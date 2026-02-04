# Flutter Claude Code Skills & Agents 구축을 위한 Deep Research

## Prompt (요청)

Flutter로 제대로 개발을 하기 위해서 다음과 같은 skill과 agent를 만들려고해. 아래 내용에 맞게 스킬과 에이전트를 개발하기 위한 자료를 조사해줘.

- skills
  - Dart skills - Dart 문법을 아주 잘 알고 있고, Dart idiometic하면서 가독성 높고 효율적인 코드를 작성할 수 있는 스킬
  - Flutter - Flutter 문법을 아주 잘 알고 있고, Flutter Idiometic하면서 가독성 높고 효율적인 코드를 작성할 수 있는 스킬
  - TDD 스킬 - TDD 원칙에 따라 소프트웨어를 개발하는 스킬 (아주 엄격하게 TDD를 준수하도록 작성할것!!)
  - 코딩 스킬 - Clean Code 원칙에 따라 코드를 잘 작성할 수 있는 스킬
  - 소프트웨어 디자인 스킬 - DDD, Clean Architect, OOP, Design Pattern, SOLID 원칙에 맞춰서 소프트웨어 구조를 잡는 스킬
  - Code Review 스킬 - 작성된 코드를 Dart, Flutter, TDD, OOP, SOLID 원칙, 디자인 패턴적이 관련점에 비판적인 사고를 하며 전체 코드에 문제가 없는지 살피는 스킬
  - Secure Code 스킬 - OWASP 10 및 소프트웨어 개발 및 특히 Flutter를 통해 앱을 개발할때 주의해야하는 내용들을 담고 있는 스킬
- Agents
  - 개발자
    - 페르소나: Senior Flutter Developer
    - 스킬 : Dart, Flutter, TDD, Code Review, 코딩, 소프트웨어 디자인 스킬, Secure Code 스킬을 가지고 소프트웨어를 개발하는 개발자
  - 코드 리뷰어
    - 페르소나 : 이미 개발된 코드를 앞서 작성한 스킬을 가지고 아주 빡세게 리뷰하는 에이전트
    - 스킬 : 앞서 작성한 모든 스킬 사용

### 고려사항

- 클로드 창시자인 '보리스 체르니'의 유투브 영상, 블로그 글 등을 반드시 확인해서 Best Practice를 찾아줘.
- Flutter 개발자 중 유명한 사람들 중에 Claude Code를 통해 내가 하려고 하는 것과 같은 내용의 작업을 하는 사람들을 찾아서 관련 내용을 조사해줘.
- 클로드 코드의 공식 문서를 반드시 확인해줘.
- 클로드 코드의 블로그 문서들도 반드시 확인해줘.

---

## Response (조사 결과)

### Executive Summary

Claude Code의 Skills과 Agents(Subagents) 시스템을 활용하여 Flutter 전문 개발 환경을 구축하기 위한 심층 조사를 완료했습니다. 공식 문서, Boris Cherny(Claude Code 창시자)의 워크플로우, Andrea Bizzotto(Flutter GDE)의 실전 사용법, 커뮤니티의 Flutter expert subagent 예시 등을 종합했습니다. Skills는 `.claude/skills/<name>/SKILL.md` 형태로, Agents는 `.claude/agents/<name>.md` 형태로 작성하며, 각각 YAML frontmatter와 마크다운 본문으로 구성됩니다.

---

### Findings

#### 1. Claude Code Skills 구조 및 작성법

Skills는 `SKILL.md` 파일에 YAML frontmatter + 마크다운 지침으로 구성됩니다. **[Confirmed]**

**핵심 frontmatter 필드:**

| 필드 | 용도 |
|------|------|
| `name` | 스킬 이름 (`/name`으로 호출) |
| `description` | Claude가 자동 로드 판단에 사용 |
| `disable-model-invocation` | `true`면 사용자만 호출 가능 |
| `user-invocable` | `false`면 Claude만 자동 사용 (배경 지식용) |
| `allowed-tools` | 허용 도구 제한 |
| `context` | `fork`면 subagent에서 격리 실행 |
| `agent` | `context: fork` 시 사용할 agent 지정 |
| `skills` | (agents에서) preload할 skills 목록 |

