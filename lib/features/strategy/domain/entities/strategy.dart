import 'package:equatable/equatable.dart';

/// 복습 전략 엔티티
class Strategy extends Equatable {
  final String id;
  final String name;
  final List<int> intervals;
  final bool isDefault;
  final DateTime createdAt;

  const Strategy({
    required this.id,
    required this.name,
    required this.intervals,
    required this.isDefault,
    required this.createdAt,
  });

  /// 전략 복사 (변경 가능)
  Strategy copyWith({
    String? id,
    String? name,
    List<int>? intervals,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Strategy(
      id: id ?? this.id,
      name: name ?? this.name,
      intervals: intervals ?? this.intervals,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, intervals, isDefault, createdAt];
}
