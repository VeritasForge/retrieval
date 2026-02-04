import 'package:hive/hive.dart';

import 'package:retrieval/core/constants/review_cycles.dart';
import '../../domain/entities/study_item.dart';

part 'study_item_model.g.dart';

@HiveType(typeId: 2)
class StudyItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String? subCategoryId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final bool isCheckbox;

  @HiveField(5)
  final DateTime studyDate;

  @HiveField(6)
  final String reviewCycleName;

  @HiveField(7)
  final DateTime createdAt;

  StudyItemModel({
    required this.id,
    required this.categoryId,
    this.subCategoryId,
    required this.content,
    required this.isCheckbox,
    required this.studyDate,
    required this.reviewCycleName,
    required this.createdAt,
  });

  factory StudyItemModel.fromEntity(StudyItem studyItem) {
    return StudyItemModel(
      id: studyItem.id,
      categoryId: studyItem.categoryId,
      subCategoryId: studyItem.subCategoryId,
      content: studyItem.content,
      isCheckbox: studyItem.isCheckbox,
      studyDate: studyItem.studyDate,
      reviewCycleName: studyItem.reviewCycle.name,
      createdAt: studyItem.createdAt,
    );
  }

  StudyItem toEntity() {
    return StudyItem(
      id: id,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      content: content,
      isCheckbox: isCheckbox,
      studyDate: studyDate,
      reviewCycle: ReviewCycle.values.firstWhere((c) => c.name == reviewCycleName),
      createdAt: createdAt,
    );
  }
}