**스킬 유형 2가지:**
- **Reference content**: 코딩 컨벤션, 스타일 가이드 등 (inline으로 대화에 주입)
- **Task content**: 배포, 커밋 등 단계별 작업 지침 (`context: fork`로 격리 실행 권장)

**스킬 파일 구조:**

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── template.md        # Template for Claude to fill in
├── examples/
│   └── sample.md      # Example output showing expected format
└── scripts/
    └── validate.sh    # Script Claude can execute
```

**스킬 저장 위치별 적용 범위:**

| Location | Path | Applies to |
|----------|------|------------|
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | 모든 프로젝트 |
| Project | `.claude/skills/<skill-name>/SKILL.md` | 현재 프로젝트만 |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | 플러그인 활성화된 곳 |

**호출 제어:**

| Frontmatter | 사용자 호출 | Claude 호출 | 로드 시점 |
|-------------|-----------|------------|----------|
| (기본값) | Yes | Yes | description 항상, 전체 내용은 호출 시 |
| `disable-model-invocation: true` | Yes | No | description 미로드, 사용자 호출 시만 |
| `user-invocable: false` | No | Yes | description 항상, 호출 시 전체 |

- **확신도**: [Confirmed]
- **출처**: [Claude Code 공식 Skills 문서](https://code.claude.com/docs/en/skills)
- **근거**: 공식 문서에서 직접 확인

---

#### 2. Claude Code Agents(Subagents) 구조

Agents는 `.claude/agents/<name>.md`에 작성하며, 각자 독립된 context window에서 실행됩니다. **[Confirmed]**

**핵심 frontmatter 필드:**

| 필드 | 용도 |
|------|------|
| `name` | 고유 식별자 (소문자, 하이픈) |
| `description` | Claude가 위임 판단에 사용 |
| `tools` | 허용 도구 목록 |
| `disallowedTools` | 차단 도구 목록 |
| `model` | `sonnet`, `opus`, `haiku`, `inherit` |
| `skills` | preload할 skills 목록 |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `hooks` | 라이프사이클 훅 |

**Agent가 Skills와 다른 점:**
- Agent는 **독립 context window** (대화 기록 안 보임)
- Agent는 **도구 접근 제한** 가능
- Agent는 **모델 선택** 가능 (haiku로 비용 절감 등)
- Skills의 `skills` 필드로 **Agent에 Skills를 preload** 가능

**Built-in Subagents:**

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| Explore | Haiku | Read-only | 파일 탐색, 코드 검색 |
| Plan | Inherit | Read-only | 계획 수립 전 리서치 |
| General-purpose | Inherit | All | 복잡한 멀티스텝 작업 |

**Agent 파일 예시:**

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

**Skills Preload 방법:**

```yaml
---
name: api-developer
description: Implement API endpoints following team conventions
skills:
  - api-conventions
  - error-handling-patterns
---

