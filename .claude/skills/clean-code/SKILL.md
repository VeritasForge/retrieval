---
name: clean-code
description: Clean Code principles for writing readable, maintainable, and efficient code. Applies Robert C. Martin's Clean Code guidelines adapted for Dart and Flutter.
user-invocable: false
---

# Clean Code 원칙

Robert C. Martin의 Clean Code 원칙을 Dart/Flutter에 맞게 적용한다.

## 핵심 철학

> "Clean code reads like well-written prose." — Robert C. Martin

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand." — Martin Fowler

## 네이밍

### 의도를 드러내는 이름
- 이름만으로 변수/함수/클래스의 목적을 파악할 수 있어야 한다
- 약어를 피하고 완전한 단어를 사용한다
- 검색 가능한 이름을 사용한다

```dart
// Good
final daysUntilNextReview = calculateDaysRemaining(nextReviewDate);
final isReviewOverdue = daysUntilNextReview < 0;
final overdueReviews = reviews.where((r) => r.isOverdue).toList();

// Bad
final d = calc(nrd);
final flag = d < 0;
final list = reviews.where((r) => r.f).toList();
```

### 클래스와 메서드 네이밍 규칙
- **클래스명**: 명사/명사구 (`ReviewScheduler`, `SpacedRepetitionCalculator`)
- **메서드명**: 동사/동사구 (`calculateNextReview`, `markAsCompleted`)
- **Bool 변수/getter**: `is`, `has`, `can`, `should` 접두사 (`isCompleted`, `hasReviews`)
- **팩토리 메서드**: `create`, `from`, `of` 접두사
- **변환 메서드**: `to` 접두사 (`toJson`, `toEntity`)

### 일관성
- 한 개념에 하나의 단어만 사용한다
- `fetch`, `get`, `retrieve` 중 하나만 선택하여 프로젝트 전체에서 일관되게 사용한다
- `Controller`, `Manager`, `Handler` 중 하나만 선택한다

## 함수

### 작게 만들기
- 한 함수는 한 가지 일만 한다 (Single Responsibility)
- 함수 본문은 20줄 이하를 목표로 한다
- 들여쓰기는 최대 2단계까지만 허용한다

### 파라미터
- 파라미터 수는 3개 이하로 제한한다
- 3개 이상 필요하면 객체로 묶는다
- boolean 파라미터 대신 별도 함수를 만든다
- Named parameter를 적극 활용한다

```dart
// Good
void scheduleReview({
  required String reviewId,
  required DateTime nextDate,
  ReviewPriority priority = ReviewPriority.normal,
}) { ... }

// Bad
void scheduleReview(String id, DateTime d, bool urgent, bool notify, int p) { ... }
```

### 부수 효과 없는 함수
- 함수 이름이 암시하지 않는 부수 효과를 만들지 않는다
- Query와 Command를 분리한다 (CQS - Command Query Separation)

```dart
// Good - Query (부수 효과 없음)
List<Review> getOverdueReviews() => _reviews.where((r) => r.isOverdue).toList();

// Good - Command (명확한 부수 효과)
void markReviewAsCompleted(String reviewId) {
  _reviews.firstWhere((r) => r.id == reviewId).complete();
  _notifyListeners();
}

// Bad - Query에 부수 효과가 숨겨져 있음
List<Review> getOverdueReviews() {
  _lastAccessedAt = DateTime.now(); // 숨겨진 부수 효과
  return _reviews.where((r) => r.isOverdue).toList();
}
```

## 클래스

### 단일 책임 원칙 (SRP)
- 클래스는 변경 이유가 하나만 있어야 한다
- 클래스명으로 책임을 설명할 수 없으면 분리한다
- "그리고(and)"가 들어가면 분리 신호다

### 응집도
- 클래스의 모든 메서드가 대부분의 인스턴스 변수를 사용해야 한다
- 일부 메서드만 사용하는 변수가 있으면 클래스 분리를 고려한다

### 캡슐화
- 구현 세부사항을 숨기고 인터페이스만 노출한다
- `_` private을 적극 활용한다
- getter/setter보다 의미 있는 메서드를 제공한다

## 주석

### 좋은 주석
- **왜(Why)**: 비즈니스 규칙이나 의사결정 이유를 설명
- **경고(Warning)**: 주의해야 할 사항을 알림
- **TODO**: 향후 작업 표시 (기한 포함)

### 나쁜 주석 (작성 금지)
- 코드를 반복하는 주석
- 주석 처리된 코드 (삭제한다)
- 이력 주석 (git이 관리한다)
- 닫는 괄호 주석 (`// end if`, `// end for`)

```dart
// Good - 왜 이런 결정을 했는지 설명
// 에빙하우스 망각곡선에 따르면 첫 번째 복습은 24시간 이내가 최적이다.
// 하지만 사용자 피드백을 반영하여 1일 후로 설정했다.
const firstReviewInterval = Duration(days: 1);

// Bad - 코드를 반복하는 주석
// 리뷰 목록을 가져온다
final reviews = getReviews();
```

## 에러 처리

- 에러 코드보다 예외를 사용한다
- null 반환 대신 빈 컬렉션이나 Optional 패턴 사용
- 예외에 충분한 컨텍스트 정보를 포함한다
- 외부 라이브러리 예외는 래핑하여 사용한다

```dart
// Good - 커스텀 예외 with 컨텍스트
class ReviewNotFoundException implements Exception {
  final String reviewId;
  const ReviewNotFoundException(this.reviewId);

  @override
  String toString() => 'Review not found: $reviewId';
}
```

## 포맷팅

- `dart format` 자동 포맷팅을 사용한다
- 한 줄은 80자 이하를 권장한다
- 관련 코드는 그룹으로 묶고, 그룹 사이에 빈 줄을 넣는다
- 수직 거리: 관련 함수는 가까이 배치한다

## DRY (Don't Repeat Yourself)

- 동일한 로직이 2번 이상 반복되면 추출한다
- 단, 우연히 비슷한 코드는 추출하지 않는다 (변경 이유가 다르면 중복이 아니다)
- 과도한 추상화보다 약간의 중복이 낫다 (3번 규칙)

## KISS (Keep It Simple, Stupid)

- 가장 단순한 해결책을 선택한다
- "나중에 필요할 수도 있는" 기능을 미리 만들지 않는다 (YAGNI)
- 복잡한 제네릭이나 메타프로그래밍을 피한다
- 코드 리뷰에서 "이게 왜 필요한가?"라는 질문에 답할 수 없으면 제거한다

## Boy Scout Rule

> "Always leave the code cleaner than you found it."

- 코드를 수정할 때 주변 코드도 조금씩 개선한다
- 단, 기능 변경과 리팩토링은 별도 커밋으로 분리한다
