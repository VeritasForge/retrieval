import 'package:equatable/equatable.dart';

/// 복습 일정 엔티티
class ReviewSchedule extends Equatable {
  final String id;
  final String taskId;
  final DateTime scheduledDate;
  final int reviewOrder;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  const ReviewSchedule({
    required this.id,
    required this.taskId,
    required this.scheduledDate,
    required this.reviewOrder,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });

  /// 새 복습 일정 생성
  factory ReviewSchedule.create({
    required String id,
    required String taskId,
    required DateTime scheduledDate,
    required int reviewOrder,
    DateTime? createdAt,
  }) {
    return ReviewSchedule(
      id: id,
      taskId: taskId,
      scheduledDate: scheduledDate,
      reviewOrder: reviewOrder,
      isCompleted: false,
      completedAt: null,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// 복습 일정 복사 (변경 가능)
  ReviewSchedule copyWith({
    String? id,
    String? taskId,
    DateTime? scheduledDate,
    int? reviewOrder,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return ReviewSchedule(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      reviewOrder: reviewOrder ?? this.reviewOrder,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 복습 완료 처리
  ReviewSchedule complete() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// 복습 미완료 처리
  ReviewSchedule uncomplete() {
    return ReviewSchedule(
      id: id,
      taskId: taskId,
      scheduledDate: scheduledDate,
      reviewOrder: reviewOrder,
      isCompleted: false,
      completedAt: null,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        scheduledDate,
        reviewOrder,
        isCompleted,
        completedAt,
        createdAt,
      ];
}
