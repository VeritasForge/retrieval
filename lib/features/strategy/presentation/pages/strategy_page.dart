import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/strategy.dart';
import '../providers/strategy_provider.dart';

/// 기본 전략 고정 순서
const _defaultStrategyOrder = {
  '에빙하우스 (표준)': 0,
  '피보나치 (자연)': 1,
  '단기 집중 (스피드)': 2,
};

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

/// 전략 페이지
class StrategyPage extends ConsumerWidget {
  const StrategyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategiesAsync = ref.watch(strategyListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Strategy Shed',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '지식을 머릿속에 고정하는 복습 비법들을 관리하세요.',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Strategy list
            strategiesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
              data: (strategies) {
                final sorted = _sortStrategies(strategies);
                return SliverList(
                  delegate: SliverChildListDelegate([
                    ...sorted.map((strategy) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 6),
                          child: _StrategyCard(
                            strategy: strategy,
                            onEdit: strategy.isDefault
                                ? null
                                : () => _showStrategyDialog(
                                      context, ref,
                                      existing: strategy,
                                    ),
                            onDelete: strategy.isDefault
                                ? null
                                : () => _showDeleteConfirmDialog(
                                      context, ref, strategy),
                          ),
                        )),
                    // Create new strategy button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: _CreateStrategyButton(
                        onTap: () => _showStrategyDialog(context, ref),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStrategyDialog(
    BuildContext context,
    WidgetRef ref, {
    Strategy? existing,
  }) {
    final isEdit = existing != null;
    final nameController = TextEditingController(
      text: isEdit ? existing.name : '',
    );
    final intervalsController = TextEditingController(
      text: isEdit ? existing.intervals.join(', ') : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          isEdit ? 'Edit Strategy' : 'New Strategy',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Strategy name',
                hintStyle: TextStyle(color: AppColors.textQuaternary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: intervalsController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Intervals (e.g. 1,3,7,14)',
                hintStyle: TextStyle(color: AppColors.textQuaternary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final intervals = intervalsController.text
                  .split(',')
                  .map((s) => int.tryParse(s.trim()))
                  .whereType<int>()
                  .toList();
              if (name.isNotEmpty && intervals.isNotEmpty) {
                if (isEdit) {
                  ref.read(strategyListProvider.notifier).update(
                        existing.copyWith(
                          name: name,
                          intervals: intervals,
                        ),
                      );
                } else {
                  ref
                      .read(strategyListProvider.notifier)
                      .add(name, intervals);
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      intervalsController.dispose();
    });
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Strategy strategy,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          '전략 삭제',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          "'${strategy.name}' 전략을 삭제하시겠습니까?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(strategyListProvider.notifier).remove(strategy.id);
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

class _StrategyCard extends StatelessWidget {
  final Strategy strategy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _StrategyCard({
    required this.strategy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final intervalsText =
        strategy.intervals.map((i) => '$i').join(' \u2192 ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$intervalsText days',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!strategy.isDefault) ...[
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
        ],
      ),
    );
  }
}

class _CreateStrategyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateStrategyButton({required this.onTap});

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
            '+ Create New Strategy',
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
