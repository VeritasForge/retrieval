import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import 'package:retrieval/core/utils/date_utils.dart';
import 'package:retrieval/features/review/domain/entities/review_schedule.dart';
import 'package:retrieval/features/review/domain/repositories/review_schedule_repository.dart';
import 'package:retrieval/features/review/domain/usecases/create_review_schedules.dart';
import 'package:retrieval/features/strategy/domain/entities/strategy.dart';
import 'package:retrieval/features/task/domain/entities/task.dart';

class MockReviewScheduleRepository extends Mock
    implements ReviewScheduleRepository {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late CreateNextReviewSchedule useCase;
  late MockReviewScheduleRepository mockRepository;
  late MockUuid mockUuid;

  final today = AppDateUtils.today();

  final strategy1371 = Strategy(
    id: 'strategy-1',
    name: '1-3-7-14',
    intervals: [1, 3, 7, 14],
    isDefault: true,
    createdAt: today,
  );

  final strategy2357 = Strategy(
    id: 'strategy-2',
    name: '2-3-5-7',
    intervals: [2, 3, 5, 7],
    isDefault: false,
    createdAt: today,
  );

  Task createTask({int level = 0, DateTime? studyDate}) {
    final date = studyDate ?? today;
    return Task(
      id: 'task-1',
      categoryId: 'cat-1',
      strategyId: 'strategy-1',
      subtasks: const [],
      level: level,
      history: const [],
      studyDate: date,
      createdAt: date,
    );
  }

  setUpAll(() {
    registerFallbackValue(ReviewSchedule.create(
      id: 'fallback',
      taskId: 'fallback',
      scheduledDate: today,
      reviewOrder: 0,
    ));
  });

  setUp(() {
    mockRepository = MockReviewScheduleRepository();
    mockUuid = MockUuid();
    useCase = CreateNextReviewSchedule(
      repository: mockRepository,
      uuid: mockUuid,
    );

    when(() => mockUuid.v4()).thenReturn('generated-uuid');
    when(() => mockRepository.create(any()))
        .thenAnswer((inv) async => inv.positionalArguments[0] as ReviewSchedule);
  });

  group('CreateNextReviewSchedule', () {
    test('level 0 → studyDate+intervals[0] 스케줄 생성', () async {
      final task = createTask(level: 0);

      final result = await useCase(task, strategy1371);

      final expectedDate = AppDateUtils.addDays(today, 1);
      expect(result.scheduledDate, expectedDate);
      expect(result.reviewOrder, 0);
    });

    test('level 2 → studyDate+intervals[2] 스케줄 생성', () async {
      final task = createTask(level: 2);

      final result = await useCase(task, strategy1371);

      final expectedDate = AppDateUtils.addDays(today, 7);
      expect(result.scheduledDate, expectedDate);
      expect(result.reviewOrder, 2);
    });

    test('다른 전략 [2,3,5,7]에서도 동작', () async {
      final task = createTask(level: 1);

      final result = await useCase(task, strategy2357);

      final expectedDate = AppDateUtils.addDays(today, 3);
      expect(result.scheduledDate, expectedDate);
      expect(result.reviewOrder, 1);
    });

    test('studyDate+interval이 과거인 경우 → today 이후로 보정', () async {
      final oldStudyDate = DateTime(2020, 1, 1);
      final task = createTask(level: 0, studyDate: oldStudyDate);

      final result = await useCase(task, strategy1371);

      expect(
        result.scheduledDate.isAfter(today) ||
            result.scheduledDate.isAtSameMomentAs(today),
        isTrue,
      );
    });

    test('repository.create 호출 및 반환값 확인', () async {
      final task = createTask(level: 0);

      final result = await useCase(task, strategy1371);

      verify(() => mockRepository.create(any())).called(1);
      expect(result.id, 'generated-uuid');
      expect(result.taskId, 'task-1');
      expect(result.isCompleted, isFalse);
    });
  });
}
