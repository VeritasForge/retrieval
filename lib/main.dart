import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/category/data/models/category_model.dart';
import 'features/category/data/models/sub_category_model.dart';
import 'features/category/presentation/providers/category_provider.dart';
import 'features/review/data/models/review_schedule_model.dart';
import 'features/review/presentation/providers/review_provider.dart';
import 'features/study_item/data/models/study_item_model.dart';
import 'features/study_item/presentation/providers/study_item_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // Hive 어댑터 등록
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(SubCategoryModelAdapter());
  Hive.registerAdapter(StudyItemModelAdapter());
  Hive.registerAdapter(ReviewScheduleModelAdapter());

  // Hive 박스 열기
  final categoryBox = await Hive.openBox<CategoryModel>('categories');
  final studyItemBox = await Hive.openBox<StudyItemModel>('study_items');
  final reviewScheduleBox =
      await Hive.openBox<ReviewScheduleModel>('review_schedules');

  runApp(
    ProviderScope(
      overrides: [
        categoryBoxProvider.overrideWithValue(categoryBox),
        studyItemBoxProvider.overrideWithValue(studyItemBox),
        reviewScheduleBoxProvider.overrideWithValue(reviewScheduleBox),
      ],
      child: const RetrievalApp(),
    ),
  );
}
