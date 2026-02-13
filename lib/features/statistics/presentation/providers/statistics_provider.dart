import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../review/domain/entities/review_schedule.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../task/domain/entities/task.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../../domain/entities/review_statistics.dart';

/// 오늘의 복습 통계 Provider
final todayStatisticsProvider = Provider<AsyncValue<ReviewStatistics>>((ref) {
  final reviewsAsync = ref.watch(todayReviewListProvider);
  final tasksAsync = ref.watch(taskListProvider);
  final categoriesAsync = ref.watch(categoryListProvider);

  return reviewsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (reviews) {
      return tasksAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (tasks) {
          return categoriesAsync.when(
            loading: () => const AsyncValue.loading(),
            error: (e, st) => AsyncValue.error(e, st),
            data: (categories) {
              final stats = _calculateStatistics(
                reviews: reviews,
                tasks: tasks,
                categoryNames: {
                  for (var c in categories) c.id: c.name,
                },
              );
              return AsyncValue.data(stats);
            },
          );
        },
      );
    },
  );
});

/// 오늘 서브태스크 완료율 Provider
final todaySubtaskCompletionProvider = Provider<AsyncValue<({int completed, int total})>>((ref) {
  final reviewsAsync = ref.watch(todayReviewListProvider);
  final tasksAsync = ref.watch(taskListProvider);

  return reviewsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (reviews) {
      return tasksAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (tasks) {
          final taskMap = {for (var t in tasks) t.id: t};
          int totalSubtasks = 0;
          int completedSubtasks = 0;

          final todayReviews = reviews.where(
            (r) => AppDateUtils.isTodayOrPast(r.scheduledDate),
          );

          for (final review in todayReviews) {
            final task = taskMap[review.taskId];
            if (task != null) {
              totalSubtasks += task.subtasks.length;
              completedSubtasks +=
                  task.subtasks.where((s) => s.isCompleted).length;
            }
          }

          return AsyncValue.data((
            completed: completedSubtasks,
            total: totalSubtasks,
          ));
        },
      );
    },
  );
});

ReviewStatistics _calculateStatistics({
  required List<ReviewSchedule> reviews,
  required List<Task> tasks,
  required Map<String, String> categoryNames,
}) {
  // 태스크 ID -> 카테고리 ID 매핑
  final taskCategoryMap = {
    for (var task in tasks) task.id: task.categoryId,
  };

  // 카테고리별 통계 계산
  final categoryStats = <String, CategoryStatistics>{};

  for (var review in reviews) {
    final categoryId = taskCategoryMap[review.taskId];
    if (categoryId == null) continue;

    final existing = categoryStats[categoryId];
    if (existing == null) {
      categoryStats[categoryId] = CategoryStatistics(
        categoryId: categoryId,
        categoryName: categoryNames[categoryId] ?? '알 수 없음',
        totalReviews: 1,
        completedReviews: review.isCompleted ? 1 : 0,
      );
    } else {
      categoryStats[categoryId] = CategoryStatistics(
        categoryId: categoryId,
        categoryName: existing.categoryName,
        totalReviews: existing.totalReviews + 1,
        completedReviews:
            existing.completedReviews + (review.isCompleted ? 1 : 0),
      );
    }
  }

  return ReviewStatistics(
    totalReviews: reviews.length,
    completedReviews: reviews.where((r) => r.isCompleted).length,
    categoryStats: categoryStats,
  );
}
