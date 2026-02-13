import '../../domain/entities/strategy.dart';
import '../../domain/repositories/strategy_repository.dart';
import '../datasources/strategy_local_datasource.dart';
import '../models/strategy_model.dart';

class StrategyRepositoryImpl implements StrategyRepository {
  final StrategyLocalDataSource localDataSource;

  StrategyRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Strategy>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Strategy?> getById(String id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<Strategy> create(Strategy strategy) async {
    final model = StrategyModel.fromEntity(strategy);
    await localDataSource.save(model);
    return strategy;
  }

  @override
  Future<Strategy> update(Strategy strategy) async {
    final model = StrategyModel.fromEntity(strategy);
    await localDataSource.save(model);
    return strategy;
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }
}
