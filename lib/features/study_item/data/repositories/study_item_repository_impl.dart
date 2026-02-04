import '../../domain/entities/study_item.dart';
import '../../domain/repositories/study_item_repository.dart';
import '../datasources/study_item_local_datasource.dart';
import '../models/study_item_model.dart';

class StudyItemRepositoryImpl implements StudyItemRepository {
  final StudyItemLocalDataSource localDataSource;

  StudyItemRepositoryImpl({required this.localDataSource});

  @override
  Future<List<StudyItem>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<StudyItem?> getById(String id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<StudyItem>> getByCategoryId(String categoryId) async {
    final models = await localDataSource.getByCategoryId(categoryId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<StudyItem>> getBySubCategoryId(String subCategoryId) async {
    final models = await localDataSource.getBySubCategoryId(subCategoryId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<StudyItem>> getByStudyDate(DateTime date) async {
    final models = await localDataSource.getByStudyDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<StudyItem> create(StudyItem studyItem) async {
    final model = StudyItemModel.fromEntity(studyItem);
    await localDataSource.save(model);
    return studyItem;
  }

  @override
  Future<StudyItem> update(StudyItem studyItem) async {
    final model = StudyItemModel.fromEntity(studyItem);
    await localDataSource.save(model);
    return studyItem;
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }
}
