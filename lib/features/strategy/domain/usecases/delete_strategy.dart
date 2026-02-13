import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../repositories/strategy_repository.dart';

/// 전략 삭제 유스케이스
class DeleteStrategy {
  final StrategyRepository repository;

  DeleteStrategy({required this.repository});

  Future<void> call(String id) async {
    final strategy = await repository.getById(id);
    if (strategy == null) {
      throw StrategyException('전략을 찾을 수 없습니다: $id');
    }

    if (strategy.isDefault) {
      throw const StrategyException('기본 전략은 삭제할 수 없습니다.');
    }

    return repository.delete(id);
  }
}
