---
name: tdd
description: Strict Test-Driven Development process. Enforces Red-Green-Refactor cycle with no exceptions. All production code MUST be preceded by a failing test.
user-invocable: false
---

# Strict TDD (Test-Driven Development)

TDD는 선택이 아니라 **필수**다. 모든 프로덕션 코드는 반드시 실패하는 테스트가 먼저 존재해야 한다.

## 절대 원칙 (위반 금지)

1. **테스트 없이 프로덕션 코드를 작성하지 않는다**
2. **실패하는 테스트가 있을 때만 프로덕션 코드를 작성한다**
3. **테스트를 통과시키는 최소한의 코드만 작성한다**
4. **모든 리팩토링은 테스트가 통과하는 상태에서 수행한다**

## Red-Green-Refactor 사이클

### Step 1: RED (실패하는 테스트 작성)

~~~
1. 구현하려는 동작을 정확히 정의한다
2. 해당 동작을 검증하는 테스트를 작성한다
3. 테스트가 올바른 이유로 실패하는지 확인한다
4. 컴파일 에러도 "실패"로 간주한다
~~~

**규칙:**
- 테스트는 하나의 동작만 검증한다 (Single Assert Rule)
- 테스트 이름은 'should_expectedBehavior_when_condition' 패턴을 따른다
- Given/When/Then 패턴을 사용한다
- 테스트가 올바른 이유로 실패하는지 반드시 확인한다
- Happy Path 뿐만 아니라 예외 상황이나 엣지 케이스도 고려해서 테스트를 만든다

~~~dart
test('should return list of reviews when repository has data', () async {
  // Arrange
  when(() => mockRepository.getReviews())
      .thenAnswer((_) async => [testReview]);

  // Act
  final result = await useCase.execute();

  // Assert
  expect(result, equals([testReview]));
  verify(() => mockRepository.getReviews()).called(1);
});
~~~

### Step 2: GREEN (최소한의 코드로 통과)

~~~
1. 테스트를 통과시키는 가장 단순한 코드를 작성한다
2. 하드코딩도 허용된다 (다음 테스트에서 일반화)
3. 설계를 고려하지 않는다 (리팩토링 단계에서 처리)
4. 다른 테스트를 깨뜨리지 않는지 확인한다
~~~

**규칙:**
- 테스트가 요구하지 않는 코드를 작성하지 않는다
- "나중에 필요할 것 같은" 코드를 미리 작성하지 않는다
- 'flutter test' 실행하여 모든 테스트가 통과하는지 확인한다

### Step 3: REFACTOR (코드 개선)

~~~
1. 중복을 제거한다
2. 네이밍을 개선한다
3. 메서드/클래스를 분리한다
4. 디자인 패턴을 적용한다
5. 매 변경마다 모든 테스트가 통과하는지 확인한다
~~~

**규칙:**
- 리팩토링 중 새로운 기능을 추가하지 않는다
- 리팩토링 중 테스트를 수정하지 않는다 (테스트 리팩토링은 별도 사이클)
- 작은 단위로 리팩토링하고 매번 테스트를 실행한다

## 테스트 레이어별 전략

### Domain Layer (Unit Tests)

**테스트 대상:** Entity, UseCase, Value Object

~~~dart
// UseCase 테스트 예시
group('GetReviews', () {
  late GetReviews useCase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = GetReviews(mockRepository);
  });

  test('should return reviews from repository', () async {
    // Arrange
    when(() => mockRepository.getReviews())
        .thenAnswer((_) async => [testReview]);

    // Act
    final result = await useCase.execute();

    // Assert
    expect(result, [testReview]);
  });

  test('should throw when repository fails', () async {
    // Arrange
    when(() => mockRepository.getReviews())
        .thenThrow(ServerException());

    // Act & Assert
    expect(() => useCase.execute(), throwsA(isA<ServerException>()));
  });
});
~~~

### Data Layer (Unit Tests)

**테스트 대상:** Repository 구현체, Model (fromJson/toJson), DataSource

~~~dart
// Model 테스트 예시
group('ReviewModel', () {
  test('should create from JSON', () {
    // Arrange
    final json = {'id': '1', 'title': 'Test', 'nextReviewDate': '2024-01-01'};

    // Act
    final model = ReviewModel.fromJson(json);

    // Assert
    expect(model.id, '1');
    expect(model.title, 'Test');
  });

  test('should convert to JSON', () {
    // Arrange
    final model = ReviewModel(id: '1', title: 'Test');

    // Act
    final json = model.toJson();

    // Assert
    expect(json['id'], '1');
    expect(json['title'], 'Test');
  });
});
~~~

### Presentation Layer (Widget Tests)

**테스트 대상:** Widget, Page, Provider

~~~dart
// Widget 테스트 예시
testWidgets('should display review list when data is loaded', (tester) async {
  // Arrange
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reviewProvider.overrideWith((_) => AsyncData([testReview])),
      ],
      child: const MaterialApp(home: ReviewListPage()),
    ),
  );

  // Act
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Test Review'), findsOneWidget);
});
~~~

## 모킹 규칙 (Mocktail)

- **테스트 대상 클래스만 실제 인스턴스를 사용한다**
- **모든 의존성은 Mock으로 대체한다**
- 추상 클래스/인터페이스가 있어야 Mocking이 가능하다 → Clean Architecture의 Repository 인터페이스가 필수인 이유

~~~dart
// Mock 선언
class MockReviewRepository extends Mock implements ReviewRepository {}
class MockGetReviews extends Mock implements GetReviews {}

// 등록 (setUpAll)
setUpAll(() {
  registerFallbackValue(FakeReview());
});
~~~

## 테스트 파일 구조

'test/' 폴더 구조는 'lib/' 구조를 미러링한다:

~~~
test/
├── features/
│   └── review/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── review_local_data_source_test.dart
│       │   ├── models/
│       │   │   └── review_model_test.dart
│       │   └── repositories/
│       │       └── review_repository_impl_test.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── review_test.dart
│       │   └── usecases/
│       │       └── get_reviews_test.dart
│       └── presentation/
│           ├── pages/
│           │   └── review_list_page_test.dart
│           ├── providers/
│           │   └── review_provider_test.dart
│           └── widgets/
│               └── review_card_test.dart
└── fixtures/
    └── review_fixture.dart  # 테스트용 공유 데이터
~~~

## TDD 개발 순서

새로운 기능을 개발할 때 다음 순서를 따른다:

~~~
1. Entity 테스트 → Entity 구현
2. Repository Interface 정의 (테스트 없이 - 인터페이스만)
3. UseCase 테스트 → UseCase 구현
4. Model 테스트 → Model 구현
5. DataSource 테스트 → DataSource 구현
6. Repository 구현체 테스트 → Repository 구현체 구현
7. Provider 테스트 → Provider 구현
8. Widget 테스트 → Widget 구현
~~~

## 테스트 커버리지

- **목표**: 80% 이상 코드 커버리지
- 'flutter test --coverage'로 측정
- Domain layer: 100% 커버리지 목표
- Data layer: 90% 이상
- Presentation layer: 80% 이상 (Widget test)

## 검증 명령

모든 변경 후 반드시 실행:

~~~bash
flutter test
flutter test --coverage
~~~

## 금지 사항

- **테스트 없이 'lib/' 코드를 수정하지 않는다**
- **테스트를 건너뛰거나 'skip'하지 않는다** (일시적으로도)
- **테스트를 통과시키기 위해 테스트를 수정하지 않는다** (프로덕션 코드를 수정)
- **'print()' 디버깅 대신 테스트를 작성한다**
- **통합 테스트로 유닛 테스트를 대체하지 않는다**
