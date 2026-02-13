import 'package:uuid/uuid.dart';

import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../entities/strategy.dart';
import '../repositories/strategy_repository.dart';

/// 전략 생성 유스케이스
class CreateStrategy {
  final StrategyRepository repository;
  final Uuid uuid;

  CreateStrategy({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Strategy> call(String name, List<int> intervals) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('전략 이름은 비어있을 수 없습니다.');
    }

    if (intervals.isEmpty) {
      throw const ValidationException('복습 간격은 비어있을 수 없습니다.');
    }

    final strategy = Strategy(
      id: uuid.v4(),
      name: name.trim(),
      intervals: intervals,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    return repository.create(strategy);
  }
}
