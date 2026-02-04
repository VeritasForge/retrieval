import 'package:equatable/equatable.dart';

import 'package:retrieval/core/constants/review_cycles.dart';

/// 학습 항목 엔티티
class StudyItem extends Equatable {
  final String id;
  final String categoryId;
  final String? subCategoryId;
  final String content;
  final bool isCheckbox;
  final DateTime studyDate;
  final ReviewCycle reviewCycle;
  final DateTime createdAt;

  const StudyItem({
    required this.id,
    required this.categoryId,
    this.subCategoryId,
    required this.content,
    required this.isCheckbox,
    required this.studyDate,
    required this.reviewCycle,
    required this.createdAt,
  });

  /// 새 학습 항목 생성
  factory StudyItem.create({
    required String id,
    required String categoryId,
    String? subCategoryId,
    required String content,
    required bool isCheckbox,
    required DateTime studyDate,
    required ReviewCycle reviewCycle,
    DateTime? createdAt,
  }) {
    return StudyItem(
      id: id,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      content: content,
      isCheckbox: isCheckbox,
      studyDate: studyDate,
      reviewCycle: reviewCycle,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// 학습 항목 복사 (변경 가능)
  StudyItem copyWith({
    String? id,
    String? categoryId,
    String? subCategoryId,
    String? content,
    bool? isCheckbox,
    DateTime? studyDate,
    ReviewCycle? reviewCycle,
    DateTime? createdAt,
  }) {
    return StudyItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      content: content ?? this.content,
      isCheckbox: isCheckbox ?? this.isCheckbox,
      studyDate: studyDate ?? this.studyDate,
      reviewCycle: reviewCycle ?? this.reviewCycle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        subCategoryId,
        content,
        isCheckbox,
        studyDate,
        reviewCycle,
        createdAt,
      ];
}
