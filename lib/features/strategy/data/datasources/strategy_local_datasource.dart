import 'package:hive/hive.dart';

import '../models/strategy_model.dart';

abstract class StrategyLocalDataSource {
  Future<List<StrategyModel>> getAll();
  Future<StrategyModel?> getById(String id);
  Future<void> save(StrategyModel strategy);
  Future<void> delete(String id);
}

class StrategyLocalDataSourceImpl implements StrategyLocalDataSource {
  final Box<StrategyModel> box;

  StrategyLocalDataSourceImpl({required this.box});

  @override
  Future<List<StrategyModel>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<StrategyModel?> getById(String id) async {
    return box.get(id);
  }

  @override
  Future<void> save(StrategyModel strategy) async {
    await box.put(strategy.id, strategy);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
