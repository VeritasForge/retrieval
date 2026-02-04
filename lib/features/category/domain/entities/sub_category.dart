import 'package:equatable/equatable.dart';

/// 소분류 카테고리 엔티티
class SubCategory extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final DateTime createdAt;

  const SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.createdAt,
  });

  /// 새 소분류 생성
  factory SubCategory.create({
    required String id,
    required String categoryId,
    required String name,
    DateTime? createdAt,
  }) {
    return SubCategory(
      id: id,
      categoryId: categoryId,
      name: name,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// 소분류 복사 (변경 가능)
  SubCategory copyWith({
    String? id,
    String? categoryId,
    String? name,
    DateTime? createdAt,
  }) {
    return SubCategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, categoryId, name, createdAt];
}
