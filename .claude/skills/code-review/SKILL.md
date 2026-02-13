---
name: code-review
description: Critical code review checklist covering Dart, Flutter, TDD, OOP, SOLID, and design pattern perspectives. Reviews code with a critical mindset to identify issues and suggest improvements.
user-invocable: false
---

# Code Review

작성된 코드를 Dart, Flutter, TDD, OOP, SOLID 원칙, 디자인 패턴 관점에서 비판적으로 리뷰한다. 문제를 발견하면 반드시 지적하고, 구체적인 개선 방안을 제시한다.

## 리뷰 우선순위

리뷰 결과는 다음 3단계로 분류한다:

1. **CRITICAL** — 반드시 수정해야 함 (버그, 보안 취약점, 데이터 손실 위험)
2. **WARNING** — 수정을 강력히 권장 (설계 문제, 성능 이슈, 유지보수 어려움)
3. **SUGGESTION** — 개선하면 좋음 (코드 스타일, 가독성, 일관성)

## 리뷰 체크리스트

### 1. Dart Idiomatic 검사

- [ ] Effective Dart 네이밍 컨벤션을 따르는가?
- [ ] 'final'/'const'를 적절히 사용했는가?
- [ ] Null safety를 올바르게 활용하는가? ('!' 남용 없는가?)
- [ ] 'late' 변수 사용이 안전한가?
- [ ] Dart 3+ 패턴 (sealed class, pattern matching, records)을 활용할 기회가 있는가?
- [ ] cascade ('..') 연산자를 활용할 수 있는 곳이 있는가?
- [ ] import 순서가 올바른가? (dart → package → relative)
- [ ] 비동기 코드에서 'async'/'await'를 적절히 사용하는가?
- [ ] Stream subscription을 올바르게 해제하는가?
- [ ] 에러 처리가 구체적인 예외 타입을 사용하는가?

### 2. Flutter 패턴 검사

- [ ] 'const' constructor를 사용할 수 있는 곳에서 사용했는가?
- [ ] 'setState()' 호출이 최소화되어 있는가?
- [ ] 'SizedBox'를 적절히 사용했는가? (불필요한 'Container' 사용 없는가?)
- [ ] Widget의 'build()' 메서드가 과도하게 길지 않은가? (50줄 이하 권장)
- [ ] 'dispose()'에서 모든 리소스를 해제하는가?
- [ ] 'Theme.of(context)'를 사용하는가? (하드코딩 스타일 없는가?)
- [ ] 'ListView.builder()'를 사용하는가? (긴 리스트에 'ListView' 직접 사용 금지)
- [ ] 상태 관리(Riverpod)를 올바르게 사용하는가?
  - 'ref.watch()'는 'build()' 내에서만 사용하는가?
  - 'ref.read()'는 이벤트 핸들러에서만 사용하는가?
- [ ] 'AsyncValue.when()'으로 loading/error/data를 모두 처리하는가?
- [ ] 접근성(Semantics)을 고려했는가?

### 3. TDD 검사

- [ ] **모든 프로덕션 코드에 대응하는 테스트가 존재하는가?**
- [ ] 테스트가 의미 있는 동작을 검증하는가? (구현 세부사항 테스트가 아닌가?)
- [ ] 테스트 이름이 명확한가? ('should_behavior_when_condition')
- [ ] AAA 패턴 (Arrange-Act-Assert)을 따르는가?
- [ ] 각 테스트가 독립적인가? (다른 테스트에 의존하지 않는가?)
- [ ] Edge case를 테스트하는가? (빈 리스트, null, 경계값)
- [ ] Mock이 올바르게 사용되는가? (테스트 대상만 실제 인스턴스)
- [ ] 'test/' 구조가 'lib/' 구조를 미러링하는가?

### 4. OOP 검사

- [ ] 캡슐화가 올바르게 적용되는가? (불필요한 public 멤버 없는가?)
- [ ] 상속 계층이 적절한가? (깊은 상속 대신 조합 사용)
- [ ] 다형성을 활용할 기회를 놓치지 않았는가?
- [ ] 타입 체크('is')를 다형적 메서드 호출로 대체할 수 있는가?
- [ ] 불변 객체를 적절히 활용하는가?

