import '../entities/study_item.dart';
import '../repositories/study_item_repository.dart';

/// 모든 학습 항목 조회 유스케이스
class GetStudyItems {
  final StudyItemRepository repository;

  GetStudyItems({required this.repository});

  Future<List<StudyItem>> call() async {
    return repository.getAll();
  }
}

/// 카테고리별 학습 항목 조회 유스케이스
class GetStudyItemsByCategory {
  final StudyItemRepository repository;

  GetStudyItemsByCategory({required this.repository});

  Future<List<StudyItem>> call(String categoryId) async {
    return repository.getByCategoryId(categoryId);
  }
}
