---
name: dev-review-cycle
description: flutter-developer와 code-reviewer 에이전트를 오케스트레이션하여 TDD 기반 개발-리뷰 사이클을 실행합니다
user-invocable: true
---

# Dev-Review Cycle Orchestrator

사용자 요구사항을 받아 `flutter-developer` (생산) + `code-reviewer` (검증) 에이전트를 오케스트레이션한다.
메인 대화가 **Judge** 역할을 수행하며, 증거 기반으로 최종 판정한다.

## 사용법

```
/dev-review-cycle <요구사항>
```

## 프로토콜 (4 Round)

사용자 요구사항을 인자로 받으면, 아래 4개 라운드를 순차 실행한다.
**최대 반복: 3회** (무한루프 방지)
**조기 종료 조건**: CRITICAL 0개 + `flutter test` 통과 + `flutter analyze` 통과

---

### Round 0: 요구사항 분석

sequential-thinking MCP를 사용하여 다음을 수행한다:

1. 사용자 요구사항을 분석한다
2. Task tool (subagent_type=Explore)로 영향 범위를 파악한다
3. 구현 계획을 수립한다
4. 핵심 질문이 있으면 AskUserQuestion으로 사용자에게 확인한다

**출력**: 구현 계획 (영향 파일, 변경 내용, TDD 순서)

---

### Round 1: 개발 (flutter-developer)

Task tool을 사용하여 `flutter-developer` 에이전트를 호출한다.

```
Task(
  subagent_type: "flutter-developer",
  prompt: """
  ## 구현 요청

  ### 요구사항
  {Round 0에서 정리한 구현 계획}

  ### 컨텍스트
  {영향 범위 파일 목록과 현재 구조}

  ### 수정 지시 (반복 시)
  {Round 3에서 AGREED 판정된 리뷰 항목}

  ### 지시사항
  - TDD Red-Green-Refactor를 엄격히 따른다
  - 구현 완료 후 `flutter test`와 `flutter analyze`를 실행한다
  - 완료 후 아래 형식으로 500토큰 이내 요약을 반환한다:

  ## 구현 요약
  - 변경 파일: [파일 목록]
  - 추가 파일: [새로 생성한 파일 목록]
  - 테스트 결과: [pass/fail, 실패 시 상세]
  - 분석 결과: [clean/issues, 이슈 시 상세]
  - 핵심 설계 결정: [주요 결정 사항]
  """
)
```

**Round 1 완료 후**: 에이전트 요약을 저장하고 Round 2로 진행한다.

---

### Round 2: 독립 리뷰 (code-reviewer)

Task tool을 사용하여 `code-reviewer` 에이전트를 호출한다.

```
Task(
  subagent_type: "code-reviewer",
  prompt: """
  ## 코드 리뷰 요청

  ### 변경 파일
  {Round 1 요약에서 받은 변경/추가 파일 목록}

  ### 원래 요구사항
  {사용자의 원래 요구사항}

  ### 지시사항
  - 위 변경 파일들을 모두 읽고 8가지 관점에서 리뷰한다
  - **반드시 1개 이상의 개선점을 식별한다** (아무리 잘 작성된 코드라도 개선할 부분은 있다)
  - 칭찬만 하지 않는다. 구체적인 개선 포인트를 반드시 제시한다
  - `flutter test`와 `flutter analyze` 결과를 확인한다
  - 완료 후 아래 형식으로 500토큰 이내 요약을 반환한다:

  ## 리뷰 결과

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
  - 권장 사항: [Approve / Approve with fixes / Request changes]
  """
)
```

**Sycophancy 방지**: "반드시 1개 이상 개선점 식별" 지시로 리뷰어가 무조건 승인하는 것을 방지한다.

---

### Round 3: Judge 판정 (메인 대화)

메인 대화가 Judge로서 리뷰 결과를 **독립적으로** 판정한다.
단순 다수결이 아닌 **증거 기반 판정**을 수행한다.

#### 판정 기준

리뷰어가 보고한 각 항목에 대해:

| 판정 | 조건 | 후속 행동 |
|------|------|-----------|
| AGREED | 해당 코드를 직접 읽고, 리뷰어의 지적이 타당하다고 판단 | 수정 대상에 포함 |
| DISAGREED | 해당 코드를 직접 읽고, 리뷰어의 지적이 과도하거나 부적절하다고 판단 | 수정 대상에서 제외, 사유 기록 |
| UNCERTAIN | 판단이 어려운 경우 | AskUserQuestion으로 사용자에게 확인 |

#### 판정 후 분기

```
if (AGREED인 CRITICAL 항목 존재):
    → Round 1로 복귀 (수정 지시 포함)
    → 반복 횟수 +1

elif (AGREED인 WARNING 항목 존재):
    → 수정 가치가 있는지 Judge가 판단
    → 수정 필요 시 → Round 1로 복귀
    → 수정 불필요 시 → 사용자에게 보고 후 완료

elif (SUGGESTION만 존재):
    → 사용자에게 리뷰 결과 보고
    → 완료
```

#### 판정 보고 형식

```markdown
## Judge 판정 결과

### Round N/3

#### AGREED (수정 진행)
- [항목] 사유: ...

#### DISAGREED (수정 불필요)
- [항목] 사유: ...

#### UNCERTAIN (사용자 확인 필요)
- [항목] 질문: ...

### 다음 행동
- [ ] Round 1 재실행 / 완료
```

---

## 종료 보고

모든 라운드 완료 후 사용자에게 최종 보고한다:

```markdown
## Dev-Review Cycle 완료

### 요구사항
{원래 요구사항}

### 실행 요약
- 총 반복: N회
- 변경 파일: [목록]
- 추가 파일: [목록]

### 리뷰 결과
- 최종 CRITICAL: 0건
- 최종 WARNING: N건 (수정됨/허용됨)
- SUGGESTION: N건 (보고)

### 검증
- flutter test: PASS/FAIL
- flutter analyze: PASS/FAIL

### DISAGREED 항목 (참고)
- [항목] Judge 판단 사유: ...
```

## 제약사항

- 각 에이전트는 **500토큰 이내 요약**만 반환 (Context 폭발 방지)
- Subagent는 1-level only (메인 대화가 orchestrator)
- MCP 도구는 포그라운드 실행만 사용
- 최대 3회 반복 후 강제 종료 (남은 항목은 사용자에게 보고)
