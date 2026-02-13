import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../entities/strategy.dart';
import '../repositories/strategy_repository.dart';

/// 전략 수정 유스케이스
class UpdateStrategy {
  final StrategyRepository repository;

  UpdateStrategy({required this.repository});

  Future<Strategy> call(Strategy strategy) async {
    if (strategy.isDefault) {
      throw const StrategyException('기본 전략은 수정할 수 없습니다.');
    }

    return repository.update(strategy);
  }
}
