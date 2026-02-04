# Flutter Claude Code Agents & Skills 구현 문서

## 개요

Claude Code의 Skills과 Agents 시스템을 활용하여 Flutter 전문 개발 환경을 구축했다.
7개 Skills + 2개 Agents + 1개 Orchestration Skill로 구성되며,
TDD 기반 개발-리뷰 사이클을 자동화하는 멀티 에이전트 오케스트레이션을 포함한다.

---

## 디렉토리 구조

```
.claude/
├── agents/
│   ├── flutter-developer.md    # 개발자 에이전트
│   └── code-reviewer.md        # 코드 리뷰어 에이전트
└── skills/
    ├── dart-coding/SKILL.md          # Dart 코딩 컨벤션
    ├── flutter-patterns/SKILL.md     # Flutter 패턴
    ├── tdd/SKILL.md                  # TDD 프로세스
    ├── clean-code/SKILL.md           # Clean Code 원칙
    ├── software-design/SKILL.md      # 소프트웨어 설계
    ├── code-review/SKILL.md          # 코드 리뷰 체크리스트
    ├── secure-code/SKILL.md          # 보안 코딩
    └── dev-review-cycle/SKILL.md     # 개발-리뷰 오케스트레이션 (user-invocable)
```

---

## Skills (7개, Reference Content)

모든 Skills는 `user-invocable: false`로 설정되어 있으며,
Agent에 preload되어 **100% 로딩**이 보장된다 (자동 발동 20% 문제 회피).

### 1. dart-coding

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/dart-coding/SKILL.md` |
| **역할** | Dart Idiomatic 코딩 컨벤션 |
| **기반** | Effective Dart 공식 가이드 |
| **주요 내용** | 네이밍 컨벤션, `final`/`const` 사용, Null Safety, Dart 3+ 패턴 (sealed class, pattern matching, records), async/await, Stream, 에러 처리, import 순서 |

### 2. flutter-patterns

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/flutter-patterns/SKILL.md` |
| **역할** | Flutter Idiomatic 패턴 |
| **기반** | Flutter 공식 컨벤션 |
| **주요 내용** | Widget 조합, `const` constructor, `setState` 최소화, Riverpod (watch/read 구분), `AsyncValue.when()`, `ListView.builder`, Theme 사용, dispose 리소스 해제, 접근성 |

### 3. tdd

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/tdd/SKILL.md` |
| **역할** | 엄격한 TDD 프로세스 |
| **기반** | Red-Green-Refactor 원칙 |
| **주요 내용** | 절대 원칙 4가지 (테스트 없이 프로덕션 코드 금지), AAA 패턴, 레이어별 테스트 전략 (Domain/Data/Presentation), Mocktail 규칙, 테스트 파일 구조 미러링, 개발 순서 (Entity → UseCase → Model → DataSource → Repository → Provider → Widget) |

### 4. clean-code

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/clean-code/SKILL.md` |
| **역할** | Clean Code 원칙 |
| **기반** | Robert C. Martin의 Clean Code (Dart/Flutter 적응) |
| **주요 내용** | 의미있는 이름, 작은 함수 (< 20줄), 파라미터 3개 이하, 매직 넘버 금지, DRY, 주석은 "왜"만 설명 |

### 5. software-design

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/software-design/SKILL.md` |
| **역할** | 소프트웨어 설계 원칙 |
| **기반** | DDD, Clean Architecture, OOP, Design Patterns, SOLID |
| **주요 내용** | 레이어 의존성 규칙 (Presentation → Domain ← Data), Entity vs Model 분리, UseCase 단일 책임, Repository 패턴, Strategy 패턴 (복습 주기) |

### 6. code-review

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/code-review/SKILL.md` |
| **역할** | 코드 리뷰 체크리스트 |
| **기반** | 10가지 관점 종합 리뷰 |
| **주요 내용** | Dart Idiomatic / Flutter 패턴 / TDD / OOP / SOLID / Clean Architecture / Design Pattern / 코드 품질 / 성능 / 보안 검사, CRITICAL > WARNING > SUGGESTION 3단계 분류 |

### 7. secure-code

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/secure-code/SKILL.md` |
| **역할** | 보안 코딩 원칙 |
| **기반** | OWASP Mobile Top 10 + Flutter 특화 |
| **주요 내용** | 하드코딩 시크릿 금지, `flutter_secure_storage` 사용, 입력 검증, 로그에 민감 정보 금지, HTTPS 강제 |

---

## Agents (2개)

### 1. flutter-developer

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/agents/flutter-developer.md` |
| **페르소나** | Senior Flutter Developer (10년+ 경험) |
| **model** | opus |
| **tools** | Read, Write, Edit, Bash, Glob, Grep |
| **preload skills** | dart-coding, flutter-patterns, tdd, clean-code, software-design, code-review, secure-code (전체 7개) |

**워크플로우:**

```
Phase 1: Understand (요구사항 분석, 코드베이스 탐색)
    ↓
Phase 2: Plan (테스트 가능한 단위로 분해, 레이어별 계획)
    ↓
Phase 3: Implement (TDD Red-Green-Refactor 반복)
    ↓
Phase 4: Verify (flutter test + flutter analyze + self-review)
```

