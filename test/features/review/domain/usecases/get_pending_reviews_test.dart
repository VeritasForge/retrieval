import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:retrieval/features/review/domain/entities/review_schedule.dart';
import 'package:retrieval/features/review/domain/repositories/review_schedule_repository.dart';
import 'package:retrieval/features/review/domain/usecases/get_today_reviews.dart';

class MockReviewScheduleRepository extends Mock
    implements ReviewScheduleRepository {}

void main() {
  late GetPendingReviews useCase;
  late MockReviewScheduleRepository mockRepository;

  final now = DateTime.now();

  ReviewSchedule createSchedule({
    required String id,
    required DateTime scheduledDate,
    bool isCompleted = false,
    DateTime? completedAt,
  }) {
    return ReviewSchedule(
      id: id,
      taskId: 'task-1',
      scheduledDate: scheduledDate,
      reviewOrder: 0,
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: now,
    );
  }

  setUp(() {
    mockRepository = MockReviewScheduleRepository();
    useCase = GetPendingReviews(repository: mockRepository);

    // Default stub for completedToday
    when(() => mockRepository.getCompletedTodaySchedules())
        .thenAnswer((_) async => []);
  });

  group('GetPendingReviews', () {
    test('overdue + today 합산 (overdue 우선)', () async {
      final overdue1 = createSchedule(
        id: 'overdue-1',
        scheduledDate: now.subtract(const Duration(days: 2)),
      );
      final today1 = createSchedule(
        id: 'today-1',
        scheduledDate: now,
      );

      when(() => mockRepository.getOverdueSchedules())
          .thenAnswer((_) async => [overdue1]);
      when(() => mockRepository.getTodaySchedules())
          .thenAnswer((_) async => [today1]);

      final result = await useCase();

      expect(result, [overdue1, today1]);
      expect(result.first.id, 'overdue-1');
    });

    test('대기 항목 없음 → 빈 리스트', () async {
      when(() => mockRepository.getOverdueSchedules())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getTodaySchedules())
          .thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('overdue만 존재', () async {
      final overdue1 = createSchedule(
        id: 'overdue-1',
        scheduledDate: now.subtract(const Duration(days: 1)),
      );

      when(() => mockRepository.getOverdueSchedules())
          .thenAnswer((_) async => [overdue1]);
      when(() => mockRepository.getTodaySchedules())
          .thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, [overdue1]);
    });

    test('today만 존재', () async {
      final today1 = createSchedule(
        id: 'today-1',
        scheduledDate: now,
      );

      when(() => mockRepository.getOverdueSchedules())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getTodaySchedules())
          .thenAnswer((_) async => [today1]);

      final result = await useCase();

      expect(result, [today1]);
    });

    test('오늘 완료된 과거 스케줄 포함', () async {
      final completedPast = createSchedule(
        id: 'completed-past-1',
        scheduledDate: now.subtract(const Duration(days: 3)),
        isCompleted: true,
        completedAt: now,
      );

      when(() => mockRepository.getOverdueSchedules())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getTodaySchedules())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getCompletedTodaySchedules())
          .thenAnswer((_) async => [completedPast]);

      final result = await useCase();

      expect(result.length, 1);
      expect(result.first.id, 'completed-past-1');
      expect(result.first.isCompleted, true);
    });

    test('오늘 완료된 스케줄 중복 제거 (today와 completedToday 겹침)', () async {
      final todayCompleted = createSchedule(
        id: 'today-completed-1',
        scheduledDate: now,
        isCompleted: true,
        completedAt: now,
      );

      when(() => mockRepository.getOverdueSchedules())
          .thenAnswer((_) async => []);
      when(() => mockRepository.getTodaySchedules())
          .thenAnswer((_) async => [todayCompleted]);
      when(() => mockRepository.getCompletedTodaySchedules())
          .thenAnswer((_) async => [todayCompleted]);

      final result = await useCase();

      expect(result.length, 1);
      expect(result.first.id, 'today-completed-1');
    });
  });
}
