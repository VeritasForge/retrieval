import 'package:uuid/uuid.dart';

import '../entities/strategy.dart';
import '../repositories/strategy_repository.dart';

/// 기본 전략 시딩 유스케이스
class SeedDefaultStrategies {
  final StrategyRepository repository;
  final Uuid uuid;

  SeedDefaultStrategies({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<void> call() async {
    final existing = await repository.getAll();
    if (existing.isNotEmpty) return;

    final defaults = [
      Strategy(
        id: uuid.v4(),
        name: '에빙하우스 (표준)',
        intervals: const [1, 3, 7, 14, 30],
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Strategy(
        id: uuid.v4(),
        name: '피보나치 (자연)',
        intervals: const [1, 2, 3, 5, 8, 13],
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      Strategy(
        id: uuid.v4(),
        name: '단기 집중 (스피드)',
        intervals: const [1, 3, 6, 10],
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (final strategy in defaults) {
      await repository.create(strategy);
    }
  }
}
