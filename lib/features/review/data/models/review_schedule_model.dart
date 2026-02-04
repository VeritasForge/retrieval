import 'package:hive/hive.dart';

import '../../domain/entities/review_schedule.dart';

part 'review_schedule_model.g.dart';

@HiveType(typeId: 3)
class ReviewScheduleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studyItemId;

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

  ReviewScheduleModel({
    required this.id,
    required this.studyItemId,
    required this.scheduledDate,
    required this.reviewOrder,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });

  factory ReviewScheduleModel.fromEntity(ReviewSchedule schedule) {
    return ReviewScheduleModel(
      id: schedule.id,
      studyItemId: schedule.studyItemId,
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
      studyItemId: studyItemId,
      scheduledDate: scheduledDate,
      reviewOrder: reviewOrder,
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }
}
