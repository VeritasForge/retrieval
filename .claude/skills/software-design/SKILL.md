---
name: software-design
description: Software design principles including DDD, Clean Architecture, OOP, Design Patterns, and SOLID. Guides architectural decisions and code structure for Flutter apps.
user-invocable: false
---

# Software Design

DDD, Clean Architecture, OOP, Design Patterns, SOLID 원칙을 적용하여 유지보수 가능하고 확장 가능한 소프트웨어를 설계한다.

## SOLID 원칙

### S - Single Responsibility Principle (단일 책임 원칙)
- 클래스는 변경 이유가 하나만 있어야 한다
- UseCase는 하나의 비즈니스 로직만 수행한다
- Widget은 하나의 시각적 책임만 가진다

```dart
// Good - 각각 하나의 책임
class ReviewScheduler {
  DateTime calculateNextReviewDate(Review review, ReviewCycle cycle) { ... }
}

class ReviewNotifier {
  void notifyUpcomingReview(Review review) { ... }
}

// Bad - 여러 책임이 혼합
class ReviewManager {
  void calculateAndNotifyAndSave(Review review) { ... }
}
```

### O - Open/Closed Principle (개방-폐쇄 원칙)
- 확장에는 열려 있고, 수정에는 닫혀 있어야 한다
- 새로운 동작은 기존 코드 수정 없이 추가 가능해야 한다
- Strategy Pattern, Template Method Pattern 활용

```dart
// Good - 새로운 주기 추가 시 기존 코드 수정 불필요
abstract class ReviewCycleStrategy {
  List<int> get intervals;
  DateTime calculateNext(DateTime baseDate, int completedCount);
}

class Cycle137 extends ReviewCycleStrategy {
  @override
  List<int> get intervals => [1, 3, 7];
  // ...
}

class Cycle13714 extends ReviewCycleStrategy {
  @override
  List<int> get intervals => [1, 3, 7, 14];
  // ...
}
```

### L - Liskov Substitution Principle (리스코프 치환 원칙)
- 하위 타입은 상위 타입으로 대체 가능해야 한다
- 상속보다 조합을 선호한다
- 계약(contract)을 위반하는 override를 하지 않는다

### I - Interface Segregation Principle (인터페이스 분리 원칙)
- 클라이언트가 사용하지 않는 메서드에 의존하지 않아야 한다
- 큰 인터페이스를 작은 인터페이스로 분리한다

```dart
// Good - 분리된 인터페이스
abstract class ReviewReader {
  Future<List<Review>> getReviews();
  Future<Review?> getReviewById(String id);
}

abstract class ReviewWriter {
  Future<void> saveReview(Review review);
  Future<void> deleteReview(String id);
}

abstract class ReviewRepository implements ReviewReader, ReviewWriter {}
```

### D - Dependency Inversion Principle (의존성 역전 원칙)
- 고수준 모듈이 저수준 모듈에 의존하지 않는다
- 둘 다 추상화에 의존한다
- Domain layer는 Data layer를 모른다

```
Presentation → Domain ← Data
(Provider)     (UseCase, Entity, Repository Interface)   (Repository Impl, Model, DataSource)
```

## Clean Architecture

### 3-Layer Architecture

```
┌─────────────────────────────────────┐
│         Presentation Layer          │  ← Flutter 의존
│   Pages, Widgets, Providers         │
├─────────────────────────────────────┤
│           Domain Layer              │  ← Pure Dart (Flutter 비의존)
│   Entities, UseCases, Repo Interfaces│
├─────────────────────────────────────┤
│            Data Layer               │  ← 외부 의존성
│   Models, Repo Impls, DataSources   │
└─────────────────────────────────────┘
```

### 의존성 규칙
- **안쪽 레이어는 바깥쪽 레이어를 모른다**
- Domain은 Presentation과 Data를 모른다
- Data는 Domain의 인터페이스를 구현한다
- Presentation은 Domain의 UseCase를 사용한다

