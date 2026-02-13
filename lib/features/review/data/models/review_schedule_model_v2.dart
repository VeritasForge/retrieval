import 'package:hive/hive.dart';

import '../../domain/entities/review_schedule.dart';

part 'review_schedule_model_v2.g.dart';

@HiveType(typeId: 8)
class ReviewScheduleModelV2 extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final DateTime scheduledDate;

  @HiveField(3)
  final int reviewOrder;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final DateTime? completedAt;

  @HiveField(6)
  final DateTime createdAt;

  ReviewScheduleModelV2({
    required this.id,
    required this.taskId,
    required this.scheduledDate,
    required this.reviewOrder,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });

  factory ReviewScheduleModelV2.fromEntity(ReviewSchedule schedule) {
    return ReviewScheduleModelV2(
      id: schedule.id,
      taskId: schedule.taskId,
      scheduledDate: schedule.scheduledDate,
      reviewOrder: schedule.reviewOrder,
      isCompleted: schedule.isCompleted,
      completedAt: schedule.completedAt,
      createdAt: schedule.createdAt,
    );
  }

  ReviewSchedule toEntity() {
    return ReviewSchedule(
      id: id,
      taskId: taskId,
      scheduledDate: scheduledDate,
      reviewOrder: reviewOrder,
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }
}
