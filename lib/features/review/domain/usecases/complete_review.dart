import 'package:uuid/uuid.dart';

import 'package:retrieval/core/exceptions/app_exceptions.dart';
import 'package:retrieval/core/utils/date_utils.dart';
import 'package:retrieval/features/strategy/domain/repositories/strategy_repository.dart';
import 'package:retrieval/features/task/domain/repositories/task_repository.dart';
import '../entities/review_schedule.dart';
import '../repositories/review_schedule_repository.dart';

/// 복습 완료 유스케이스
class CompleteReview {
  final ReviewScheduleRepository repository;
  final TaskRepository taskRepository;
  final StrategyRepository strategyRepository;
  final Uuid uuid;

  CompleteReview({
    required this.repository,
    required this.taskRepository,
    required this.strategyRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<ReviewSchedule> call(String scheduleId) async {
    if (scheduleId.isEmpty) {
      throw const ValidationException('복습 일정 ID는 비어있을 수 없습니다.');
    }

    // 1) 스케줄 완료 처리
    final schedule = await repository.getById(scheduleId);
    if (schedule == null) {
      throw ReviewScheduleException('복습 일정을 찾을 수 없습니다: $scheduleId');
    }

    final completedSchedule = schedule.complete();
    await repository.update(completedSchedule);

    // 2) 태스크 레벨 업 + 서브태스크 리셋
    final task = await taskRepository.getById(schedule.taskId);
    if (task == null) {
      throw TaskException('태스크를 찾을 수 없습니다: ${schedule.taskId}');
    }

    final currentLevel = task.level;
    final updatedTask = task.advanceLevel().resetSubtasks();
    await taskRepository.update(updatedTask);

    // 3) 전략 로드
    final strategy = await strategyRepository.getById(task.strategyId);
    if (strategy == null) {
      throw StrategyException('전략을 찾을 수 없습니다: ${task.strategyId}');
    }

    // 4) 다음 레벨이 전략 범위 내이면 다음 스케줄 생성
    if (currentLevel + 1 < strategy.intervals.length) {
      final studyBasedDate = AppDateUtils.addDays(
        task.studyDate,
        strategy.intervals[currentLevel + 1],
      );
      final today = AppDateUtils.today();
      final nextScheduledDate =
          studyBasedDate.isBefore(today) ? today : studyBasedDate;

      final nextSchedule = ReviewSchedule.create(
        id: uuid.v4(),
        taskId: task.id,
        scheduledDate: nextScheduledDate,
        reviewOrder: currentLevel + 1,
      );

      await repository.create(nextSchedule);
    }

    return completedSchedule;
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
