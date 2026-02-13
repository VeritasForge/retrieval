import 'package:hive/hive.dart';

import '../../domain/entities/strategy.dart';

part 'strategy_model.g.dart';

@HiveType(typeId: 5)
class StrategyModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<int> intervals;

  @HiveField(3)
  final bool isDefault;

  @HiveField(4)
  final DateTime createdAt;

  StrategyModel({
    required this.id,
    required this.name,
    required this.intervals,
    required this.isDefault,
    required this.createdAt,
  });

  factory StrategyModel.fromEntity(Strategy strategy) {
    return StrategyModel(
      id: strategy.id,
      name: strategy.name,
      intervals: strategy.intervals,
      isDefault: strategy.isDefault,
      createdAt: strategy.createdAt,
    );
  }

  Strategy toEntity() {
    return Strategy(
      id: id,
      name: name,
      intervals: intervals,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }
}
