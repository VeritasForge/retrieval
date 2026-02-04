import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../entities/review_schedule.dart';
import '../repositories/review_schedule_repository.dart';

/// 복습 완료 유스케이스
class CompleteReview {
  final ReviewScheduleRepository repository;

  CompleteReview({required this.repository});

  Future<ReviewSchedule> call(String scheduleId) async {
    if (scheduleId.isEmpty) {
      throw const ValidationException('복습 일정 ID는 비어있을 수 없습니다.');
    }

    final schedule = await repository.getById(scheduleId);
    if (schedule == null) {
      throw ReviewScheduleException('복습 일정을 찾을 수 없습니다: $scheduleId');
    }

    return repository.update(schedule.complete());
  }
}

/// 복습 미완료 처리 유스케이스
class UncompleteReview {
  final ReviewScheduleRepository repository;

  UncompleteReview({required this.repository});

  Future<ReviewSchedule> call(String scheduleId) async {
    if (scheduleId.isEmpty) {
      throw const ValidationException('복습 일정 ID는 비어있을 수 없습니다.');
    }

    final schedule = await repository.getById(scheduleId);
    if (schedule == null) {
      throw ReviewScheduleException('복습 일정을 찾을 수 없습니다: $scheduleId');
    }

    return repository.update(schedule.uncomplete());
  }
}
