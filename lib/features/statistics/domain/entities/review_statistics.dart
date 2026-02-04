import 'package:equatable/equatable.dart';

/// 복습 통계 엔티티
class ReviewStatistics extends Equatable {
  final int totalReviews;
  final int completedReviews;
  final Map<String, CategoryStatistics> categoryStats;

  const ReviewStatistics({
    required this.totalReviews,
    required this.completedReviews,
    required this.categoryStats,
  });

  double get completionRate =>
      totalReviews > 0 ? completedReviews / totalReviews : 0;

  int get pendingReviews => totalReviews - completedReviews;

  @override
  List<Object?> get props => [totalReviews, completedReviews, categoryStats];
}

/// 카테고리별 통계
class CategoryStatistics extends Equatable {
  final String categoryId;
  final String categoryName;
  final int totalReviews;
  final int completedReviews;

  const CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.totalReviews,
    required this.completedReviews,
  });

  double get completionRate =>
      totalReviews > 0 ? completedReviews / totalReviews : 0;

  int get pendingReviews => totalReviews - completedReviews;

  @override
  List<Object?> get props =>
      [categoryId, categoryName, totalReviews, completedReviews];
}
