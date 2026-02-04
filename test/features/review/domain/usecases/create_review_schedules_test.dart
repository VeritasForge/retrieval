import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrieval/core/constants/review_cycles.dart';
import 'package:retrieval/features/review/domain/entities/review_schedule.dart';
import 'package:retrieval/features/review/domain/repositories/review_schedule_repository.dart';
import 'package:retrieval/features/review/domain/usecases/create_review_schedules.dart';
import 'package:retrieval/features/study_item/domain/entities/study_item.dart';

class MockReviewScheduleRepository extends Mock
    implements ReviewScheduleRepository {}

void main() {
  late CreateReviewSchedules useCase;
  late MockReviewScheduleRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewScheduleRepository();
    useCase = CreateReviewSchedules(repository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(<ReviewSchedule>[]);
  });

  group('CreateReviewSchedules', () {
    test('should create correct number of schedules based on review cycle', () async {
      final studyItem = StudyItem.create(
        id: 'study-1',
        categoryId: 'cat-1',
        content: '문제 1번',
        isCheckbox: true,
        studyDate: DateTime(2024, 1, 15),
        reviewCycle: ReviewCycle.days_1_3_7,
      );

      when(() => mockRepository.createMany(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments[0] as List<ReviewSchedule>,
      );

      final result = await useCase(studyItem);

      expect(result.length, 3); // 1-3-7 has 3 reviews
      verify(() => mockRepository.createMany(any())).called(1);
    });

    test('should create schedules with correct dates for 1-3-7 cycle', () async {
      final studyDate = DateTime(2024, 1, 15);
      final studyItem = StudyItem.create(
        id: 'study-1',
        categoryId: 'cat-1',
        content: '문제 1번',
        isCheckbox: true,
        studyDate: studyDate,
        reviewCycle: ReviewCycle.days_1_3_7,
      );

      when(() => mockRepository.createMany(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments[0] as List<ReviewSchedule>,
      );

      final result = await useCase(studyItem);

      // 1일 후: 1/16, 4일 후(1+3): 1/19, 11일 후(1+3+7): 1/26
      expect(result[0].scheduledDate, DateTime(2024, 1, 16));
      expect(result[0].reviewOrder, 1);
      expect(result[1].scheduledDate, DateTime(2024, 1, 19));
      expect(result[1].reviewOrder, 2);
      expect(result[2].scheduledDate, DateTime(2024, 1, 26));
      expect(result[2].reviewOrder, 3);
    });

    test('should create schedules with correct dates for 1-3-7-14 cycle', () async {
      final studyDate = DateTime(2024, 1, 15);
      final studyItem = StudyItem.create(
        id: 'study-1',
        categoryId: 'cat-1',
        content: '문제 1번',
        isCheckbox: true,
        studyDate: studyDate,
        reviewCycle: ReviewCycle.days_1_3_7_14,
      );

      when(() => mockRepository.createMany(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments[0] as List<ReviewSchedule>,
      );

      final result = await useCase(studyItem);

      expect(result.length, 4);
      expect(result[0].scheduledDate, DateTime(2024, 1, 16)); // +1
      expect(result[1].scheduledDate, DateTime(2024, 1, 19)); // +1+3
      expect(result[2].scheduledDate, DateTime(2024, 1, 26)); // +1+3+7
      expect(result[3].scheduledDate, DateTime(2024, 2, 9)); // +1+3+7+14
    });

    test('all schedules should reference the study item', () async {
      final studyItem = StudyItem.create(
        id: 'study-1',
        categoryId: 'cat-1',
        content: '문제 1번',
        isCheckbox: true,
        studyDate: DateTime(2024, 1, 15),
        reviewCycle: ReviewCycle.days_1_3_7,
      );

      when(() => mockRepository.createMany(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments[0] as List<ReviewSchedule>,
      );

      final result = await useCase(studyItem);

      for (final schedule in result) {
        expect(schedule.studyItemId, 'study-1');
        expect(schedule.isCompleted, isFalse);
      }
    });
  });
}