Implement API endpoints. Follow the conventions and patterns from the preloaded skills.
```

Subagent는 부모 대화의 skills를 자동 상속하지 않으므로, `skills` 필드에 명시적으로 나열해야 합니다.

- **확신도**: [Confirmed]
- **출처**: [Claude Code 공식 Subagents 문서](https://code.claude.com/docs/en/sub-agents)

---

#### 3. Boris Cherny의 Best Practices

Claude Code 창시자의 핵심 원칙들입니다. **[Confirmed]**

| 원칙 | 설명 |
|------|------|
| **Plan Mode 먼저** | Shift+Tab 2번으로 Plan Mode 진입 후 계획 합의 → auto-accept로 구현 |
| **검증이 최우선** | Claude에게 자기 작업을 검증할 방법 제공 (테스트, bash 명령) → 품질 2-3배 향상 |
| **모듈화된 에이전트** | "하나의 큰 에이전트"가 아니라 모듈화된 역할. 신뢰는 전문화+제약에서 나옴 |
| **CLAUDE.md 반복 개선** | 실수마다 추가, 주기적으로 편집하여 실수율 감소 |
| **파이프라인 워크플로** | 코딩을 단계(spec → draft → simplify → verify)로 나누고 각 단계에 다른 "mind" 적용 |
| **Hooks 활용** | PostToolUse hook으로 코드 포맷팅 자동 처리 |
| **병렬 세션** | 5개 Claude 터미널 + 5-10개 claude.ai 브라우저 세션 병렬 운영 |
| **Opus 4.5 사용** | "the best coding model I've ever used" — 느리지만 steering 적게 필요 |

**사용하는 subagents:**
- `code-simplifier`: 코드 완성 후 단순화
- `verify-app`: E2E 테스트용 상세 검증 지침

**핵심 철학:**
> "Most people ask: 'How do I get better outputs from AI?' Boris asks: 'How do I build a system where AI reliably produces what I need?'"

> "The best agents are the ones that can check and self-correct."

> "You don't trust; you instrument."

- **확신도**: [Confirmed]
- **출처**: [VentureBeat](https://venturebeat.com/technology/the-creator-of-claude-code-just-revealed-his-workflow-and-developers-are), [Boris Cherny Twitter Thread](https://twitter-thread.com/t/2007179832300581177), [Medium - 22 Tips](https://medium.com/@joe.njenga/boris-cherny-claude-code-creator-shares-these-22-tips-youre-probably-using-it-wrong-1b570aedefbe), [InfoQ](https://www.infoq.com/news/2026/01/claude-code-creator-workflow/), [Threads](https://www.threads.com/@boris_cherny/post/DUMZr4VElyb/)

---

#### 4. Andrea Bizzotto (Flutter GDE)의 Claude Code 활용

Flutter 커뮤니티에서 가장 영향력 있는 Claude Code + Flutter 사용자입니다. **[Confirmed]**

**핵심 접근법:**
- 빈 프로젝트에서 시작, **상세한 요구사항 스펙 문서** 먼저 작성 (specs/initial-requirements.md)
- `.claude/commands/`에 커스텀 명령 생성 (예: `update-plan-commit`)
- "Forget 'vibe coding'" — 기능, UI, 동작, 코드 스타일까지 명시적으로 작성
- DevContainer에서 Claude Code 실행하여 보안 확보
- Opus 4.5 with thinking 모델 사용 권장
- Sub-agents를 역할별로 조직: UI Agent, Logic Agent, Backend Agent, Test Agent

**모델 선택 가이드 (Andrea):**
- Haiku: 빠른 작업
- Sonnet: 빌드
- Opus: 폴리시

- **확신도**: [Confirmed]
- **출처**: [Build Flutter Apps FASTER with Claude Code Opus 4](https://codewithandrea.com/videos/build-flutter-apps-faster-claude-code-opus4/), [Free Crash Course](https://codewithandrea.com/emails/2025-06-25-claude-code/), [DevContainer Guide](https://codewithandrea.com/articles/run-ai-agents-inside-devcontainer/)

---

#### 5. Dart Idiomatic Coding Best Practices

Effective Dart 공식 가이드의 핵심 원칙들입니다. **[Confirmed]**

**네이밍 컨벤션:**
- `UpperCamelCase`: 클래스, enum, typedef, type parameter
- `lowerCamelCase`: 변수, 함수, 메서드, 파라미터
- `snake_case`: 파일명, 패키지명, 디렉토리명
- `///`: public API 문서화

**핵심 원칙:**
- **`final`/`const` 적극 사용**: `const` 위젯은 성능 + hot-reload에 유리
- **Null safety**: 기본 non-nullable, `?`로 명시적 nullable
- **Cascade (`..`) 연산자**: 같은 객체 연속 조작 시 사용
- **Extension methods**: 헬퍼 클래스 대체
- **Dart 3+ 패턴**: destructuring, pattern matching, sealed class
- **Wildcard `_`**: 미사용 콜백 파라미터에 사용 (Dart 3.7+)
- **불변 컬렉션 선호**, 글로벌 상태 최소화
- **Private member**: `_` 접두사 (라이브러리 수준 private)

