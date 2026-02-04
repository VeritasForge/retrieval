import 'package:uuid/uuid.dart';

import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../entities/category.dart';
import '../entities/sub_category.dart';
import '../repositories/category_repository.dart';

/// 소분류 추가 유스케이스
class AddSubCategory {
  final CategoryRepository repository;
  final Uuid uuid;

  AddSubCategory({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Category> call(String categoryId, String name) async {
    if (categoryId.isEmpty) {
      throw const ValidationException('카테고리 ID는 비어있을 수 없습니다.');
    }
    if (name.trim().isEmpty) {
      throw const ValidationException('소분류 이름은 비어있을 수 없습니다.');
    }

    final subCategory = SubCategory.create(
      id: uuid.v4(),
      categoryId: categoryId,
      name: name.trim(),
    );

    return repository.addSubCategory(categoryId, subCategory);
  }
}
