import 'package:hive/hive.dart';

import '../../domain/entities/category.dart';

part 'category_model_v2.g.dart';

@HiveType(typeId: 4)
class CategoryModelV2 extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String iconName;

  @HiveField(3)
  final String colorHex;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5, defaultValue: false)
  final bool isDefault;

  @HiveField(6, defaultValue: 0)
  final int order;

  CategoryModelV2({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.createdAt,
    this.isDefault = false,
    this.order = 0,
  });

  factory CategoryModelV2.fromEntity(Category category) {
    return CategoryModelV2(
      id: category.id,
      name: category.name,
      iconName: category.iconName,
      colorHex: category.colorHex,
      createdAt: category.createdAt,
      isDefault: category.isDefault,
      order: category.order,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      isDefault: isDefault,
      createdAt: createdAt,
      order: order,
    );
  }
}
