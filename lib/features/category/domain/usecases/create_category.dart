import 'package:uuid/uuid.dart';

import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// 카테고리 생성 유스케이스
class CreateCategory {
  final CategoryRepository repository;
  final Uuid uuid;

  CreateCategory({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Category> call(String name) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('카테고리 이름은 비어있을 수 없습니다.');
    }

    final category = Category.create(
      id: uuid.v4(),
      name: name.trim(),
    );

    return repository.create(category);
  }
}