**Flutter 특화:**
- `setState()` 남용 금지 — 불필요한 위젯 리빌드 유발
- `SizedBox` > `Container` (placeholder용) — const constructor
- 대규모 앱은 Provider, Riverpod, BLoC 등 상태관리 솔루션 사용
- `dart format` + `analysis_options.yaml` 린트 규칙 활용

**두 가지 핵심 테마:**
1. **Be consistent**: 코드가 달라 보이면, 의미적으로도 달라야 함
2. **Be brief**: 간결하게 작성

- **확신도**: [Confirmed]
- **출처**: [Effective Dart](https://dart.dev/effective-dart), [Effective Dart: Style](https://dart.dev/effective-dart/style), [Effective Dart: Design](https://dart.dev/effective-dart/design)

---

#### 6. Flutter TDD + Clean Architecture Best Practices

ResoCoder의 TDD Clean Architecture 코스가 Flutter 커뮤니티 표준입니다. **[Confirmed]**

**엄격한 TDD 프로세스 (Red-Green-Refactor):**

1. **Red**: 실패하는 테스트 먼저 작성
2. **Green**: 테스트 통과하는 최소 코드 작성
3. **Refactor**: 코드 품질 개선 (모든 테스트 통과 확인)

**핵심 규칙:**
- 테스트 대상 클래스 외 모든 의존성은 Mock 처리 (Mocktail 사용)
- `test/` 폴더 구조는 `lib/` 구조와 동일하게 유지
- 추상 클래스/인터페이스가 TDD에 매우 중요
- Model은 Entity를 extends (Entity에는 fromJson/toJson 없음)
- 커버리지: `flutter test --coverage`로 측정

**3-Layer Architecture:**

```
lib/
└── features/
    └── [feature]/
        ├── data/           # 데이터 레이어
        │   ├── datasources/    # Remote/Local data sources
        │   ├── models/         # fromJson/toJson 포함
        │   └── repositories/   # Repository 구현체
        ├── domain/         # 도메인 레이어 (Pure Dart)
        │   ├── entities/       # 비즈니스 엔티티
        │   ├── repositories/   # Repository 인터페이스
        │   └── usecases/       # 비즈니스 로직
        └── presentation/   # 프레젠테이션 레이어
            ├── pages/
            ├── providers/      # 상태 관리
            └── widgets/
```

**테스트 전략:**
- Unit tests: Domain layer (usecases, entities)
- Widget tests: Presentation layer
- Integration tests: 전체 플로우
- Golden tests: UI 스냅샷 비교

- **확신도**: [Confirmed]
- **출처**: [ResoCoder Flutter TDD Course](https://resocoder.com/flutter-clean-architecture-tdd/), [GitHub](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course), [TDD & Clean Architecture Guide](https://medium.com/@deadlogic/tdd-test-driven-development-and-clean-architecture-in-flutter-a1880048b09f)

---

#### 7. Flutter OWASP Security Best Practices

Talsec의 OWASP Mobile Top 10 for Flutter 시리즈가 가장 포괄적입니다. **[Confirmed]**

| OWASP Category | 핵심 대책 |
|----------------|----------|
| **M1: Improper Credential Usage** | `flutter_secure_storage` 사용, API 키 하드코딩 금지, BFF 패턴으로 서버 프록시 |
| **M2: Inadequate Supply Chain** | pub.dev 검증된 패키지만 사용, 의존성 최소화, 보안 코드 리뷰 |
| **M3: Insecure Auth/AuthZ** | OAuth/OIDC, 짧은 수명 토큰, 서버사이드 검증 필수, 비대칭 키 기반 바이오메트릭 |
| **M5: Insecure Communication** | TLS 필수, certificate pinning (`http_certificate_pinning`), FreeRASP 런타임 보호 |
| **M6: Inadequate Privacy** | 데이터 수집 최소화, `avoid_print` 린트 규칙, 사용자 동의 |

**Flutter 특화 보안 원칙:**
- `flutter_secure_storage`로 KeyChain(iOS)/Keystore(Android) 활용
- 코드 난독화 (obfuscation) 적용
- 루팅/탈옥 감지
- 민감 데이터 URL, 로그, plain preferences에 저장 금지
- CI 파이프라인에 모바일 보안 스캐너 추가 (MobSF 등)
- 주요 릴리스 전 펜테스트 수행

- **확신도**: [Confirmed]
- **출처**: [Talsec OWASP for Flutter M1](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m1-mastering-credential-security-in-flutter), [M2](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m2-inadequate-supply-chain-security-in-flutter), [M3](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m3-insecure-authentication-and-authorization-in-flutter), [M5](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m5-insecure-communication-for-flutter-and-dart), [HackerNoon](https://hackernoon.com/10-best-practices-for-securing-your-flutter-mobile-app-in-2025), [Flutter Security Docs](https://docs.flutter.dev/security)

---

#### 8. 커뮤니티 Flutter Expert Subagent 구조

VoltAgent의 awesome-claude-code-subagents에서 제공하는 Flutter expert가 좋은 참고 모델입니다. **[Likely]**

```yaml
name: flutter-expert
description: Expert Flutter specialist mastering Flutter 3+ with modern architecture patterns.
             Specializes in cross-platform development, custom animations, native integrations,
             and performance optimization with focus on creating beautiful, native-performance applications.
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
```

**8가지 체크리스트:**
1. Flutter 3+ 기능 효과적 활용
2. Null safety 유지
3. 80%+ 위젯 테스트 커버리지
4. 일관된 60 FPS 성능
5. 최적화된 번들 사이즈
6. 플랫폼 패리티
7. 접근성 구현
8. 우수한 코드 품질

**기술 아키텍처 도메인:**
- Clean architecture with feature-based structure
- State management (Provider, Riverpod 2.0, BLoC/Cubit, GetX, Redux, MobX)
- Widget composition patterns and render optimization
- Platform-specific features (iOS, Android Material You, platform channels)
- Custom animations and physics simulations
- Performance optimization
- Testing (widget, integration, golden tests)
- Native integrations (camera, location, biometrics, push notifications)

**개발 워크플로 3단계:**
1. Architecture Planning
2. Implementation Phase
3. Flutter Excellence (검증 및 최적화)

- **확신도**: [Likely]
- **출처**: [VoltAgent Flutter Expert](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/02-language-specialists/flutter-expert.md)

---

#### 9. Skills와 Agents의 조합 패턴 (Boris Cherny 방식)

Skills를 Agents에 preload하는 것이 공식 권장 패턴입니다. **[Confirmed]**

```yaml
# .claude/agents/developer.md
---
name: flutter-developer
skills:
  - dart-coding
  - flutter-patterns
  - tdd
  - clean-code
  - software-design
  - secure-code
---
```

이렇게 하면 Agent 시작 시 모든 Skills의 전체 내용이 context에 주입됩니다. Subagent는 부모 대화의 skills를 자동으로 상속하지 않으므로, 명시적으로 `skills` 필드에 나열해야 합니다.

- **확신도**: [Confirmed]
- **출처**: [Claude Code Subagents 문서 - Preload skills](https://code.claude.com/docs/en/sub-agents)

---

#### 10. Skills vs Prompts vs Projects vs MCP vs Subagents 비교

| 기준 | Skills | Prompts | Projects | Subagents | MCP |
|------|--------|---------|----------|-----------|-----|
| 지속성 | 여러 대화 | 단일 대화 | 프로젝트 내 | 세션 전체 | 지속적 연결 |
| 코드 포함 | 가능 | 불가 | 불가 | 가능 | 가능 |
| 로딩 방식 | 필요시 동적 | 매 턴 | 항상 | 호출시 | 항상 가용 |

**사용 시점:**
- **Skills**: 반복되는 전문 절차나 조직 워크플로우
- **Prompts**: 일회성 요청이나 대화형 지시
- **Projects**: 특정 이니셔티브의 배경 지식
- **Subagents**: 독립적 작업 처리와 도구 제한
- **MCP**: 외부 데이터 접근이나 비즈니스 도구 통합

- **확신도**: [Confirmed]
- **출처**: [Skills Explained (Claude Blog)](https://claude.com/blog/skills-explained)

---

### Comparisons

| 기준 | Skills (Reference) | Skills (Task + Fork) | Agents (Subagents) |
|------|-------------------|---------------------|-------------------|
| 실행 환경 | 메인 대화에 inline 주입 | 독립 context (fork) | 독립 context |
| 대화 기록 접근 | 있음 | 없음 | 없음 |
| 도구 제한 | `allowed-tools`로 제한 | `allowed-tools`로 제한 | `tools`/`disallowedTools` |
| 호출 방식 | Claude 자동 / `/name` | Claude 자동 / `/name` | Claude 자동 위임 / 명시 요청 |
| 모델 선택 | 불가 (메인 모델) | `agent` 필드로 지정 | `model` 필드로 지정 |
| Skills preload | N/A | N/A | `skills` 필드로 가능 |
| 용도 | 배경 지식, 컨벤션 | 독립 작업 실행 | 전문 역할 위임 |

**권장 구조**: Skills를 **Reference content**(배경 지식)로 작성하고, Agents에 preload하여 사용 — [Confirmed]

---

### 구현 권장 구조

조사 결과를 바탕으로 한 권장 파일 구조:

```
.claude/
├── skills/
│   ├── dart-coding/
│   │   └── SKILL.md          # Dart idiomatic coding 지침
│   ├── flutter-patterns/
│   │   └── SKILL.md          # Flutter idiomatic 패턴
│   ├── tdd/
│   │   └── SKILL.md          # 엄격한 TDD 프로세스
│   ├── clean-code/
│   │   └── SKILL.md          # Clean Code 원칙
│   ├── software-design/
│   │   └── SKILL.md          # DDD, Clean Architecture, SOLID
│   ├── code-review/
│   │   └── SKILL.md          # 코드 리뷰 체크리스트
│   └── secure-code/
│       └── SKILL.md          # OWASP + Flutter 보안
├── agents/
│   ├── flutter-developer.md  # 개발자 agent (위 skills preload)
│   └── code-reviewer.md      # 리뷰어 agent (read-only tools)
```

**Skills는 `user-invocable: false`로 설정**하여 배경 지식으로만 사용하고, Agents에서 `skills` 필드로 preload하는 것이 가장 효과적입니다.

**개발자 Agent**는 모든 도구 접근, **코드 리뷰어 Agent**는 `tools: Read, Grep, Glob, Bash`로 read-only 제한을 권장합니다.

---

### Edge Cases & Caveats

- **Context 크기 제한**: Skills 총 description이 15,000자(기본)를 초과하면 일부 skills가 제외됨. `SLASH_COMMAND_TOOL_CHAR_BUDGET` 환경변수로 조정 가능
- **Skills preload 시 token 소비**: Agent에 많은 skills를 preload하면 context가 빠르게 소비됨. SKILL.md는 500줄 이하 권장
- **Subagent 중첩 불가**: Subagent는 다른 subagent를 spawn할 수 없음. 체이닝은 메인 대화에서 수행
- **Boris Cherny "YouTube 영상"**: 특정 YouTube 영상은 찾지 못했음. 주요 컨텐츠는 X(Twitter) 스레드와 Threads 게시물로 공유됨

---

### Contradictions Found

- **모순 없음**: 공식 문서, Boris Cherny의 팁, 커뮤니티 사례 모두 일관된 방향을 제시. Skills는 reference content로, Agents는 전문 역할 위임으로 사용하는 패턴이 공통.

---

### Sources

1. [Claude Code Skills 공식 문서](https://code.claude.com/docs/en/skills) — 공식 문서
2. [Claude Code Subagents 공식 문서](https://code.claude.com/docs/en/sub-agents) — 공식 문서
3. [Introducing Agent Skills (Claude Blog)](https://claude.com/blog/skills) — 공식 블로그
4. [Skills Explained (Claude Blog)](https://claude.com/blog/skills-explained) — 공식 블로그
5. [Boris Cherny Workflow (VentureBeat)](https://venturebeat.com/technology/the-creator-of-claude-code-just-revealed-his-workflow-and-developers-are) — 1차 자료
6. [Boris Cherny Twitter Thread](https://twitter-thread.com/t/2007179832300581177) — 1차 자료
7. [Boris Cherny 22 Tips (Medium)](https://medium.com/@joe.njenga/boris-cherny-claude-code-creator-shares-these-22-tips-youre-probably-using-it-wrong-1b570aedefbe) — 기술 블로그
8. [Boris Cherny Threads 게시물](https://www.threads.com/@boris_cherny/post/DUMZr4VElyb/) — SNS/1차 자료
9. [Claude Code Team Setup (Dev Genius)](https://blog.devgenius.io/the-claude-code-team-just-revealed-their-setup-pay-attention-4e5d90208813) — 기술 블로그
10. [ChernyCode GitHub](https://github.com/meleantonio/ChernyCode) — 커뮤니티
11. [Andrea Bizzotto - Build Flutter Apps FASTER](https://codewithandrea.com/videos/build-flutter-apps-faster-claude-code-opus4/) — 1차 자료
12. [Andrea Bizzotto - DevContainer Guide](https://codewithandrea.com/articles/run-ai-agents-inside-devcontainer/) — 1차 자료
13. [Andrea Bizzotto - Riverpod Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/) — 1차 자료
14. [Effective Dart (dart.dev)](https://dart.dev/effective-dart) — 공식 문서
15. [Effective Dart: Style](https://dart.dev/effective-dart/style) — 공식 문서
16. [Effective Dart: Design](https://dart.dev/effective-dart/design) — 공식 문서
17. [ResoCoder Flutter TDD Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/) — 1차 자료
18. [ResoCoder TDD GitHub](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course) — 1차 자료
19. [Talsec OWASP Top 10 for Flutter M1](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m1-mastering-credential-security-in-flutter) — 기술 블로그
20. [Talsec OWASP M2](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m2-inadequate-supply-chain-security-in-flutter) — 기술 블로그
21. [Talsec OWASP M3](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m3-insecure-authentication-and-authorization-in-flutter) — 기술 블로그
22. [Talsec OWASP M5](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m5-insecure-communication-for-flutter-and-dart) — 기술 블로그
23. [Flutter Security Docs](https://docs.flutter.dev/security) — 공식 문서
24. [HackerNoon Flutter Security 2025](https://hackernoon.com/10-best-practices-for-securing-your-flutter-mobile-app-in-2025) — 기술 블로그
25. [VoltAgent Flutter Expert Subagent](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/02-language-specialists/flutter-expert.md) — 커뮤니티
26. [Awesome Claude Code Subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) — 커뮤니티
27. [Flutter Riverpod Clean Architecture Template](https://github.com/ssoad/flutter_riverpod_clean_architecture) — 커뮤니티
28. [Rémy Baudet - Flutter + Claude Code + Clean Architecture](https://medium.com/@remy.baudet/building-a-flutter-app-with-claude-code-and-feature-first-clean-architecture-fa89fe5aa58b) — 기술 블로그
29. [Claude Code Customization Guide (alexop.dev)](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/) — 기술 블로그
30. [Flutter Create with AI (docs.flutter.dev)](https://docs.flutter.dev/ai/create-with-ai) — 공식 문서

---

### Research Metadata

- 검색 쿼리 수: 10 (일반 8 + SNS 2)
- 수집 출처 수: 30
- 출처 유형 분포: 공식 문서 7, 1차 자료 7, 기술 블로그 10, 커뮤니티 5, SNS 1
- 확신도 분포: Confirmed 9, Likely 1, Uncertain 0, Unverified 0
- SNS 출처: Reddit 0건 (관련 스레드 미발견), X/Threads 2건
- SNS 접근 방법: WebSearch site: operator
- 조사 일시: 2026-02-04
