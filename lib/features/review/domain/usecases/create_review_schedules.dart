import 'package:uuid/uuid.dart';

import 'package:retrieval/core/utils/date_utils.dart';
import 'package:retrieval/features/strategy/domain/entities/strategy.dart';
import 'package:retrieval/features/task/domain/entities/task.dart';
import '../entities/review_schedule.dart';
import '../repositories/review_schedule_repository.dart';

/// 다음 복습 일정 생성 유스케이스
class CreateNextReviewSchedule {
  final ReviewScheduleRepository repository;
  final Uuid uuid;

  CreateNextReviewSchedule({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// 태스크의 현재 레벨에 기반하여 다음 복습 일정 생성
  Future<ReviewSchedule> call(Task task, Strategy strategy) async {
    final studyBasedDate = AppDateUtils.addDays(
      task.studyDate,
      strategy.intervals[task.level],
    );
    final today = AppDateUtils.today();
    final scheduledDate =
        studyBasedDate.isBefore(today) ? today : studyBasedDate;

    final schedule = ReviewSchedule.create(
      id: uuid.v4(),
      taskId: task.id,
      scheduledDate: scheduledDate,
      reviewOrder: task.level,
    );

    return repository.create(schedule);
  }
}
