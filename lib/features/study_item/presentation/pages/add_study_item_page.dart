import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../category/presentation/providers/category_provider.dart';
import 'package:retrieval/core/constants/review_cycles.dart';
import '../providers/study_item_provider.dart';

class AddStudyItemPage extends ConsumerStatefulWidget {
  const AddStudyItemPage({super.key});

  @override
  ConsumerState<AddStudyItemPage> createState() => _AddStudyItemPageState();
}

class _AddStudyItemPageState extends ConsumerState<AddStudyItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  ReviewCycle _selectedCycle = ReviewCycle.days_1_3_7;
  DateTime _studyDate = DateTime.now();
  bool _isCheckbox = true;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 기록'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('오류: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('먼저 카테고리를 추가해주세요.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/categories'),
                    child: const Text('카테고리 관리'),
                  ),
                ],
              ),
            );
          }

          final selectedCategory = _selectedCategoryId != null
              ? categories
                  .where((c) => c.id == _selectedCategoryId)
                  .firstOrNull
              : null;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 복습 주기 선택
                const Text('복습 주기', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ReviewCycle.values.map((cycle) {
                    return ChoiceChip(
                      label: Text(cycle.label),
                      selected: _selectedCycle == cycle,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCycle = cycle);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 학습 날짜
                const Text('학습 날짜', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(DateFormat('yyyy-MM-dd').format(_studyDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _studyDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _studyDate = date);
                    }
                  },
                ),
                const Divider(),

                // 대분류 선택
                const Text('대분류', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: '카테고리 선택',
                  ),
                  items: categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      _selectedSubCategoryId = null;
                    });
                  },
                  validator: (value) =>
                      value == null ? '카테고리를 선택해주세요' : null,
                ),
                const SizedBox(height: 16),

                // 소분류 선택 (선택사항)
                if (selectedCategory != null &&
                    selectedCategory.subCategories.isNotEmpty) ...[
                  const Text('소분류 (선택사항)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      hintText: '소분류 선택',
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('없음')),
                      ...selectedCategory.subCategories.map((sc) {
                        return DropdownMenuItem(
                            value: sc.id, child: Text(sc.name));
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSubCategoryId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // 입력 방식
                const Text('입력 방식', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('체크박스'),
                      selected: _isCheckbox,
                      onSelected: (selected) {
                        if (selected) setState(() => _isCheckbox = true);
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('텍스트'),
                      selected: !_isCheckbox,
                      onSelected: (selected) {
                        if (selected) setState(() => _isCheckbox = false);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 학습 내용
                const Text('학습 내용', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: _isCheckbox ? '예: 문제 1번' : '예: 1~10쪽',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? '학습 내용을 입력해주세요' : null,
                ),
                const SizedBox(height: 32),

                // 저장 버튼
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('저장'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(studyItemListProvider.notifier).add(
            categoryId: _selectedCategoryId!,
            subCategoryId: _selectedSubCategoryId,
            content: _contentController.text,
            isCheckbox: _isCheckbox,
            studyDate: _studyDate,
            reviewCycle: _selectedCycle,
          );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학습 기록이 저장되었습니다.')),
      );
    }
  }
}
