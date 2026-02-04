---
name: full-review
description: 기존 코드베이스를 code-reviewer + flutter-developer 에이전트로 리뷰하고 수정하는 리뷰 전용 오케스트레이션 스킬
user-invocable: true
---

# Full Review Orchestrator

기존 코드베이스를 `code-reviewer` (검증) + `flutter-developer` (수정) 에이전트로 **리뷰→판정→수정** 순서로 오케스트레이션한다.
메인 대화가 **Judge** 역할을 수행하며, 증거 기반으로 최종 판정한다.

## 사용법

```
/full-review           # 전체 feature 리뷰
/full-review <feature> # 단일 feature 리뷰 (예: /full-review category)
```

## dev-review-cycle과의 차이

| 항목 | dev-review-cycle | full-review |
|------|-----------------|-------------|
| 시작점 | 새 기능 개발 | 기존 코드 리뷰 |
| Round 0 | 구현 계획 수립 | 리뷰 범위 분석 + 배치 계획 |
| Round 1 | flutter-developer (개발) | code-reviewer (리뷰) |
| Round 2 | code-reviewer (리뷰) | Judge 판정 (메인 대화) |
| Round 3 | Judge 판정 | flutter-developer (수정, 조건부) |
| 단위 | 요구사항 1건 | feature 단위 배치 |

## 프로토콜 (4 Round)

feature 단위로 Round 1~3을 반복 실행한다.
**feature당 수정 최대 2회** (무한루프 방지)

---

### Round 0: 범위 분석

sequential-thinking MCP를 사용하여 다음을 수행한다:

1. 인자 파싱: 전체 리뷰 vs 단일 feature
2. Glob으로 `lib/features/*/` 및 `lib/core/`, `lib/app.dart` 파일 목록 수집
3. feature별 배치 계획 수립 (priority 순)

**배치 우선순위**:

| Priority | 대상 | 사유 |
|----------|------|------|
| P1 | category | 핵심 도메인 (다른 feature에서 의존) |
| P1 | review | 핵심 비즈니스 로직 (복습 주기) |
| P1 | core | 공유 인프라 |
| P2 | study_item | 주요 데이터 feature |
| P3 | statistics | 통계 표시 |
| P3 | app | 앱 진입점 |

**출력**: 배치 계획 (feature 목록, 파일 수, 실행 순서)

---

### Round 1: Feature 리뷰 (code-reviewer)

Task tool을 사용하여 `code-reviewer` 에이전트를 호출한다. **feature별로 반복 실행.**

```
Task(
  subagent_type: "code-reviewer",
  prompt: """
  ## 코드 리뷰 요청: {feature_name}

  ### 리뷰 대상 파일
  {feature 파일 목록을 layer별로 분류}
  - domain/: [파일 목록]
  - data/: [파일 목록]
  - presentation/: [파일 목록]

  ### 프로젝트 컨텍스트
  - Flutter + Riverpod + Hive + Clean Architecture
  - 에빙하우스 망각곡선 기반 간격 반복 학습 앱
  - 복습 주기: 1-3-7, 1-3-7-14, 1-4-7-14, 2-3-5-7

  ### 지시사항
  - 위 파일들을 모두 읽고 8가지 관점에서 리뷰한다
  - **아키텍처 위반(Clean Architecture 의존성 규칙)을 최우선으로 검사한다**
  - **반드시 1개 이상의 개선점을 식별한다** (아무리 잘 작성된 코드라도 개선할 부분은 있다)
  - 칭찬만 하지 않는다. 구체적인 개선 포인트를 반드시 제시한다
  - flutter test와 flutter analyze는 실행하지 않는다 (Judge가 최종 실행)
  - 완료 후 아래 형식으로 500토큰 이내 요약을 반환한다:

  ## 리뷰 결과: {feature_name}

  ### CRITICAL (반드시 수정)
  - [파일:라인] 설명 | 위반 원칙 | 수정안

  ### WARNING (수정 권장)
  - [파일:라인] 설명 | 위반 원칙 | 수정안

  ### SUGGESTION (개선 가능)
  - [파일:라인] 설명 | 현재 → 개선안

  ### 테스트 커버리지
  - 누락된 테스트: [목록]

  ### Summary
  - CRITICAL: N건, WARNING: N건, SUGGESTION: N건
  - 전체 품질: [Excellent / Good / Needs Improvement / Poor]
  """
)
```

**Sycophancy 방지**: "반드시 1개 이상 개선점 식별" 지시로 리뷰어가 무조건 승인하는 것을 방지한다.

---

### Round 2: Judge 판정 (메인 대화)

메인 대화가 Judge로서 리뷰 결과를 **독립적으로** 판정한다.
단순 다수결이 아닌 **증거 기반 판정**을 수행한다.

#### 판정 절차

1. 리뷰어가 보고한 CRITICAL/WARNING 항목의 **해당 코드를 직접 Read tool로 읽는다**
2. 코드를 읽은 결과를 근거로 판정한다

#### 판정 기준