### Feature-First 구조

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── usecases/
│   │   └── usecase.dart        # UseCase 추상 클래스
│   └── utils/
│       └── date_utils.dart
└── features/
    └── review/
        ├── data/
        │   ├── datasources/
        │   │   └── review_local_data_source.dart
        │   ├── models/
        │   │   └── review_model.dart    # extends Entity, fromJson/toJson
        │   └── repositories/
        │       └── review_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── review.dart          # Pure Dart, 비즈니스 속성만
        │   ├── repositories/
        │   │   └── review_repository.dart  # 추상 인터페이스
        │   └── usecases/
        │       ├── get_reviews.dart
        │       ├── add_review.dart
        │       └── complete_review.dart
        └── presentation/
            ├── pages/
            │   └── review_list_page.dart
            ├── providers/
            │   └── review_provider.dart
            └── widgets/
                └── review_card.dart
```

### Entity vs Model
- **Entity**: Domain layer에 위치, Pure Dart, 비즈니스 로직만 포함
- **Model**: Data layer에 위치, Entity를 extends, `fromJson`/`toJson`/`fromHive`/`toHive` 포함

```dart
// Domain - Entity (Pure Dart)
class Review {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime nextReviewDate;
  final int completedCount;

  const Review({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.nextReviewDate,
    this.completedCount = 0,
  });

  bool get isOverdue => DateTime.now().isAfter(nextReviewDate);
}

// Data - Model (extends Entity)
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.nextReviewDate,
    super.completedCount,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  factory ReviewModel.fromEntity(Review entity) { ... }
}
```

### UseCase 패턴

```dart
// 추상 UseCase
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {}

// 구체 UseCase
class GetReviews implements UseCase<List<Review>, NoParams> {
  final ReviewRepository repository;

  const GetReviews(this.repository);

  @override
  Future<List<Review>> call(NoParams params) {
    return repository.getReviews();
  }
}
```

## OOP 원칙

### 캡슐화
- 내부 상태를 숨기고 public 메서드로만 접근한다
- Dart의 `_` private을 활용한다
- getter보다 의미 있는 메서드를 제공한다

### 다형성
- 추상 클래스와 인터페이스를 활용한다
- Sealed class로 exhaustive 패턴 매칭을 구현한다
- 타입 체크(`is`) 대신 다형적 메서드 호출을 사용한다

### 상속보다 조합
- 깊은 상속 계층을 피한다 (최대 2단계)
- Mixin으로 횡단 관심사를 추가한다
- 조합(composition)으로 기능을 구성한다

## Design Patterns (Flutter 맞춤)

### Repository Pattern
- Data layer와 Domain layer를 분리한다
- Domain에 인터페이스, Data에 구현체를 둔다

### Observer Pattern (Riverpod)
- `ref.watch()`로 반응형 상태 관찰
- Provider의 상태 변화에 자동 UI 갱신

### Strategy Pattern
- 복습 주기 계산 등 교체 가능한 알고리즘에 적용

### Factory Pattern
- 복잡한 객체 생성 로직을 캡슐화
- `factory` constructor 또는 별도 Factory 클래스 활용

### Singleton Pattern
- Dart에서는 `factory` constructor + `static` instance로 구현
- 단, 남용하지 않는다 (테스트 어려움, 전역 상태)
- Riverpod Provider가 Singleton을 대체할 수 있다

## DDD (Domain-Driven Design) 핵심 개념

### Ubiquitous Language
- 도메인 전문가와 개발자가 같은 용어를 사용한다
- 코드에서도 도메인 용어를 그대로 사용한다
- 예: `Review`, `ReviewCycle`, `SpacedRepetition`, `ForgettingCurve`

### Value Object
- 동등성은 값으로 판단한다 (identity가 아닌)
- 불변(immutable)이다
- 자체 검증 로직을 포함한다

```dart
class ReviewCycle {
  final List<int> intervals;

  const ReviewCycle(this.intervals)
      : assert(intervals.length > 0, 'Intervals must not be empty');

  @override
  bool operator ==(Object other) =>
      other is ReviewCycle && listEquals(intervals, other.intervals);

  @override
  int get hashCode => Object.hashAll(intervals);
}
```

### Aggregate
- 관련 Entity와 Value Object의 묶음
- Aggregate Root를 통해서만 내부 상태를 변경한다
- 트랜잭션 일관성의 경계

### Bounded Context
- 각 Feature가 하나의 Bounded Context에 해당한다
- Feature 간 의존성을 최소화한다
- 공유 개념은 `core/`에 배치한다
