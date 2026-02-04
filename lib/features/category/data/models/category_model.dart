import 'package:hive/hive.dart';

import '../../domain/entities/category.dart';
import 'sub_category_model.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<SubCategoryModel> subCategories;

  @HiveField(3)
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.subCategories,
    required this.createdAt,
  });

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      subCategories: category.subCategories
          .map((sc) => SubCategoryModel.fromEntity(sc))
          .toList(),
      createdAt: category.createdAt,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      subCategories: subCategories.map((sc) => sc.toEntity()).toList(),
      createdAt: createdAt,
    );
  }
}