| 판정 | 조건 | 후속 행동 |
|------|------|-----------|
| AGREED | 해당 코드를 직접 읽고, 리뷰어의 지적이 타당하다고 판단 | 수정 대상에 포함 |
| DISAGREED | 해당 코드를 직접 읽고, 리뷰어의 지적이 과도하거나 부적절하다고 판단 | 수정 대상에서 제외, 사유 기록 |
| UNCERTAIN | 판단이 어려운 경우 | AskUserQuestion으로 사용자에게 확인 |

#### 판정 후 분기

```
if (AGREED인 CRITICAL 항목 존재):
    → MUST_FIX → Round 3으로 진행
    → 반복 횟수 +1

elif (AGREED인 WARNING 다수 존재):
    → SHOULD_FIX → Round 3으로 진행
    → 반복 횟수 +1

elif (SUGGESTION만 존재):
    → 사용자에게 보고 후 다음 feature로 진행
```

#### 판정 보고 형식

```markdown
## Judge 판정 결과: {feature_name}

### AGREED (수정 진행)
- [항목] 사유: ...

### DISAGREED (수정 불필요)
- [항목] 사유: ...

### UNCERTAIN (사용자 확인 필요)
- [항목] 질문: ...

### 다음 행동
- MUST_FIX / SHOULD_FIX / REPORT_ONLY
```

---

### Round 3: 수정 사이클 (flutter-developer, 조건부)

MUST_FIX 또는 SHOULD_FIX 판정 시에만 실행한다.

```
Task(
  subagent_type: "flutter-developer",
  prompt: """
  ## 수정 요청: {feature_name}

  ### AGREED 수정 항목
  {Judge가 AGREED 판정한 CRITICAL/WARNING 항목만}
  - [파일:라인] 문제 설명 | 수정안

  ### 컨텍스트
  - Flutter + Riverpod + Hive + Clean Architecture
  - DISAGREED 항목은 수정하지 않는다
  - SUGGESTION 항목은 수정하지 않는다

  ### 지시사항
  - AGREED 항목만 수정한다
  - 기존 동작을 변경하지 않으면서 코드 품질을 개선한다
  - 수정 완료 후 `flutter test`와 `flutter analyze`를 실행한다
  - 완료 후 아래 형식으로 500토큰 이내 요약을 반환한다:

  ## 수정 요약: {feature_name}
  - 변경 파일: [파일 목록]
  - 수정 항목: [수정한 AGREED 항목 목록]
  - 테스트 결과: [pass/fail, 실패 시 상세]
  - 분석 결과: [clean/issues, 이슈 시 상세]
  """
)
```

**수정 후 재검토**: 수정 완료 후 code-reviewer 에이전트로 **수정 파일만** 재검토한다.

```
Task(
  subagent_type: "code-reviewer",
  prompt: """
  ## 수정 후 재검토: {feature_name}

  ### 수정된 파일
  {Round 3에서 변경된 파일 목록}

  ### 원래 지적 사항
  {AGREED 항목 목록}

  ### 지시사항
  - 수정된 파일만 읽고 리뷰한다
  - 원래 지적 사항이 올바르게 수정되었는지 확인한다
  - 새로운 CRITICAL이 발견되면 보고한다
  - flutter test와 flutter analyze는 실행하지 않는다
  - 500토큰 이내 요약을 반환한다
  """
)
```

재검토에서 새 CRITICAL 발견 시 → Judge 판정 → 수정 반복 (feature당 최대 2회)

---

## Feature별 처리 흐름

```
FOR EACH feature IN batch_plan (priority 순):
  round_count = 0

  Round 1: code-reviewer 리뷰
  Round 2: Judge 판정
    if MUST_FIX or SHOULD_FIX:
      WHILE round_count < 2:
        Round 3: flutter-developer 수정 + code-reviewer 재검토
        Judge 재판정
        if no new CRITICAL: BREAK
        round_count += 1

  → 결과 누적

→ flutter test 실행 (전체)
→ flutter analyze 실행 (전체)
→ 종료 보고
```

---

## 종료 보고

모든 feature 처리 완료 후 최종 보고한다:

```markdown
## Full Review Report

### 요약
- 리뷰 feature: N개
- 총 CRITICAL: N건 (해결: N, 미해결: N)
- 총 WARNING: N건 (해결: N, 미해결: N)
- SUGGESTION: N건
- 누락 테스트: N개 파일
- flutter test: PASS/FAIL
- flutter analyze: PASS/FAIL

### Feature별 결과
| Feature | CRITICAL | WARNING | SUGGESTION | 수정 횟수 | 상태 |
|---------|----------|---------|------------|-----------|------|
| category | N | N | N | N | 완료/미해결 |
| ... | ... | ... | ... | ... | ... |

### Judge DISAGREED 항목
- [{feature}] [항목] Judge 판단 사유: ...

### 미해결 항목 (수동 조치 필요)
- [{feature}] [항목] 권장 조치: ...
```

## 제약사항

- 각 에이전트는 **500토큰 이내 요약**만 반환 (Context 폭발 방지)
- feature당 수정 **최대 2회** (무한루프 방지)
- Subagent는 1-level only (메인 대화가 orchestrator)
- code-reviewer는 `flutter test`/`flutter analyze` 실행 안 함 (Judge가 전체 종료 시 최종 실행)
- MCP 도구는 포그라운드 실행만 사용
