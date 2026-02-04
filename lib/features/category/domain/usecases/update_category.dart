import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// 카테고리 수정 유스케이스
class UpdateCategory {
  final CategoryRepository repository;

  UpdateCategory({required this.repository});

  Future<Category> call(Category category) async {
    if (category.name.trim().isEmpty) {
      throw const ValidationException('카테고리 이름은 비어있을 수 없습니다.');
    }

    return repository.update(category.copyWith(name: category.name.trim()));
  }
}