**개발 순서 (레이어별):**

```
1. Entity (Domain)         — test → implement
2. Repository Interface    — interface only
3. UseCase (Domain)        — test → implement
4. Model (Data)            — test → implement
5. DataSource (Data)       — test → implement
6. Repository Impl (Data)  — test → implement
7. Provider (Presentation) — test → implement
8. Widget/Page             — test → implement
```

**코드 품질 기준:**

- `///` doc comments (public API)
- `final` / `const` 사용
- 함수 20줄 이하
- 파라미터 3개 이하
- 중첩 2단계 이하
- `print()` 금지

### 2. code-reviewer

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/agents/code-reviewer.md` |
| **페르소나** | Elite Code Reviewer (수천 개 Flutter 앱 리뷰 경험) |
| **model** | opus |
| **tools** | Read, Grep, Glob, Bash (**Write/Edit 없음 — 읽기 전용**) |
| **preload skills** | dart-coding, flutter-patterns, tdd, clean-code, software-design, code-review, secure-code (전체 7개) |

**리뷰 프로세스:**

```
Step 1: Scope Identification (git diff로 변경 파일 식별)
    ↓
Step 2: Architecture Audit (의존성 규칙 위반 검사)
    ↓
Step 3: Detailed Code Review (8가지 관점)
    ↓
Step 4: Test Verification (flutter test + flutter analyze)
    ↓
Step 5: Report Generation (구조화된 리포트)
```

**8가지 리뷰 관점:**

| # | 관점 | 핵심 검사 항목 |
|---|------|---------------|
| A | Dart Idiomatic | 네이밍, final/const, null safety, Dart 3+ 패턴 |
| B | Flutter Patterns | const constructor, setState, Riverpod, AsyncValue |
| C | TDD Compliance | 모든 파일에 대응 테스트 존재 여부, AAA 패턴, 엣지 케이스 |
| D | OOP & SOLID | SRP, OCP, LSP, ISP, DIP |
| E | Clean Architecture | 의존성 규칙, Entity vs Model, UseCase 단일 책임 |
| F | Design Pattern | 적절한 패턴 사용, 과도한 패턴 적용 여부 |
| G | Clean Code | 함수 크기, 파라미터 수, 매직 넘버, DRY |
| H | Security | 하드코딩 시크릿, secure storage, 입력 검증, 로그 |

**리포트 분류:**

| 심각도 | 기준 |
|--------|------|
| **CRITICAL** | 버그, 보안 취약점, 데이터 손실, 아키텍처 위반 |
| **WARNING** | SOLID 위반, 누락된 테스트, 성능 이슈 |
| **SUGGESTION** | 네이밍, 스타일, const 사용, 패턴 개선 |

---

## Orchestration Skill: dev-review-cycle

| 항목 | 내용 |
|------|------|
| **파일** | `.claude/skills/dev-review-cycle/SKILL.md` |
| **user-invocable** | `true` |
| **호출** | `/dev-review-cycle <요구사항>` |
| **역할** | flutter-developer + code-reviewer 오케스트레이션 |

### 적용 패턴

| 패턴 | 출처 | 적용 방식 |
|------|------|-----------|
| **Tool-MAD** | ICLR 2025 | developer(생산) + reviewer(검증) + 메인 대화(Judge) |
| **Boris Cherny** | Claude Code 창시자 | Plan → Execute → Verify, Counter-Review로 검증 |
| **ICLR 2025** | 학술 연구 | 전문화된 이질적 에이전트, 증거 기반 Judge |
| **Sycophancy 방지** | CONSENSAGENT | reviewer에 "반드시 1개+ 개선점 식별" 강제 |
| **Context 관리** | Tiered Report | 각 에이전트 500토큰 이내 요약만 반환 |

### 4 Round 프로토콜

```
┌─────────────────────────────────────────────────────────────────┐
│  Round 0: 요구사항 분석 (메인 대화)                               │
│                                                                 │
│  - sequential-thinking MCP로 요구사항 분석                       │
│  - Explore agent로 영향 범위 파악                                │
│  - 구현 계획 수립                                                │
│  - 핵심 질문 → AskUserQuestion                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
          ┌────────────────▼────────────────┐
          │  iteration = 0, max = 3         │
          └────────────────┬────────────────┘
                           │
  ┌────────────────────────▼──────────────────────────────────┐
  │                                                           │
  │  Round 1: 개발 ─── Task(flutter-developer)                │
  │  - TDD Red-Green-Refactor 실행                            │
  │  - flutter test + flutter analyze                         │
  │  - 500토큰 이내 구현 요약 반환                              │
  │                         │                                 │
  │                         ▼                                 │
  │  Round 2: 독립 리뷰 ─── Task(code-reviewer)               │
  │  - 8가지 관점 코드 리뷰                                    │
  │  - "반드시 1개+ 개선점 식별" (sycophancy 방지)              │
  │  - CRITICAL / WARNING / SUGGESTION 분류                   │
  │  - 500토큰 이내 리뷰 요약 반환                              │
  │                         │                                 │
  │                         ▼                                 │
  │  Round 3: Judge 판정 ─── 메인 대화                         │
  │  - 코드를 직접 읽고 증거 기반 판정                           │
  │  - AGREED: 수정 필요 → Round 1 재실행                      │
  │  - DISAGREED: 리뷰어 지적 기각 + 사유 기록                  │
  │  - UNCERTAIN: AskUserQuestion으로 사용자 확인               │
  │                         │                                 │
  │          CRITICAL 있음?──YES──→ Round 1 (iter++)           │
  │                NO               iter < 3?                 │
  │                │                  NO → 강제 종료            │
  │          완료 보고                                          │
  └───────────────────────────────────────────────────────────┘
