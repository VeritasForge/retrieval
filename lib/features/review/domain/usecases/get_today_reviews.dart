import '../entities/review_schedule.dart';
import '../repositories/review_schedule_repository.dart';

/// 오늘 복습 일정 조회 유스케이스
class GetTodayReviews {
  final ReviewScheduleRepository repository;

  GetTodayReviews({required this.repository});

  Future<List<ReviewSchedule>> call() async {
    return repository.getTodaySchedules();
  }
}

/// 미완료 복습 일정 조회 유스케이스 (오늘 + 이전)
class GetPendingReviews {
  final ReviewScheduleRepository repository;

  GetPendingReviews({required this.repository});

  Future<List<ReviewSchedule>> call() async {
    final today = await repository.getTodaySchedules();
    final overdue = await repository.getOverdueSchedules();
    return [...overdue, ...today];
  }
}