### 5. SOLID 검사

- [ ] **SRP**: 클래스가 하나의 책임만 가지는가? (변경 이유가 하나인가?)
- [ ] **OCP**: 새로운 기능을 추가할 때 기존 코드를 수정해야 하는가?
- [ ] **LSP**: 하위 타입이 상위 타입의 계약을 지키는가?
- [ ] **ISP**: 클라이언트가 사용하지 않는 메서드에 의존하는가?
- [ ] **DIP**: 구체 구현이 아닌 추상화에 의존하는가?

### 6. Clean Architecture 검사

- [ ] **의존성 규칙**: 안쪽 레이어가 바깥쪽 레이어를 import하지 않는가?
  - Domain이 Data/Presentation을 import하는가? → **CRITICAL**
  - Entity에 Flutter 의존성이 있는가? → **CRITICAL**
- [ ] **Entity vs Model**: Entity에 fromJson/toJson이 있는가? → **WARNING**
- [ ] **UseCase**: UseCase가 하나의 비즈니스 로직만 수행하는가?
- [ ] **Repository Interface**: Domain에 인터페이스, Data에 구현체가 있는가?
- [ ] **Feature 격리**: Feature 간 직접 의존이 없는가?

### 7. Design Pattern 검사

- [ ] 적절한 디자인 패턴이 적용되어 있는가?
- [ ] 패턴이 과도하게 적용되지 않았는가? (Over-engineering)
- [ ] Repository Pattern이 올바르게 구현되어 있는가?
- [ ] Strategy Pattern이 필요한 곳에 적용되어 있는가? (복습 주기 등)
- [ ] Singleton 남용이 없는가? (Riverpod Provider로 대체 가능한가?)

### 8. 코드 품질 검사

- [ ] 매직 넘버/문자열이 상수로 추출되어 있는가?
- [ ] 중복 코드가 없는가?
- [ ] 주석이 "왜(why)"를 설명하는가? (코드 반복 주석 없는가?)
- [ ] 주석 처리된 코드가 남아있지 않는가?
- [ ] 함수 파라미터가 3개를 넘지 않는가?
- [ ] 들여쓰기가 2단계를 넘지 않는가?
- [ ] 'dart format' 포맷팅이 적용되어 있는가?

### 9. 성능 검사

- [ ] 불필요한 Widget rebuild가 없는가?
- [ ] 무거운 연산이 UI 스레드에서 실행되지 않는가?
- [ ] 리스트 렌더링이 lazy loading을 사용하는가?
- [ ] 이미지 캐싱이 적용되어 있는가?
- [ ] 메모리 누수 위험이 없는가? (미해제 subscription, controller 등)

### 10. 보안 검사 (기본)

- [ ] API 키나 시크릿이 코드에 하드코딩되지 않았는가?
- [ ] 민감 데이터가 'flutter_secure_storage'를 사용하는가?
- [ ] 사용자 입력이 검증되는가?
- [ ] 로그에 민감 정보가 출력되지 않는가?

## 리뷰 출력 형식

~~~markdown
## Code Review Result

### CRITICAL
- [파일:라인] 설명
  - 문제: 구체적인 문제 설명
  - 영향: 이 문제가 발생시킬 수 있는 결과
  - 수정안: 구체적인 코드 수정 방법

### WARNING
- [파일:라인] 설명
  - 문제: ...
  - 수정안: ...

### SUGGESTION
- [파일:라인] 설명
  - 현재: ...
  - 개선안: ...

### Summary
- CRITICAL: N건
- WARNING: N건
- SUGGESTION: N건
- 전체 품질: [Excellent / Good / Needs Improvement / Poor]
~~~

## 리뷰 원칙

- **비판적이되 건설적으로**: 문제만 지적하지 않고 반드시 해결책을 제시한다
- **근거를 제시**: 왜 문제인지 원칙/패턴을 인용하여 설명한다
- **우선순위 명확히**: CRITICAL > WARNING > SUGGESTION 순서로 대응한다
- **칭찬도 한다**: 잘 작성된 코드가 있으면 인정한다
- **일관성 중시**: 프로젝트 전체의 일관성을 확인한다
