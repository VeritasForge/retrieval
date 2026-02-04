import 'package:hive/hive.dart';

import '../../domain/entities/sub_category.dart';

part 'sub_category_model.g.dart';

@HiveType(typeId: 1)
class SubCategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final DateTime createdAt;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.createdAt,
  });

  factory SubCategoryModel.fromEntity(SubCategory subCategory) {
    return SubCategoryModel(
      id: subCategory.id,
      categoryId: subCategory.categoryId,
      name: subCategory.name,
      createdAt: subCategory.createdAt,
    );
  }

  SubCategory toEntity() {
    return SubCategory(
      id: id,
      categoryId: categoryId,
      name: name,
      createdAt: createdAt,
    );
  }
}
