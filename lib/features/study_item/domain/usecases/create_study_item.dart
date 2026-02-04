import 'package:uuid/uuid.dart';

import 'package:retrieval/core/constants/review_cycles.dart';
import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../entities/study_item.dart';
import '../repositories/study_item_repository.dart';

/// 학습 항목 생성 파라미터
class CreateStudyItemParams {
  final String categoryId;
  final String? subCategoryId;
  final String content;
  final bool isCheckbox;
  final DateTime studyDate;
  final ReviewCycle reviewCycle;

  const CreateStudyItemParams({
    required this.categoryId,
    this.subCategoryId,
    required this.content,
    required this.isCheckbox,
    required this.studyDate,
    required this.reviewCycle,
  });
}

/// 학습 항목 생성 유스케이스
class CreateStudyItem {
  final StudyItemRepository repository;
  final Uuid uuid;

  CreateStudyItem({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<StudyItem> call(CreateStudyItemParams params) async {
    if (params.categoryId.isEmpty) {
      throw const ValidationException('카테고리 ID는 비어있을 수 없습니다.');
    }
    if (params.content.trim().isEmpty) {
      throw const ValidationException('학습 내용은 비어있을 수 없습니다.');
    }

    final studyItem = StudyItem.create(
      id: uuid.v4(),
      categoryId: params.categoryId,
      subCategoryId: params.subCategoryId,
      content: params.content.trim(),
      isCheckbox: params.isCheckbox,
      studyDate: params.studyDate,
      reviewCycle: params.reviewCycle,
    );

    return repository.create(studyItem);
  }
}
