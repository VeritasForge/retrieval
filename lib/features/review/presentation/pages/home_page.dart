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
import '../../../statistics/presentation/widgets/completion_donut_chart.dart';
import '../../../strategy/domain/entities/strategy.dart';
import '../../../strategy/presentation/providers/strategy_provider.dart';
import '../../../task/domain/entities/task.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../../../task/presentation/widgets/add_task_bottom_sheet.dart';
import '../../../task/presentation/widgets/task_card.dart';
import '../providers/review_provider.dart';

/// Completed Sets 접기/펼치기 상태
final _completedExpandedProvider = StateProvider<bool>((ref) => false);

/// 홈 페이지
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(todayReviewListProvider);
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final strategiesAsync = ref.watch(strategyListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final isLoading = reviewsAsync.isLoading ||
                tasksAsync.isLoading ||
                categoriesAsync.isLoading ||
                strategiesAsync.isLoading;
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = reviewsAsync.error ??
                tasksAsync.error ??
                categoriesAsync.error ??
                strategiesAsync.error;
            if (error != null) {
              return Center(child: Text('Error: $error'));
            }

            return _buildContent(
              context,
              ref,
              reviews: reviewsAsync.value!,
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
    required List<ReviewSchedule> reviews,
    required List<Task> tasks,
    required List<Category> categories,
    required List<Strategy> strategies,
  }) {
    // Build lookup maps
    final taskMap = {for (var t in tasks) t.id: t};
    final categoryMap = {for (var c in categories) c.id: c};
    final strategyMap = {for (var s in strategies) s.id: s};

    // Split reviews: active (today/past, not completed) vs completed vs future
    final activeReviews = <ReviewSchedule>[];
    final completedReviews = <ReviewSchedule>[];
    final futureReviews = <ReviewSchedule>[];

    for (final review in reviews) {
      if (AppDateUtils.isTodayOrPast(review.scheduledDate)) {
        if (review.isCompleted) {
          completedReviews.add(review);
        } else {
          activeReviews.add(review);
        }
      } else {
        futureReviews.add(review);
      }
    }

    // Also find future schedules from all reviews (including completed)
    // For the "Future Neural Schedule", gather unfinished future schedules
    futureReviews.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    // Calculate subtask completion for active reviews
    int totalSubtasks = 0;
    int completedSubtasks = 0;
    for (final review in activeReviews) {
      final task = taskMap[review.taskId];
      if (task != null) {
        totalSubtasks += task.subtasks.length;
        completedSubtasks +=
            task.subtasks.where((s) => s.isCompleted).length;
      }
    }
    final completionPercent =
        totalSubtasks > 0 ? (completedSubtasks / totalSubtasks * 100).round() : 0;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(context),
        ),

        // Dashboard card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildDashboard(
              completedSubtasks,
              totalSubtasks,
              completionPercent,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Active Learning Sets
        if (activeReviews.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSectionHeader(
                icon: Icons.circle,
                iconColor: AppColors.indigo,
                iconSize: 8,
                title: 'Active Learning Sets (${activeReviews.length})',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final review = activeReviews[index];
                final task = taskMap[review.taskId];
                if (task == null) return const SizedBox.shrink();
                final category = categoryMap[task.categoryId];
                final strategy = strategyMap[task.strategyId];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 6),
                  child: TaskCard(
                    task: task,
                    category: category,
                    strategy: strategy,
                    scheduledDate: review.scheduledDate,
                    onToggleSubtask: (subtaskId) {
                      ref
                          .read(taskListProvider.notifier)
                          .toggle(task.id, subtaskId);
                    },
                    onComplete: () async {
                      await ref
                          .read(todayReviewListProvider.notifier)
                          .complete(review.id);
                      ref.read(taskListProvider.notifier).load();
                    },
                  ),
                );
              },
              childCount: activeReviews.length,
            ),
          ),
        ] else if (completedReviews.isEmpty) ...[
          // Empty state (no active and no completed)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.emerald.withValues(alpha: 0.5),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '오늘 복습할 항목이 없습니다',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '새로운 학습을 추가해보세요!',
                    style: TextStyle(
                      color: AppColors.textQuaternary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Completed Sets (collapsible)
        if (completedReviews.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () {
                  ref.read(_completedExpandedProvider.notifier).state =
                      !ref.read(_completedExpandedProvider);
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.emerald, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'Completed Sets (${completedReviews.length})',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      ref.watch(_completedExpandedProvider)
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (ref.watch(_completedExpandedProvider)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final review = completedReviews[index];
                  final task = taskMap[review.taskId];
                  if (task == null) return const SizedBox.shrink();
                  final category = categoryMap[task.categoryId];
                  final strategy = strategyMap[task.strategyId];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 4),
                    child: _CompletedSetCard(
                      task: task,
                      category: category,
                      strategy: strategy,
                    ),
                  );
                },
                childCount: completedReviews.length,
              ),
            ),
          ],
        ],

        // Upcoming
        if (futureReviews.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSectionHeader(
                icon: Icons.schedule,
                iconColor: AppColors.amber,
                iconSize: 14,
                title: 'Upcoming (${futureReviews.length})',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildUpcomingGroups(
                futureReviews,
                taskMap,
                categoryMap,
                strategyMap,
                ref,
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildUpcomingGroups(
    List<ReviewSchedule> futureReviews,
    Map<String, Task> taskMap,
    Map<String, Category> categoryMap,
    Map<String, Strategy> strategyMap,
    WidgetRef ref,
  ) {
    // Group reviews by days until review
    final grouped = <int, List<ReviewSchedule>>{};
    for (final review in futureReviews) {
      final daysUntil = AppDateUtils.daysBetween(
          AppDateUtils.today(), review.scheduledDate);
      grouped.putIfAbsent(daysUntil, () => []).add(review);
    }

    final sortedDays = grouped.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDays.map((days) {
        final reviews = grouped[days]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day label
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$days일 후 (${DateFormat('MM.dd').format(AppDateUtils.addDays(AppDateUtils.today(), days))})',
                  style: TextStyle(
                    color: AppColors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Review items for this day
              ...reviews.map((review) {
                final task = taskMap[review.taskId];
                if (task == null) return const SizedBox.shrink();
                final category = categoryMap[task.categoryId];
                final strategy = strategyMap[task.strategyId];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _UpcomingItem(
                    task: task,
                    category: category,
                    strategy: strategy,
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.emerald, AppColors.indigo],
                ).createShader(bounds),
                child: const Text(
                  "Jay's Garden",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => AddTaskBottomSheet.show(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(int completed, int total, int percent) {
    final statusText = percent >= 100
        ? '정원이 꽉 찼어요!'
        : '지식을 키우는 중';
    final progressText = '오늘의 조각들을 $percent% 채웠어요!';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          CompletionDonutChart(
            completed: completed,
            total: total > 0 ? total : 1,
            size: 112,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  progressText,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _UpcomingItem extends StatelessWidget {
  final Task task;
  final Category? category;
  final Strategy? strategy;

  const _UpcomingItem({
    required this.task,
    this.category,
    this.strategy,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = category != null
        ? ColorUtils.fromHex(category!.colorHex)
        : AppColors.textQuaternary;

    final studyDateStr = DateFormat('MM.dd').format(task.studyDate);
    final categoryName = category?.name ?? '미분류';
    final displayTitle = '$categoryName · $studyDateStr';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category != null
                  ? IconUtils.getIcon(category!.iconName)
                  : Icons.help_outline,
              color: categoryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (strategy != null)
                  Text(
                    strategy!.name,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedSetCard extends StatelessWidget {
  final Task task;
  final Category? category;
  final Strategy? strategy;

  const _CompletedSetCard({
    required this.task,
    this.category,
    this.strategy,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = category != null
        ? ColorUtils.fromHex(category!.colorHex)
        : AppColors.textQuaternary;

    final studyDateStr = DateFormat('MM.dd').format(task.studyDate);
    final categoryName = category?.name ?? '미분류';
    final displayTitle = '$categoryName · $studyDateStr';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Checkmark icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.emerald,
              size: 16,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      category != null
                          ? IconUtils.getIcon(category!.iconName)
                          : Icons.help_outline,
                      size: 12,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category?.name ?? '미분류',
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (strategy != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: AppColors.textQuaternary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        strategy!.name,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
