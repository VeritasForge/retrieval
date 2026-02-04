import '../../domain/entities/review_schedule.dart';
import '../../domain/repositories/review_schedule_repository.dart';
import '../datasources/review_schedule_local_datasource.dart';
import '../models/review_schedule_model.dart';

class ReviewScheduleRepositoryImpl implements ReviewScheduleRepository {
  final ReviewScheduleLocalDataSource localDataSource;

  ReviewScheduleRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ReviewSchedule>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ReviewSchedule?> getById(String id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<ReviewSchedule>> getByStudyItemId(String studyItemId) async {
    final models = await localDataSource.getByStudyItemId(studyItemId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ReviewSchedule>> getByDate(DateTime date) async {
    final models = await localDataSource.getByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ReviewSchedule>> getByDateRange(
      DateTime start, DateTime end) async {
    final models = await localDataSource.getByDateRange(start, end);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ReviewSchedule>> getTodaySchedules() async {
    final models = await localDataSource.getTodaySchedules();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ReviewSchedule>> getOverdueSchedules() async {
    final models = await localDataSource.getOverdueSchedules();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ReviewSchedule> create(ReviewSchedule schedule) async {
    final model = ReviewScheduleModel.fromEntity(schedule);
    await localDataSource.save(model);
    return schedule;
  }

  @override
  Future<List<ReviewSchedule>> createMany(List<ReviewSchedule> schedules) async {
    final models = schedules.map((s) => ReviewScheduleModel.fromEntity(s)).toList();
    await localDataSource.saveMany(models);
    return schedules;
  }

  @override
  Future<ReviewSchedule> update(ReviewSchedule schedule) async {
    final model = ReviewScheduleModel.fromEntity(schedule);
    await localDataSource.save(model);
    return schedule;
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }

  @override
  Future<void> deleteByStudyItemId(String studyItemId) async {
    await localDataSource.deleteByStudyItemId(studyItemId);
  }
}
