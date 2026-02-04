import 'package:hive/hive.dart';

import 'package:retrieval/core/utils/date_utils.dart';
import '../models/review_schedule_model.dart';

abstract class ReviewScheduleLocalDataSource {
  Future<List<ReviewScheduleModel>> getAll();
  Future<ReviewScheduleModel?> getById(String id);
  Future<List<ReviewScheduleModel>> getByStudyItemId(String studyItemId);
  Future<List<ReviewScheduleModel>> getByDate(DateTime date);
  Future<List<ReviewScheduleModel>> getByDateRange(
      DateTime start, DateTime end);
  Future<List<ReviewScheduleModel>> getTodaySchedules();
  Future<List<ReviewScheduleModel>> getOverdueSchedules();
  Future<void> save(ReviewScheduleModel schedule);
  Future<void> saveMany(List<ReviewScheduleModel> schedules);
  Future<void> delete(String id);
  Future<void> deleteByStudyItemId(String studyItemId);
}

class ReviewScheduleLocalDataSourceImpl
    implements ReviewScheduleLocalDataSource {
  final Box<ReviewScheduleModel> box;

  ReviewScheduleLocalDataSourceImpl({required this.box});

  @override
  Future<List<ReviewScheduleModel>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<ReviewScheduleModel?> getById(String id) async {
    return box.get(id);
  }

  @override
  Future<List<ReviewScheduleModel>> getByStudyItemId(String studyItemId) async {
    return box.values
        .where((schedule) => schedule.studyItemId == studyItemId)
        .toList();
  }

  @override
  Future<List<ReviewScheduleModel>> getByDate(DateTime date) async {
    return box.values
        .where((schedule) => AppDateUtils.isSameDay(schedule.scheduledDate, date))
        .toList();
  }

  @override
  Future<List<ReviewScheduleModel>> getByDateRange(
      DateTime start, DateTime end) async {
    final startDate = AppDateUtils.startOfDay(start);
    final endDate = AppDateUtils.endOfDay(end);

    return box.values.where((schedule) {
      return !schedule.scheduledDate.isBefore(startDate) &&
          !schedule.scheduledDate.isAfter(endDate);
    }).toList();
  }

  @override
  Future<List<ReviewScheduleModel>> getTodaySchedules() async {
    return getByDate(DateTime.now());
  }

  @override
  Future<List<ReviewScheduleModel>> getOverdueSchedules() async {
    final today = AppDateUtils.today();

    return box.values.where((schedule) {
      return AppDateUtils.startOfDay(schedule.scheduledDate).isBefore(today) &&
          !schedule.isCompleted;
    }).toList();
  }

  @override
  Future<void> save(ReviewScheduleModel schedule) async {
    await box.put(schedule.id, schedule);
  }

  @override
  Future<void> saveMany(List<ReviewScheduleModel> schedules) async {
    final entries = {for (var s in schedules) s.id: s};
    await box.putAll(entries);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }

  @override
  Future<void> deleteByStudyItemId(String studyItemId) async {
    final toDelete =
        box.values.where((s) => s.studyItemId == studyItemId).toList();
    for (var schedule in toDelete) {
      await box.delete(schedule.id);
    }
  }
}
