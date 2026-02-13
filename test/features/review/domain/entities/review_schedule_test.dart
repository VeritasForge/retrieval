import 'package:flutter_test/flutter_test.dart';
import 'package:retrieval/features/review/domain/entities/review_schedule.dart';

void main() {
  group('ReviewSchedule', () {
    test('create should create a new schedule with isCompleted false', () {
      final schedule = ReviewSchedule.create(
        id: 'schedule-1',
        taskId: 'task-1',
        scheduledDate: DateTime(2024, 1, 16),
        reviewOrder: 1,
      );

      expect(schedule.id, 'schedule-1');
      expect(schedule.taskId, 'task-1');
      expect(schedule.scheduledDate, DateTime(2024, 1, 16));
      expect(schedule.reviewOrder, 1);
      expect(schedule.isCompleted, isFalse);
      expect(schedule.completedAt, isNull);
    });

    test('complete should mark schedule as completed', () {
      final schedule = ReviewSchedule.create(
        id: 'schedule-1',
        taskId: 'task-1',
        scheduledDate: DateTime(2024, 1, 16),
        reviewOrder: 1,
      );

      final completed = schedule.complete();

      expect(completed.isCompleted, isTrue);
      expect(completed.completedAt, isNotNull);
    });

    test('uncomplete should mark schedule as not completed', () {
      final schedule = ReviewSchedule(
        id: 'schedule-1',
        taskId: 'task-1',
        scheduledDate: DateTime(2024, 1, 16),
        reviewOrder: 1,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final uncompleted = schedule.uncomplete();

      expect(uncompleted.isCompleted, isFalse);
      expect(uncompleted.completedAt, isNull);
    });

    test('equality should work correctly', () {
      final now = DateTime.now();
      final schedule1 = ReviewSchedule(
        id: 'schedule-1',
        taskId: 'task-1',
        scheduledDate: DateTime(2024, 1, 16),
        reviewOrder: 1,
        isCompleted: false,
        completedAt: null,
        createdAt: now,
      );
      final schedule2 = ReviewSchedule(
        id: 'schedule-1',
        taskId: 'task-1',
        scheduledDate: DateTime(2024, 1, 16),
        reviewOrder: 1,
        isCompleted: false,
        completedAt: null,
        createdAt: now,
      );

      expect(schedule1, equals(schedule2));
    });
  });
}
