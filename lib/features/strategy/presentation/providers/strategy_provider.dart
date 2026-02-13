import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/strategy_local_datasource.dart';
import '../../data/models/strategy_model.dart';
import '../../data/repositories/strategy_repository_impl.dart';
import '../../domain/entities/strategy.dart';
import '../../domain/repositories/strategy_repository.dart';
import '../../domain/usecases/create_strategy.dart';
import '../../domain/usecases/delete_strategy.dart';
import '../../domain/usecases/get_strategies.dart';
import '../../domain/usecases/seed_default_strategies.dart';
import '../../domain/usecases/update_strategy.dart';

/// Hive Box Provider
final strategyBoxProvider = Provider<Box<StrategyModel>>((ref) {
  throw UnimplementedError('strategyBoxProvider must be overridden');
});

/// DataSource Provider
final strategyLocalDataSourceProvider =
    Provider<StrategyLocalDataSource>((ref) {
  final box = ref.watch(strategyBoxProvider);
  return StrategyLocalDataSourceImpl(box: box);
});

/// Repository Provider
final strategyRepositoryProvider = Provider<StrategyRepository>((ref) {
  final dataSource = ref.watch(strategyLocalDataSourceProvider);
  return StrategyRepositoryImpl(localDataSource: dataSource);
});

/// UseCase Providers
final createStrategyUseCaseProvider = Provider<CreateStrategy>((ref) {
  final repository = ref.watch(strategyRepositoryProvider);
  return CreateStrategy(repository: repository);
});

final getStrategiesUseCaseProvider = Provider<GetStrategies>((ref) {
  final repository = ref.watch(strategyRepositoryProvider);
  return GetStrategies(repository: repository);
});

final updateStrategyUseCaseProvider = Provider<UpdateStrategy>((ref) {
  final repository = ref.watch(strategyRepositoryProvider);
  return UpdateStrategy(repository: repository);
});

final deleteStrategyUseCaseProvider = Provider<DeleteStrategy>((ref) {
  final repository = ref.watch(strategyRepositoryProvider);
  return DeleteStrategy(repository: repository);
});

final seedDefaultStrategiesUseCaseProvider =
    Provider<SeedDefaultStrategies>((ref) {
  final repository = ref.watch(strategyRepositoryProvider);
  return SeedDefaultStrategies(repository: repository);
});

/// Strategy List State
class StrategyListNotifier
    extends StateNotifier<AsyncValue<List<Strategy>>> {
  final GetStrategies getStrategies;
  final CreateStrategy createStrategy;
  final UpdateStrategy updateStrategy;
  final DeleteStrategy deleteStrategy;

  StrategyListNotifier({
    required this.getStrategies,
    required this.createStrategy,
    required this.updateStrategy,
    required this.deleteStrategy,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final strategies = await getStrategies();
      state = AsyncValue.data(strategies);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(String name, List<int> intervals) async {
    try {
      await createStrategy(name, intervals);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Strategy strategy) async {
    try {
      await updateStrategy(strategy);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String id) async {
    try {
      await deleteStrategy(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final strategyListProvider =
    StateNotifierProvider<StrategyListNotifier, AsyncValue<List<Strategy>>>(
        (ref) {
  return StrategyListNotifier(
    getStrategies: ref.watch(getStrategiesUseCaseProvider),
    createStrategy: ref.watch(createStrategyUseCaseProvider),
    updateStrategy: ref.watch(updateStrategyUseCaseProvider),
    deleteStrategy: ref.watch(deleteStrategyUseCaseProvider),
  );
});
