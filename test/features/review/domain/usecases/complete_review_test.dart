import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import 'package:retrieval/core/exceptions/app_exceptions.dart';
import 'package:retrieval/core/utils/date_utils.dart';
import 'package:retrieval/features/review/domain/entities/review_schedule.dart';
import 'package:retrieval/features/review/domain/repositories/review_schedule_repository.dart';
import 'package:retrieval/features/review/domain/usecases/complete_review.dart';
import 'package:retrieval/features/strategy/domain/entities/strategy.dart';
import 'package:retrieval/features/strategy/domain/repositories/strategy_repository.dart';
import 'package:retrieval/features/task/domain/entities/subtask.dart';
import 'package:retrieval/features/task/domain/entities/task.dart';
import 'package:retrieval/features/task/domain/repositories/task_repository.dart';

class MockReviewScheduleRepository extends Mock
    implements ReviewScheduleRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockStrategyRepository extends Mock implements StrategyRepository {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late CompleteReview useCase;
  late MockReviewScheduleRepository mockRepository;
  late MockTaskRepository mockTaskRepository;
  late MockStrategyRepository mockStrategyRepository;
  late MockUuid mockUuid;

  final today = AppDateUtils.today();
  final testStrategy = Strategy(
    id: 'strategy-1',
    name: '1-3-7-14',
    intervals: [1, 3, 7, 14],
    isDefault: true,
    createdAt: today,
  );

  ReviewSchedule createSchedule({
    String id = 'schedule-1',
    String taskId = 'task-1',
    int reviewOrder = 0,
  }) {
    return ReviewSchedule.create(
      id: id,
      taskId: taskId,
      scheduledDate: today,
      reviewOrder: reviewOrder,
      createdAt: today,
    );
  }

  Task createTask({
    String id = 'task-1',
    int level = 0,
    List<Subtask>? subtasks,
    DateTime? studyDate,
  }) {
    final date = studyDate ?? today;
    return Task(
      id: id,
      categoryId: 'cat-1',
      strategyId: 'strategy-1',
      subtasks: subtasks ??
          const [
            Subtask(id: 'sub-1', title: '서브태스크 1', isCompleted: true),
            Subtask(id: 'sub-2', title: '서브태스크 2', isCompleted: true),
          ],
      level: level,
      history: const [],
      studyDate: date,
      createdAt: date,
    );
  }

  void stubHappyPath({int taskLevel = 0, DateTime? studyDate}) {
    final schedule = createSchedule();
    final task = createTask(level: taskLevel, studyDate: studyDate);

    when(() => mockRepository.getById('schedule-1'))
        .thenAnswer((_) async => schedule);
    when(() => mockRepository.update(any()))
        .thenAnswer((inv) async => inv.positionalArguments[0] as ReviewSchedule);
    when(() => mockRepository.create(any()))
        .thenAnswer((inv) async => inv.positionalArguments[0] as ReviewSchedule);
    when(() => mockTaskRepository.getById('task-1'))
        .thenAnswer((_) async => task);
    when(() => mockTaskRepository.update(any()))
        .thenAnswer((inv) async => inv.positionalArguments[0] as Task);
    when(() => mockStrategyRepository.getById('strategy-1'))
        .thenAnswer((_) async => testStrategy);
    when(() => mockUuid.v4()).thenReturn('generated-uuid');
  }

  setUpAll(() {
    registerFallbackValue(createSchedule());
    registerFallbackValue(createTask());
  });

  setUp(() {
    mockRepository = MockReviewScheduleRepository();
    mockTaskRepository = MockTaskRepository();
    mockStrategyRepository = MockStrategyRepository();
    mockUuid = MockUuid();
    useCase = CompleteReview(
      repository: mockRepository,
      taskRepository: mockTaskRepository,
      strategyRepository: mockStrategyRepository,
      uuid: mockUuid,
    );
  });

  group('CompleteReview', () {
    test('스케줄 완료 처리', () async {
      stubHappyPath();

      final result = await useCase('schedule-1');

      expect(result.isCompleted, isTrue);
      verify(() => mockRepository.update(any())).called(1);
    });

    test('태스크 레벨 업 + 서브태스크 리셋', () async {
      stubHappyPath();

      await useCase('schedule-1');

      final captured =
          verify(() => mockTaskRepository.update(captureAny())).captured;
      final updatedTask = captured.first as Task;
      expect(updatedTask.level, 1);
      expect(updatedTask.subtasks.every((s) => !s.isCompleted), isTrue);
    });

    test('level 0 완료 → studyDate+3일 스케줄 생성 (전략 [1,3,7,14])', () async {
      stubHappyPath(taskLevel: 0);

      await useCase('schedule-1');

      final captured =
          verify(() => mockRepository.create(captureAny())).captured;
      final createdSchedule = captured.first as ReviewSchedule;
      final expectedDate = AppDateUtils.addDays(today, 3);
      expect(createdSchedule.scheduledDate, expectedDate);
      expect(createdSchedule.reviewOrder, 1);
    });

    test('level 1 완료 → studyDate+7일 스케줄 생성', () async {
      stubHappyPath(taskLevel: 1);

      await useCase('schedule-1');

      final captured =
          verify(() => mockRepository.create(captureAny())).captured;
      final createdSchedule = captured.first as ReviewSchedule;
      final expectedDate = AppDateUtils.addDays(today, 7);
      expect(createdSchedule.scheduledDate, expectedDate);
      expect(createdSchedule.reviewOrder, 2);
    });

    test('level 2 완료 → studyDate+14일 스케줄 생성', () async {
      stubHappyPath(taskLevel: 2);

      await useCase('schedule-1');

      final captured =
          verify(() => mockRepository.create(captureAny())).captured;
      final createdSchedule = captured.first as ReviewSchedule;
      final expectedDate = AppDateUtils.addDays(today, 14);
      expect(createdSchedule.scheduledDate, expectedDate);
      expect(createdSchedule.reviewOrder, 3);
    });

    test('studyDate+interval이 과거인 경우 → today 이후로 보정', () async {
      // studyDate가 오래 전이라 studyDate+3 이 이미 과거
      final oldStudyDate = DateTime(2020, 1, 1);
      stubHappyPath(taskLevel: 0, studyDate: oldStudyDate);

      await useCase('schedule-1');

      final captured =
          verify(() => mockRepository.create(captureAny())).captured;
      final createdSchedule = captured.first as ReviewSchedule;
      // 과거 날짜가 아닌 today 이후여야 함
      expect(
        createdSchedule.scheduledDate.isAfter(today) ||
            createdSchedule.scheduledDate.isAtSameMomentAs(today),
        isTrue,
      );
    });

    test('level 3 완료 → 스케줄 미생성 (간격 소진)', () async {
      stubHappyPath(taskLevel: 3);

      await useCase('schedule-1');

      verifyNever(() => mockRepository.create(any()));
    });

    test('빈 scheduleId → ValidationException', () async {
      expect(
        () => useCase(''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('스케줄 미발견 → ReviewScheduleException', () async {
      when(() => mockRepository.getById('not-found'))
          .thenAnswer((_) async => null);

      expect(
        () => useCase('not-found'),
        throwsA(isA<ReviewScheduleException>()),
      );
    });

    test('태스크 미발견 → TaskException', () async {
      final schedule = createSchedule();
      when(() => mockRepository.getById('schedule-1'))
          .thenAnswer((_) async => schedule);
      when(() => mockRepository.update(any()))
          .thenAnswer((inv) async => inv.positionalArguments[0] as ReviewSchedule);
      when(() => mockTaskRepository.getById('task-1'))
          .thenAnswer((_) async => null);

      expect(
        () => useCase('schedule-1'),
        throwsA(isA<TaskException>()),
      );
    });

    test('전략 미발견 → StrategyException', () async {
      final schedule = createSchedule();
      final task = createTask();
      when(() => mockRepository.getById('schedule-1'))
          .thenAnswer((_) async => schedule);
      when(() => mockRepository.update(any()))
          .thenAnswer((inv) async => inv.positionalArguments[0] as ReviewSchedule);
      when(() => mockTaskRepository.getById('task-1'))
          .thenAnswer((_) async => task);
      when(() => mockTaskRepository.update(any()))
          .thenAnswer((inv) async => inv.positionalArguments[0] as Task);
      when(() => mockStrategyRepository.getById('strategy-1'))
          .thenAnswer((_) async => null);

      expect(
        () => useCase('schedule-1'),
        throwsA(isA<StrategyException>()),
      );
    });
  });
}
