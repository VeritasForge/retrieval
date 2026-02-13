# Retrieval - 복습 관리 앱

## 프로젝트 개요

에빙하우스 망각곡선 기반 간격 반복 학습(Spaced Repetition)을 활용한 복습 관리 앱

## 기술 스택

- **Flutter** - 크로스 플랫폼 프레임워크
- **Riverpod** - 상태 관리 (flutter_riverpod, riverpod_annotation)
- **Hive** - 로컬 데이터 저장 (hive, hive_flutter)
- **fl_chart** - 도넛 차트
- **uuid** - 고유 ID 생성
- **equatable** - 값 객체 동등성 비교
- **intl** - 국제화/날짜 포맷팅

## 아키텍처

Clean Architecture 적용 - `lib/features/[feature]/` 하위에 `domain/`, `data/`, `presentation/` 레이어 분리

### Features

- **category** - 카테고리 관리
- **review** - 복습 스케줄 관리
- **shell** - 앱 셸 (네비게이션/레이아웃)
- **statistics** - 통계/차트
- **strategy** - 복습 전략 관리
- **task** - 학습 태스크 관리

### Core

- `lib/core/constants/` - 상수 (앱 색상, 기본 카테고리 등)
- `lib/core/exceptions/` - 예외 처리
- `lib/core/theme/` - 앱 테마
- `lib/core/utils/` - 유틸리티 (날짜, 색상, 아이콘)

## 복습 전략

Strategy 엔티티로 동적 관리. 기본 전략:

- **에빙하우스 (표준)**: 1 → 3 → 7 → 14 → 30일
- **피보나치 (자연)**: 1 → 2 → 3 → 5 → 8 → 13일
- **단기 집중 (스피드)**: 1 → 3 → 6 → 10일

모든 간격은 **공부한 날(studyDate) 기준**으로 계산. 계산된 날짜가 과거인 경우 오늘로 보정.

## Claude Code 설정

### Agents

- **flutter-developer** - Flutter 시니어 개발자 에이전트 (TDD, Clean Architecture)
- **code-reviewer** - 코드 리뷰 에이전트 (Dart, Flutter, SOLID, 보안)

### Skills

- **clean-code** - Clean Code 원칙 적용
- **code-review** - 코드 리뷰 체크리스트
- **dart-coding** - Dart 코딩 컨벤션
- **dev-review-cycle** - 개발-리뷰 사이클 오케스트레이션
- **flutter-patterns** - Flutter 패턴 및 모범 사례
- **full-review** - 전체 코드 리뷰 오케스트레이션
- **secure-code** - OWASP 기반 보안 모범 사례
- **software-design** - DDD, Clean Architecture, SOLID 설계 원칙
- **tdd** - TDD Red-Green-Refactor 사이클

### Rules

- **commands** - 의존성 설치, 코드 생성, 테스트, 분석, 실행 명령어
- **protection-protocol** - 테스트 보호 프로토콜 (변경 전/후 검증 필수)

### Commands

- **/commit** - 변경사항 커밋 및 푸시
- **/wrap** - CLAUDE.md 동기화 검증 및 업데이트

## 테스트

9개 테스트 파일:
- `test/core/date_utils_test.dart`
- `test/features/category/domain/entities/category_test.dart`
- `test/features/category/domain/usecases/create_category_test.dart`
- `test/features/review/domain/entities/review_schedule_test.dart`
- `test/features/review/domain/usecases/complete_review_test.dart`
- `test/features/review/domain/usecases/create_next_review_schedule_test.dart`
- `test/features/review/domain/usecases/get_pending_reviews_test.dart`
- `test/features/strategy/domain/entities/strategy_test.dart`
- `test/features/task/domain/entities/task_test.dart`
