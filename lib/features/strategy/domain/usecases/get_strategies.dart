import '../entities/strategy.dart';
import '../repositories/strategy_repository.dart';

/// 모든 전략 조회 유스케이스
class GetStrategies {
  final StrategyRepository repository;

  GetStrategies({required this.repository});

  Future<List<Strategy>> call() async {
    return repository.getAll();
  }
}
