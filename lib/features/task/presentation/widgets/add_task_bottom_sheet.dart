import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../review/domain/entities/review_schedule.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../strategy/domain/entities/strategy.dart';
import '../../../strategy/presentation/providers/strategy_provider.dart';
import '../../domain/usecases/create_task.dart';
import '../providers/task_provider.dart';

/// 카테고리 고정 순서
const _defaultCategoryOrder = {
  '알고리즘': 0,
  '독서': 1,
  '강의': 2,
  '메모': 3,
};

/// 기본 전략 고정 순서
const _defaultStrategyOrder = {
  '에빙하우스 (표준)': 0,
  '피보나치 (자연)': 1,
  '단기 집중 (스피드)': 2,
};

/// 카테고리 정렬: 기본 카테고리(고정 순서) → 커스텀 카테고리(생성 순서)
List<Category> _sortCategories(List<Category> categories) {
  final known = categories
      .where((c) => _defaultCategoryOrder.containsKey(c.name))
      .toList()
    ..sort((a, b) {
      final orderA = _defaultCategoryOrder[a.name] ?? 99;
      final orderB = _defaultCategoryOrder[b.name] ?? 99;
      return orderA.compareTo(orderB);
    });
  final custom = categories
      .where((c) => !_defaultCategoryOrder.containsKey(c.name))
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return [...known, ...custom];
}

/// 전략 정렬: 기본 전략(고정 순서) → 커스텀 전략(생성 순서)
List<Strategy> _sortStrategies(List<Strategy> strategies) {
  final defaults = strategies.where((s) => s.isDefault).toList()
    ..sort((a, b) {
      final orderA = _defaultStrategyOrder[a.name] ?? 99;
      final orderB = _defaultStrategyOrder[b.name] ?? 99;
      return orderA.compareTo(orderB);
    });
  final customs = strategies.where((s) => !s.isDefault).toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return [...defaults, ...customs];
}

/// 태스크 추가 바텀 시트
class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();

  /// 바텀 시트 표시
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskBottomSheet(),
    );
  }
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  String? _selectedCategoryId;
  String? _selectedStrategyId;
  final List<TextEditingController> _subtaskControllers = [
    TextEditingController(),
  ];
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtask(int index) {
    if (_subtaskControllers.length <= 1) return;
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    // Fix 2: Show validation feedback instead of silently returning
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요')),
      );
      return;
    }
    if (_selectedStrategyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전략을 선택해주세요')),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final params = CreateTaskParams(
        categoryId: _selectedCategoryId!,
        strategyId: _selectedStrategyId!,
        subtaskTitles:
            _subtaskControllers.map((c) => c.text).toList(),
      );

      final newTask = await ref.read(taskListProvider.notifier).add(params);

      // Fix 1: Create initial review schedule with TODAY's date
      // so the task appears immediately on the home screen.
      // The interval-based scheduling only applies after the first review.
      const uuidGen = Uuid();
      final initialSchedule = ReviewSchedule.create(
        id: uuidGen.v4(),
        taskId: newTask.id,
        scheduledDate: AppDateUtils.today(),
        reviewOrder: 0,
      );
      final repository = ref.read(reviewScheduleRepositoryProvider);
      await repository.create(initialSchedule);
      await ref.read(todayReviewListProvider.notifier).load();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final strategiesAsync = ref.watch(strategyListProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(56)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 64,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'New Seed Packet',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),

                // Category selector
                const Text(
                  'Category',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (categories) {
                    final sorted = _sortCategories(categories);
                    if (_selectedCategoryId == null && sorted.isNotEmpty) {
                      final defaultCat = sorted.where(
                          (c) => c.name == '알고리즘').firstOrNull;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedCategoryId == null) {
                          setState(() {
                            _selectedCategoryId =
                                defaultCat?.id ?? sorted.first.id;
                          });
                        }
                      });
                    }
                    return _buildCategoryGrid(sorted);
                  },
                ),
                const SizedBox(height: 24),

                // Strategy selector
                const Text(
                  'Strategy',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                strategiesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (strategies) {
                    final sorted = _sortStrategies(strategies);
                    if (_selectedStrategyId == null && sorted.isNotEmpty) {
                      final defaultStrat = sorted.where(
                          (s) => s.name == '에빙하우스 (표준)').firstOrNull;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedStrategyId == null) {
                          setState(() {
                            _selectedStrategyId =
                                defaultStrat?.id ?? sorted.first.id;
                          });
                        }
                      });
                    }
                    return _buildStrategyChips(sorted);
                  },
                ),
                const SizedBox(height: 24),

                // Subtask builder
                const Text(
                  'Tasks',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                ..._buildSubtaskInputs(),
                const SizedBox(height: 12),
                _buildAddStepButton(),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: GestureDetector(
                    onTap: _isSubmitting ? null : _submit,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.indigo, Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'PLANT IN MY GARDEN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: categories.map((cat) {
        final isSelected = _selectedCategoryId == cat.id;
        final color = ColorUtils.fromHex(cat.colorHex);
        return GestureDetector(
          onTap: () => setState(() => _selectedCategoryId = cat.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconUtils.getIcon(cat.iconName),
                  size: 18,
                  color: isSelected ? color : AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  cat.name,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStrategyChips(List<Strategy> strategies) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: strategies.map((strategy) {
        final isSelected = _selectedStrategyId == strategy.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedStrategyId = strategy.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.indigo.withValues(alpha: 0.15)
                  : AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected
                    ? AppColors.indigo.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              strategy.name,
              style: TextStyle(
                color: isSelected ? AppColors.indigo : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildSubtaskInputs() {
    return List.generate(_subtaskControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subtaskControllers[index],
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Task ${index + 1}',
                  hintStyle: TextStyle(
                    color: AppColors.textQuaternary,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.surfaceVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.surfaceVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.indigo),
                  ),
                ),
              ),
            ),
            if (_subtaskControllers.length > 1)
              IconButton(
                onPressed: () => _removeSubtask(index),
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textQuaternary,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAddStepButton() {
    return GestureDetector(
      onTap: _addSubtask,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Text(
            '+ Add New Task',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
