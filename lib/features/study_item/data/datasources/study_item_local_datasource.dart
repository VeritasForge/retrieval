import 'package:hive/hive.dart';

import 'package:retrieval/core/utils/date_utils.dart';
import '../models/study_item_model.dart';

abstract class StudyItemLocalDataSource {
  Future<List<StudyItemModel>> getAll();
  Future<StudyItemModel?> getById(String id);
  Future<List<StudyItemModel>> getByCategoryId(String categoryId);
  Future<List<StudyItemModel>> getBySubCategoryId(String subCategoryId);
  Future<List<StudyItemModel>> getByStudyDate(DateTime date);
  Future<void> save(StudyItemModel studyItem);
  Future<void> delete(String id);
}

class StudyItemLocalDataSourceImpl implements StudyItemLocalDataSource {
  final Box<StudyItemModel> box;

  StudyItemLocalDataSourceImpl({required this.box});

  @override
  Future<List<StudyItemModel>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<StudyItemModel?> getById(String id) async {
    return box.get(id);
  }

  @override
  Future<List<StudyItemModel>> getByCategoryId(String categoryId) async {
    return box.values.where((item) => item.categoryId == categoryId).toList();
  }

  @override
  Future<List<StudyItemModel>> getBySubCategoryId(String subCategoryId) async {
    return box.values
        .where((item) => item.subCategoryId == subCategoryId)
        .toList();
  }

  @override
  Future<List<StudyItemModel>> getByStudyDate(DateTime date) async {
    return box.values
        .where((item) => AppDateUtils.isSameDay(item.studyDate, date))
        .toList();
  }

  @override
  Future<void> save(StudyItemModel studyItem) async {
    await box.put(studyItem.id, studyItem);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
