import 'package:hive/hive.dart';

import 'package:retrieval/core/utils/date_utils.dart';
import '../models/review_schedule_model_v2.dart';

abstract class ReviewScheduleLocalDataSource {
  Future<List<ReviewScheduleModelV2>> getAll();
  Future<ReviewScheduleModelV2?> getById(String id);
  Future<List<ReviewScheduleModelV2>> getByTaskId(String taskId);
  Future<List<ReviewScheduleModelV2>> getByDate(DateTime date);
  Future<List<ReviewScheduleModelV2>> getByDateRange(
      DateTime start, DateTime end);
  Future<List<ReviewScheduleModelV2>> getTodaySchedules();
  Future<List<ReviewScheduleModelV2>> getOverdueSchedules();
  Future<List<ReviewScheduleModelV2>> getCompletedTodaySchedules();
  Future<void> save(ReviewScheduleModelV2 schedule);
  Future<void> saveMany(List<ReviewScheduleModelV2> schedules);
  Future<void> delete(String id);
  Future<void> deleteByTaskId(String taskId);
}

class ReviewScheduleLocalDataSourceImpl
    implements ReviewScheduleLocalDataSource {
  final Box<ReviewScheduleModelV2> box;

  ReviewScheduleLocalDataSourceImpl({required this.box});

  @override
  Future<List<ReviewScheduleModelV2>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<ReviewScheduleModelV2?> getById(String id) async {
    return box.get(id);
  }

  @override
  Future<List<ReviewScheduleModelV2>> getByTaskId(String taskId) async {
    return box.values
        .where((schedule) => schedule.taskId == taskId)
        .toList();
  }

  @override
  Future<List<ReviewScheduleModelV2>> getByDate(DateTime date) async {
    return box.values
        .where((schedule) => AppDateUtils.isSameDay(schedule.scheduledDate, date))
        .toList();
  }

  @override
  Future<List<ReviewScheduleModelV2>> getByDateRange(
      DateTime start, DateTime end) async {
    final startDate = AppDateUtils.startOfDay(start);
    final endDate = AppDateUtils.endOfDay(end);

    return box.values.where((schedule) {
      return !schedule.scheduledDate.isBefore(startDate) &&
          !schedule.scheduledDate.isAfter(endDate);
    }).toList();
  }

  @override
  Future<List<ReviewScheduleModelV2>> getTodaySchedules() async {
    return getByDate(DateTime.now());
  }

  @override
  Future<List<ReviewScheduleModelV2>> getOverdueSchedules() async {
    final today = AppDateUtils.today();

    return box.values.where((schedule) {
      return AppDateUtils.startOfDay(schedule.scheduledDate).isBefore(today) &&
          !schedule.isCompleted;
    }).toList();
  }

  @override
  Future<List<ReviewScheduleModelV2>> getCompletedTodaySchedules() async {
    final now = DateTime.now();

    return box.values.where((schedule) {
      return schedule.isCompleted &&
          schedule.completedAt != null &&
          AppDateUtils.isSameDay(schedule.completedAt!, now);
    }).toList();
  }

  @override
  Future<void> save(ReviewScheduleModelV2 schedule) async {
    await box.put(schedule.id, schedule);
  }

  @override
  Future<void> saveMany(List<ReviewScheduleModelV2> schedules) async {
    final entries = {for (var s in schedules) s.id: s};
    await box.putAll(entries);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }

  @override
  Future<void> deleteByTaskId(String taskId) async {
    final toDelete =
        box.values.where((s) => s.taskId == taskId).toList();
    for (var schedule in toDelete) {
      await box.delete(schedule.id);
    }
  }
}
