import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:retrieval/core/constants/review_cycles.dart';
import '../../../review/domain/usecases/create_review_schedules.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../data/datasources/study_item_local_datasource.dart';
import '../../data/models/study_item_model.dart';
import '../../data/repositories/study_item_repository_impl.dart';
import '../../domain/entities/study_item.dart';
import '../../domain/repositories/study_item_repository.dart';
import '../../domain/usecases/create_study_item.dart';
import '../../domain/usecases/delete_study_item.dart';
import '../../domain/usecases/get_study_items.dart';

/// Hive Box Provider
final studyItemBoxProvider = Provider<Box<StudyItemModel>>((ref) {
  throw UnimplementedError('studyItemBoxProvider must be overridden');
});

/// DataSource Provider
final studyItemLocalDataSourceProvider =
    Provider<StudyItemLocalDataSource>((ref) {
  final box = ref.watch(studyItemBoxProvider);
  return StudyItemLocalDataSourceImpl(box: box);
});

/// Repository Provider
final studyItemRepositoryProvider = Provider<StudyItemRepository>((ref) {
  final dataSource = ref.watch(studyItemLocalDataSourceProvider);
  return StudyItemRepositoryImpl(localDataSource: dataSource);
});

/// UseCase Providers
final createStudyItemUseCaseProvider = Provider<CreateStudyItem>((ref) {
  final repository = ref.watch(studyItemRepositoryProvider);
  return CreateStudyItem(repository: repository);
});

final getStudyItemsUseCaseProvider = Provider<GetStudyItems>((ref) {
  final repository = ref.watch(studyItemRepositoryProvider);
  return GetStudyItems(repository: repository);
});

final deleteStudyItemUseCaseProvider = Provider<DeleteStudyItem>((ref) {
  final repository = ref.watch(studyItemRepositoryProvider);
  return DeleteStudyItem(repository: repository);
});

/// Study Item List State
class StudyItemListNotifier
    extends StateNotifier<AsyncValue<List<StudyItem>>> {
  final GetStudyItems getStudyItems;
  final CreateStudyItem createStudyItem;
  final DeleteStudyItem deleteStudyItem;
  final CreateReviewSchedules createReviewSchedules;

  StudyItemListNotifier({
    required this.getStudyItems,
    required this.createStudyItem,
    required this.deleteStudyItem,
    required this.createReviewSchedules,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final items = await getStudyItems();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add({
    required String categoryId,
    String? subCategoryId,
    required String content,
    required bool isCheckbox,
    required DateTime studyDate,
    required ReviewCycle reviewCycle,
  }) async {
    try {
      final item = await createStudyItem(CreateStudyItemParams(
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        content: content,
        isCheckbox: isCheckbox,
        studyDate: studyDate,
        reviewCycle: reviewCycle,
      ));

      // 복습 일정 자동 생성
      await createReviewSchedules(item);

      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String id) async {
    try {
      await deleteStudyItem(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final studyItemListProvider =
    StateNotifierProvider<StudyItemListNotifier, AsyncValue<List<StudyItem>>>(
        (ref) {
  return StudyItemListNotifier(
    getStudyItems: ref.watch(getStudyItemsUseCaseProvider),
    createStudyItem: ref.watch(createStudyItemUseCaseProvider),
    deleteStudyItem: ref.watch(deleteStudyItemUseCaseProvider),
    createReviewSchedules: ref.watch(createReviewSchedulesUseCaseProvider),
  );
});
