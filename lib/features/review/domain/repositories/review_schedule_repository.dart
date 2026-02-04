import '../entities/review_schedule.dart';

/// 복습 일정 저장소 인터페이스
abstract class ReviewScheduleRepository {
  /// 모든 복습 일정 조회
  Future<List<ReviewSchedule>> getAll();

  /// ID로 복습 일정 조회
  Future<ReviewSchedule?> getById(String id);

  /// 학습 항목별 복습 일정 조회
  Future<List<ReviewSchedule>> getByStudyItemId(String studyItemId);

  /// 특정 날짜의 복습 일정 조회
  Future<List<ReviewSchedule>> getByDate(DateTime date);

  /// 특정 날짜 범위의 복습 일정 조회
  Future<List<ReviewSchedule>> getByDateRange(DateTime start, DateTime end);

  /// 오늘 복습 일정 조회
  Future<List<ReviewSchedule>> getTodaySchedules();

  /// 미완료 복습 일정 조회 (오늘 이전)
  Future<List<ReviewSchedule>> getOverdueSchedules();

  /// 복습 일정 생성
  Future<ReviewSchedule> create(ReviewSchedule schedule);

  /// 복습 일정 여러 개 생성
  Future<List<ReviewSchedule>> createMany(List<ReviewSchedule> schedules);

  /// 복습 일정 수정
  Future<ReviewSchedule> update(ReviewSchedule schedule);

  /// 복습 일정 삭제
  Future<void> delete(String id);

  /// 학습 항목의 모든 복습 일정 삭제
  Future<void> deleteByStudyItemId(String studyItemId);
}
