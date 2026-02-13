import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import '../../../task/domain/entities/task.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../../../task/presentation/widgets/subtask_item.dart';
import '../widgets/completion_donut_chart.dart';

/// 확장된 review ID 상태
final _expandedReviewIdsProvider = StateProvider<Set<String>>((ref) => {});

/// 통계 페이지
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(todayReviewListProvider);
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final strategiesAsync = ref.watch(strategyListProvider);
    final allReviewsAsync = ref.watch(_allReviewsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final isLoading = reviewsAsync.isLoading ||
                tasksAsync.isLoading ||
                categoriesAsync.isLoading ||
                strategiesAsync.isLoading ||
                allReviewsAsync.isLoading;
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = reviewsAsync.error ??
                tasksAsync.error ??
                categoriesAsync.error ??
                strategiesAsync.error ??
                allReviewsAsync.error;
            if (error != null) {
              return Center(child: Text('Error: $error'));
            }

            return _buildContent(
              context,
              ref,
              todayReviews: reviewsAsync.value!,
              allReviews: allReviewsAsync.value!,
              tasks: tasksAsync.value!,
              categories: categoriesAsync.value!,
              strategies: strategiesAsync.value!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required List<ReviewSchedule> todayReviews,
    required List<ReviewSchedule> allReviews,
    required List<Task> tasks,
    required List<Category> categories,
    required List<Strategy> strategies,
  }) {
    final taskMap = {for (var t in tasks) t.id: t};
    final categoryMap = {for (var c in categories) c.id: c};
    final strategyMap = {for (var s in strategies) s.id: s};

    // Today's summary
    final todayActive =
        todayReviews.where((r) => !r.isCompleted).length;
    final todayCompleted =
        todayReviews.where((r) => r.isCompleted).length;

    // All completed reviews (for history)
    final completedReviews = allReviews
        .where((r) => r.isCompleted && r.completedAt != null)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    // Group by date
    final groupedByDate = <String, List<ReviewSchedule>>{};
    for (final review in completedReviews) {
      final dateKey = DateFormat('yyyy-MM-dd').format(review.completedAt!);
      groupedByDate.putIfAbsent(dateKey, () => []).add(review);
    }
    final sortedDates = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Growth Stats',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '복습 이력과 통계를 확인하세요.',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Today's summary card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Row(
                children: [
                  CompletionDonutChart(
                    completed: todayCompleted,
                    total:
                        (todayActive + todayCompleted) > 0
                            ? todayActive + todayCompleted
                            : 1,
                    size: 100,
                    title: 'Today',
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 요약',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          icon: Icons.check_circle,
                          iconColor: AppColors.emerald,
                          label: '완료',
                          value: '$todayCompleted',
                        ),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          icon: Icons.circle,
                          iconColor: AppColors.indigo,
                          label: '남은 복습',
                          value: '$todayActive',
                        ),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          icon: Icons.history,
                          iconColor: AppColors.amber,
                          label: '전체 완료',
                          value: '${completedReviews.length}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Review history
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.history, color: AppColors.indigo, size: 14),
                const SizedBox(width: 8),
                const Text(
                  '복습 이력',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        if (completedReviews.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  '아직 완료된 복습이 없습니다.',
                  style: TextStyle(
                    color: AppColors.textQuaternary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dateKey = sortedDates[index];
                final reviews = groupedByDate[dateKey]!;
                final date = DateTime.parse(dateKey);
                final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;
                final dateLabel = isToday
                    ? '오늘'
                    : DateFormat('MM월 dd일 (E)', 'ko').format(date);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date label
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.indigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$dateLabel (${reviews.length})',
                          style: TextStyle(
                            color: AppColors.indigo,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Review items
                      ...reviews.map((review) {
                        final task = taskMap[review.taskId];
                        if (task == null) return const SizedBox.shrink();
                        final category = categoryMap[task.categoryId];
                        final strategy = strategyMap[task.strategyId];

                        final categoryColor = category != null
                            ? ColorUtils.fromHex(category.colorHex)
                            : AppColors.textQuaternary;

                        final studyDateStr =
                            DateFormat('MM.dd').format(task.studyDate);

                        final isExpanded = ref
                            .watch(_expandedReviewIdsProvider)
                            .contains(review.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: GestureDetector(
                            onTap: () {
                              final ids = ref
                                  .read(_expandedReviewIdsProvider.notifier)
                                  .state;
                              if (ids.contains(review.id)) {
                                ref
                                    .read(_expandedReviewIdsProvider
                                        .notifier)
                                    .state = {...ids}..remove(review.id);
                              } else {
                                ref
                                    .read(_expandedReviewIdsProvider
                                        .notifier)
                                    .state = {...ids, review.id};
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.surfaceVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: categoryColor
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          category != null
                                              ? IconUtils.getIcon(
                                                  category.iconName)
                                              : Icons.help_outline,
                                          color: categoryColor,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${category?.name ?? '미분류'} · $studyDateStr',
                                              style: const TextStyle(
                                                color:
                                                    AppColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (strategy != null)
                                              _buildScheduleDateChips(
                                                strategy,
                                                task,
                                                review,
                                                categoryColor,
                                              )
                                            else
                                              Text(
                                                'Level ${review.reviewOrder}',
                                                style: TextStyle(
                                                  color: AppColors
                                                      .textTertiary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.emerald,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  // Expanded subtask list
                                  if (isExpanded &&
                                      task.subtasks.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    ...task.subtasks.map(
                                      (subtask) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: SubtaskItem(
                                          subtask: subtask,
                                          onTap: null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
              childCount: sortedDates.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildScheduleDateChips(
    Strategy strategy,
    Task task,
    ReviewSchedule review,
    Color categoryColor,
  ) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(strategy.intervals.length, (i) {
        final date =
            AppDateUtils.addDays(task.studyDate, strategy.intervals[i]);
        final dateStr = DateFormat('MM.dd').format(date);
        final isCompleted = i < review.reviewOrder;
        final isCurrent = i == review.reviewOrder - 1;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isCurrent
                ? categoryColor.withValues(alpha: 0.15)
                : AppColors.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border: isCurrent
                ? Border.all(color: categoryColor.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  color: isCompleted
                      ? categoryColor
                      : AppColors.textQuaternary,
                  fontSize: 10,
                  fontWeight:
                      isCompleted ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.check,
                  size: 10,
                  color: categoryColor,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 10),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// All reviews provider (fetches from repository directly)
final _allReviewsProvider =
    FutureProvider<List<ReviewSchedule>>((ref) async {
  final repo = ref.watch(reviewScheduleRepositoryProvider);
  return repo.getAll();
});
