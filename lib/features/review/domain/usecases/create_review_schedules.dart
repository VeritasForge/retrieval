import 'package:uuid/uuid.dart';

import 'package:retrieval/core/utils/date_utils.dart';
import 'package:retrieval/features/study_item/domain/entities/study_item.dart';
import '../entities/review_schedule.dart';
import '../repositories/review_schedule_repository.dart';

/// 학습 항목에 대한 복습 일정 생성 유스케이스
class CreateReviewSchedules {
  final ReviewScheduleRepository repository;
  final Uuid uuid;

  CreateReviewSchedules({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// 학습 항목에 대해 복습 주기에 따른 모든 복습 일정 생성
  Future<List<ReviewSchedule>> call(StudyItem studyItem) async {
    final schedules = <ReviewSchedule>[];
    final baseDate = AppDateUtils.startOfDay(studyItem.studyDate);

    int cumulativeDays = 0;
    for (int i = 0; i < studyItem.reviewCycle.intervals.length; i++) {
      cumulativeDays += studyItem.reviewCycle.intervals[i];

      final schedule = ReviewSchedule.create(
        id: uuid.v4(),
        studyItemId: studyItem.id,
        scheduledDate: AppDateUtils.addDays(baseDate, cumulativeDays),
        reviewOrder: i + 1,
      );
      schedules.add(schedule);
    }

    return repository.createMany(schedules);
  }
}
