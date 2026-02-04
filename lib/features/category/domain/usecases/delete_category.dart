import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../repositories/category_repository.dart';

/// 카테고리 삭제 유스케이스
class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory({required this.repository});

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw const ValidationException('카테고리 ID는 비어있을 수 없습니다.');
    }

    return repository.delete(id);
  }
}
