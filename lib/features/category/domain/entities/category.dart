import 'package:equatable/equatable.dart';

import 'sub_category.dart';

/// 대분류 카테고리 엔티티
class Category extends Equatable {
  final String id;
  final String name;
  final List<SubCategory> subCategories;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.subCategories,
    required this.createdAt,
  });

  /// 새 카테고리 생성 (빈 소분류 목록)
  factory Category.create({
    required String id,
    required String name,
    DateTime? createdAt,
  }) {
    return Category(
      id: id,
      name: name,
      subCategories: const [],
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// 카테고리 복사 (변경 가능)
  Category copyWith({
    String? id,
    String? name,
    List<SubCategory>? subCategories,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      subCategories: subCategories ?? this.subCategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 소분류 추가
  Category addSubCategory(SubCategory subCategory) {
    return copyWith(
      subCategories: [...subCategories, subCategory],
    );
  }

  /// 소분류 제거
  Category removeSubCategory(String subCategoryId) {
    return copyWith(
      subCategories:
          subCategories.where((sc) => sc.id != subCategoryId).toList(),
    );
  }

  /// 소분류 업데이트
  Category updateSubCategory(SubCategory updatedSubCategory) {
    return copyWith(
      subCategories: subCategories.map((sc) {
        return sc.id == updatedSubCategory.id ? updatedSubCategory : sc;
      }).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, subCategories, createdAt];
}
