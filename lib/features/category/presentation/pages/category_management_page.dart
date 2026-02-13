import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../../../task/presentation/providers/task_provider.dart';

/// 카테고리 정렬 (order 기준)
List<Category> _sortCategories(List<Category> categories) {
  return List<Category>.from(categories)
    ..sort((a, b) => a.order.compareTo(b.order));
}

/// 색상 팔레트
const _colorPalette = [
  '10B981', // emerald
  '6366F1', // indigo
  'F59E0B', // amber
  'F43F5E', // rose
  '3B82F6', // blue
  '8B5CF6', // violet
  'EC4899', // pink
  '14B8A6', // teal
  'EF4444', // red
  '22C55E', // green
  'F97316', // orange
  '06B6D4', // cyan
];

/// 카테고리 관리 페이지
class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (categories) {
            final sorted = _sortCategories(categories);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Garden',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '학습 카테고리를 관리하세요.',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Reorderable category list + create button
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.only(bottom: 100),
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      // Create 버튼 인덱스는 무시
                      if (oldIndex >= sorted.length ||
                          newIndex > sorted.length) {
                        return;
                      }
                      ref
                          .read(categoryListProvider.notifier)
                          .reorder(oldIndex, newIndex);
                    },
                    itemCount: sorted.length + 1,
                    itemBuilder: (context, index) {
                      // 마지막 아이템: Create 버튼 (드래그 핸들 없음 → 드래그 불가)
                      if (index == sorted.length) {
                        return Padding(
                          key: const ValueKey('__create_button__'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: _CreateCategoryButton(
                            onTap: () => _showCategoryDialog(context, ref),
                          ),
                        );
                      }
                      final category = sorted[index];
                      return Padding(
                        key: ValueKey(category.id),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 6),
                        child: _CategoryCard(
                          index: index,
                          category: category,
                          onEdit: category.isDefault
                              ? null
                              : () => _showCategoryDialog(
                                    context, ref,
                                    existing: category,
                                  ),
                          onDelete: category.isDefault
                              ? null
                              : () => _showSafeDeleteDialog(
                                    context, ref, category),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? existing,
  }) {
    final isEdit = existing != null;
    final nameController = TextEditingController(
      text: isEdit ? existing.name : '',
    );
    String selectedIcon = isEdit ? existing.iconName : 'lightbulb';
    String selectedColor = isEdit ? existing.colorHex : _colorPalette[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isEdit ? 'Edit Category' : 'New Category',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Category name',
                    hintStyle: TextStyle(color: AppColors.textQuaternary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon selector
                Text(
                  'Icon',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: IconUtils.availableIcons.map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() => selectedIcon = iconName);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ColorUtils.fromHex(selectedColor)
                                  .withValues(alpha: 0.2)
                              : AppColors.surfaceVariant
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(
                                  color: ColorUtils.fromHex(selectedColor),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          IconUtils.getIcon(iconName),
                          size: 20,
                          color: isSelected
                              ? ColorUtils.fromHex(selectedColor)
                              : AppColors.textTertiary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color selector
                Text(
                  'Color',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorPalette.map((hex) {
                    final isSelected = selectedColor == hex;
                    final color = ColorUtils.fromHex(hex);
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() => selectedColor = hex);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  if (isEdit) {
                    ref.read(categoryListProvider.notifier).update(
                          existing.copyWith(
                            name: name,
                            iconName: selectedIcon,
                            colorHex: selectedColor,
                          ),
                        );
                  } else {
                    ref.read(categoryListProvider.notifier).add(
                          name,
                          selectedIcon,
                          selectedColor,
                        );
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
    });
  }

  void _showSafeDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final taskRepo = ref.read(taskRepositoryProvider);
    final tasks = await taskRepo.getByCategoryId(category.id);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          '카테고리 삭제',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          tasks.isNotEmpty
              ? "이 카테고리에 ${tasks.length}개의 학습 항목이 있습니다.\n삭제하면 해당 항목의 카테고리가 '미분류'로 표시됩니다."
              : "'${category.name}' 카테고리를 삭제하시겠습니까?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoryListProvider.notifier).remove(category.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.rose),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final int index;
  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryCard({
    required this.index,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromHex(category.colorHex);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconUtils.getIcon(category.iconName),
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (category.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: AppColors.textQuaternary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!category.isDefault) ...[
            GestureDetector(
              onTap: onEdit,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          ReorderableDragStartListener(
            index: index,
            child: const Icon(
              Icons.drag_handle,
              color: AppColors.textQuaternary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateCategoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateCategoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.surfaceVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Text(
            '+ Create New Category',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