```

### 조기 종료 조건

3가지 조건이 **모두** 충족될 때:

1. CRITICAL 0건
2. `flutter test` PASS
3. `flutter analyze` PASS

### 3자 분리 아키텍처

```
 Developer (생산자)        Reviewer (검증자)         Judge (판정자)
 ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
 │ flutter-developer │    │ code-reviewer    │    │ 메인 대화         │
 │                  │    │                  │    │                  │
 │ Tools:           │    │ Tools:           │    │ Tools:           │
 │  R/W/Edit/Bash   │    │  R only (Grep,   │    │  All             │
 │  Glob/Grep       │    │  Glob, Bash)     │    │                  │
 │                  │    │                  │    │                  │
 │ 역할:            │    │ 역할:            │    │ 역할:            │
 │  코드 작성        │    │  코드 읽기 전용   │    │  증거 기반 판정   │
 │  TDD 실행        │    │  8관점 리뷰      │    │  독립 검증        │
 │  테스트 실행      │    │  개선점 강제 식별  │    │  최종 결정        │
 └────────┬─────────┘    └────────┬─────────┘    └────────┬─────────┘
          │                      │                       │
          │  500토큰 요약         │  500토큰 요약          │
          └──────────────────────┴───────────────────────┘
                        Context 관리
```

### Claude Code 제약 반영

| 제약 | 대응 |
|------|------|
| Subagent 1-level only | 메인 대화가 orchestrator 역할 수행 |
| Context 폭발 | 각 에이전트에 "500토큰 이내 요약" 지시 |
| MCP 도구 제한 | 포그라운드 실행만 사용 |
| Skills 자동 발동률 20% | Agent에 skills preload (100% 보장) |
| 무한 루프 위험 | 최대 3회 반복 강제 종료 |

---

## 설계 의사결정 기록

### 1. Skills를 Agent에 preload하는 이유

Skills의 자동 발동률이 ~20%로 매우 낮다 (LLM 추론 기반 비결정적 발동).
Agent의 `skills:` 필드에 명시적으로 preload하면 **100% 로딩이 보장**된다.
따라서 모든 Skills는 `user-invocable: false`로 설정하고 Agent를 통해서만 사용한다.

### 2. Reviewer를 읽기 전용으로 제한하는 이유

Reviewer가 코드를 수정하면 "생산자 = 검증자"가 되어 독립적 리뷰가 불가능하다.
Write/Edit 도구를 제거하여 **관찰만 가능한 검증자** 역할을 강제한다.

### 3. Judge를 별도 에이전트가 아닌 메인 대화로 하는 이유

Claude Code의 Subagent는 1-level만 지원한다.
메인 대화 → developer (subagent), 메인 대화 → reviewer (subagent)는 가능하지만,
메인 대화 → judge → developer (2-level)는 불가능하다.
따라서 메인 대화 자체가 Judge 역할을 겸한다.

### 4. "반드시 1개+ 개선점 식별" 지시의 이유

LLM은 sycophancy(아첨) 경향이 있어, 코드에 문제가 있어도 "잘 작성되었습니다"로 넘어가는 경우가 많다.
CONSENSAGENT 패턴에서 차용하여, reviewer에게 개선점 식별을 **강제**함으로써 실질적인 리뷰를 유도한다.

### 5. 500토큰 요약 제한의 이유

Subagent의 전체 출력이 메인 대화 context에 포함되면 급격히 context가 소모된다.
Tiered Report 패턴을 적용하여, 핵심 정보만 담은 요약으로 context 효율을 유지한다.

---

## 참고 자료

- [Claude Code 공식 문서 - Skills & Agents](https://docs.anthropic.com/en/docs/claude-code)
- [Boris Cherny (Claude Code 창시자) - 워크플로우](https://www.youtube.com/@anthropic)
- [Scott Spence - Skills 발동률 분석](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably)
- [ICLR 2025 - Tool-MAD: Multi-Agent Debate](https://arxiv.org/abs/2504.07824)
- [CONSENSAGENT - Sycophancy 방지 패턴](https://arxiv.org/abs/2505.00662)
- [flutter-claude-code-skills-agents-research.md](./flutter-claude-code-skills-agents-research.md) — 초기 조사 자료
- [claude-code-skills-invocation-rate-research.md](./claude-code-skills-invocation-rate-research.md) — 발동률 문제 조사
