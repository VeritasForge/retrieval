import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../category/presentation/providers/category_provider.dart';
import '../../../review/domain/entities/review_schedule.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../study_item/domain/entities/study_item.dart';
import '../../../study_item/presentation/providers/study_item_provider.dart';
import '../../domain/entities/review_statistics.dart';

/// 오늘의 복습 통계 Provider
final todayStatisticsProvider = Provider<AsyncValue<ReviewStatistics>>((ref) {
  final reviewsAsync = ref.watch(todayReviewListProvider);
  final studyItemsAsync = ref.watch(studyItemListProvider);
  final categoriesAsync = ref.watch(categoryListProvider);

  return reviewsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (reviews) {
      return studyItemsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (studyItems) {
          return categoriesAsync.when(
            loading: () => const AsyncValue.loading(),
            error: (e, st) => AsyncValue.error(e, st),
            data: (categories) {
              final stats = _calculateStatistics(
                reviews: reviews,
                studyItems: studyItems,
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

ReviewStatistics _calculateStatistics({
  required List<ReviewSchedule> reviews,
  required List<StudyItem> studyItems,
  required Map<String, String> categoryNames,
}) {
  // 학습 항목 ID -> 카테고리 ID 매핑
  final itemCategoryMap = {
    for (var item in studyItems) item.id: item.categoryId,
  };

  // 카테고리별 통계 계산
  final categoryStats = <String, CategoryStatistics>{};

  for (var review in reviews) {
    final categoryId = itemCategoryMap[review.studyItemId];
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
