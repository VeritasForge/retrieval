import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../repositories/study_item_repository.dart';

/// 학습 항목 삭제 유스케이스
class DeleteStudyItem {
  final StudyItemRepository repository;

  DeleteStudyItem({required this.repository});

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw const ValidationException('학습 항목 ID는 비어있을 수 없습니다.');
    }

    return repository.delete(id);
  }
}
