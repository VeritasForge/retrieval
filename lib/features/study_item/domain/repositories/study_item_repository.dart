import '../entities/study_item.dart';

/// 학습 항목 저장소 인터페이스
abstract class StudyItemRepository {
  /// 모든 학습 항목 조회
  Future<List<StudyItem>> getAll();

  /// ID로 학습 항목 조회
  Future<StudyItem?> getById(String id);

  /// 카테고리별 학습 항목 조회
  Future<List<StudyItem>> getByCategoryId(String categoryId);

  /// 소분류별 학습 항목 조회
  Future<List<StudyItem>> getBySubCategoryId(String subCategoryId);

  /// 날짜별 학습 항목 조회
  Future<List<StudyItem>> getByStudyDate(DateTime date);

  /// 학습 항목 생성
  Future<StudyItem> create(StudyItem studyItem);

  /// 학습 항목 수정
  Future<StudyItem> update(StudyItem studyItem);

  /// 학습 항목 삭제
  Future<void> delete(String id);
}
