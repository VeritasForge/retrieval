import 'package:equatable/equatable.dart';

/// 카테고리 엔티티
class Category extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final bool isDefault;
  final DateTime createdAt;
  final int order;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    this.isDefault = false,
    required this.createdAt,
    this.order = 0,
  });

  /// 새 카테고리 생성
  factory Category.create({
    required String id,
    required String name,
    required String iconName,
    required String colorHex,
    bool isDefault = false,
    DateTime? createdAt,
    int order = 0,
  }) {
    return Category(
      id: id,
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      isDefault: isDefault,
      createdAt: createdAt ?? DateTime.now(),
      order: order,
    );
  }

  /// 카테고리 복사 (변경 가능)
  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    bool? isDefault,
    DateTime? createdAt,
    int? order,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, iconName, colorHex, isDefault, createdAt, order];
}
