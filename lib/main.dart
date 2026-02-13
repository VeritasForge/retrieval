import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';
import 'core/constants/default_categories.dart';
import 'features/category/data/models/category_model_v2.dart';
import 'features/category/domain/entities/category.dart';
import 'features/category/presentation/providers/category_provider.dart';
import 'features/review/data/models/review_schedule_model_v2.dart';
import 'features/review/presentation/providers/review_provider.dart';
import 'features/strategy/data/models/strategy_model.dart';
import 'features/strategy/presentation/providers/strategy_provider.dart';
import 'features/strategy/domain/usecases/seed_default_strategies.dart';
import 'features/strategy/data/datasources/strategy_local_datasource.dart';
import 'features/strategy/data/repositories/strategy_repository_impl.dart';
import 'features/task/data/models/subtask_model.dart';
import 'features/task/data/models/task_model.dart';
import 'features/task/presentation/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');

  // Hive 초기화
  await Hive.initFlutter();

  // 새 Hive 어댑터 등록
  Hive.registerAdapter(CategoryModelV2Adapter());
  Hive.registerAdapter(StrategyModelAdapter());
  Hive.registerAdapter(SubtaskModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(ReviewScheduleModelV2Adapter());

  // 새 Hive 박스 열기
  final categoryBox = await Hive.openBox<CategoryModelV2>('categories_v2');
  final strategyBox = await Hive.openBox<StrategyModel>('strategies');
  final taskBox = await Hive.openBox<TaskModel>('tasks');
  final reviewScheduleBox =
      await Hive.openBox<ReviewScheduleModelV2>('review_schedules_v2');

  // 기존 박스 삭제 시도
  try {
    await Hive.deleteBoxFromDisk('categories');
  } catch (_) {}
  try {
    await Hive.deleteBoxFromDisk('study_items');
  } catch (_) {}
  try {
    await Hive.deleteBoxFromDisk('review_schedules');
  } catch (_) {}

  // 기본 전략 시딩
  final strategyDataSource =
      StrategyLocalDataSourceImpl(box: strategyBox);
  final strategyRepository =
      StrategyRepositoryImpl(localDataSource: strategyDataSource);
  final seedStrategies =
      SeedDefaultStrategies(repository: strategyRepository);
  await seedStrategies();

  // 기본 카테고리 시딩
  if (categoryBox.isEmpty) {
    const uuid = Uuid();
    for (var i = 0; i < DefaultCategory.defaults.length; i++) {
      final dc = DefaultCategory.defaults[i];
      final category = Category.create(
        id: uuid.v4(),
        name: dc.name,
        iconName: dc.iconName,
        colorHex: dc.colorHex,
        isDefault: true,
        order: i,
      );
      final model = CategoryModelV2.fromEntity(category);
      await categoryBox.put(model.id, model);
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        categoryBoxProvider.overrideWithValue(categoryBox),
        strategyBoxProvider.overrideWithValue(strategyBox),
        taskBoxProvider.overrideWithValue(taskBox),
        reviewScheduleBoxProvider.overrideWithValue(reviewScheduleBox),
      ],
      child: const RetrievalApp(),
    ),
  );
}
