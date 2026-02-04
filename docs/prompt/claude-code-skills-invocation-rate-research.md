# Claude Code Skills 발동률 문제 원인과 해결책 Deep Research

## Prompt (요청)

스킬의 발동률이 20% 정도 밖에 안된다는 보고가 있는데 왜 그런지와 어떻게 하면 해결 할 수 있는지 조사해줘.

---

## Response (조사 결과)

### Executive Summary

Claude Code Skills의 자동 발동률이 약 **20%**에 불과하다는 보고는 사실이며, 이는 구조적 원인에 기반합니다. Skills의 자동 발동은 **LLM의 텍스트 추론**에 전적으로 의존하며, 알고리즘적 라우팅이 없습니다. 주요 원인은 (1) description 매칭의 비결정적 특성, (2) 15,000자 context budget 초과로 인한 skills 누락, (3) 캐싱/로딩 버그입니다. 가장 효과적인 해결책은 **Skills를 Agent에 preload하여 사용하는 것**(100% 로딩 보장)이며, 자동 발동에 의존하지 않는 것이 권장됩니다.

---

### Findings

#### 1. 20% 발동률은 실증적으로 검증된 수치다

Scott Spence가 체계적으로 테스트한 결과, 단순한 skill description만으로는 **20% 발동률**이 측정되었습니다. 이는 Claude가 skill을 "배경음"처럼 취급하여 무시하고 직접 구현으로 넘어가기 때문입니다. **[Confirmed]**

| 방식 | 발동률 | 특징 |
|------|--------|------|
| 단순 description만 | **20%** | 신뢰 불가 |
| Hook 기반 강제 지시 | **50%** | 개선되나 불안정 |
| LLM Eval Hook | **80%** | 변동성 있음 (특정 케이스 0%) |
| Forced Eval Hook | **84%** | 가장 일관됨 |
| Agent에 skills preload | **100%** | 발동이 아닌 주입 방식 |

- **확신도**: [Confirmed]
- **출처**: [Scott Spence - How to Make Skills Activate Reliably](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably), [Skills Don't Auto-Activate](https://scottspence.com/posts/claude-code-skills-dont-auto-activate)

---

#### 2. 근본 원인: LLM 추론 기반의 비결정적 발동 메커니즘

Skills 발동은 **알고리즘이 아니라 LLM의 언어 이해**에 전적으로 의존합니다. Claude는 `<available_skills>` 목록에서 description을 읽고 사용자 의도와 매칭을 "추론"합니다. 이는 본질적으로 비결정적(non-deterministic)입니다. **[Confirmed]**

작동 방식:
```
사용자 요청 → Claude가 <available_skills> 목록 확인
           → description과 사용자 의도를 LLM 추론으로 비교
           → 매칭 판단 (비결정적) → Skill 호출 또는 무시
```

> "Claude reads this list and uses its native language understanding to match your intent against the skill descriptions. There is no algorithmic skill selection."

- **확신도**: [Confirmed]
- **출처**: [Lee Han Chung - Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/), [paddo.dev - Controllability Problem](https://paddo.dev/blog/claude-skills-controllability-problem/)

---

#### 3. 15,000자 Context Budget 초과로 Skills가 아예 보이지 않음

`<available_skills>` 섹션은 기본 **15,000자(~4,000 토큰)** 제한이 있습니다. 이를 초과하면 skills가 목록에서 제외되며, Claude는 "시스템 프롬프트에 나열되지 않은 skill은 절대 사용하지 말 것"이라는 지시를 받으므로 **누락된 skill은 영구적으로 접근 불가**합니다. **[Confirmed]**

63개 설치된 skills 중 42개만 표시되고 21개(33%)가 숨겨진 사례가 보고되었습니다.

각 skill은 약 **109자의 XML 오버헤드 + description 길이**를 소비합니다.

| Skills 수 | 권장 description 길이 |
|-----------|---------------------|
| 60+ | 130자 이하 |
| 40-60 | 150자 이하 |
| 20-40 | 200자 이하 |
| 10 이하 | 제한 없음 (총합 15,000자 이내) |

**환경변수로 제한 증가 가능:**
```bash
SLASH_COMMAND_TOOL_CHAR_BUDGET=30000 claude
```

- **확신도**: [Confirmed]
- **출처**: [fsck.com - Skills Not Triggering](https://blog.fsck.com/2025/12/17/claude-code-skills-not-triggering/), [GitHub Issue #13099](https://github.com/anthropics/claude-code/issues/13099)

---

#### 4. 알려진 버그들: 캐싱, 디스커버리, Prettier 문제

Skills가 아예 로드되지 않는 기술적 버그들이 다수 보고되었습니다. **[Confirmed]**

| 버그 | 원인 | 해결책 |
|------|------|--------|
| Skills 미발견 | `~/.claude/skills/` 경로의 SKILL.md 미인식 | 세션 재시작, `/agents` 실행 |
| 캐싱 문제 (macOS) | 오래된 캐시에서 읽음, 최신 SKILL.md 무시 | 세션 재시작 |
| 권한 문제 (Linux) | `/tmp/claude/` 쓰기 권한 부재 | `chown` 으로 권한 변경 |
| Prettier 포맷팅 | YAML frontmatter 깨짐 | `# prettier-ignore` 추가 또는 단일 줄 description |
| 중복 로딩 (Plugin) | Plugin skills가 2.2배 예산 소비 | Plugin 최소화 |

- **확신도**: [Confirmed]
- **출처**: [GitHub Issues #11266](https://github.com/anthropics/claude-code/issues/11266), [#17417](https://github.com/anthropics/claude-code/issues/17417), [#21428](https://github.com/anthropics/claude-code/issues/21428), [#22081](https://github.com/anthropics/claude-code/issues/22081), [Scott Spence - Skills Not Recognised](https://scottspence.com/posts/claude-code-skills-not-recognised)

---

#### 5. `user-invocable: false` Skills는 자동 발동에 특히 취약하다

`user-invocable: false`로 설정된 skills는 `/` 메뉴에서 숨겨지지만, Claude가 자동 발동하도록 의도된 것입니다. 그러나 이 설정은 **실제 발동률 향상에 기여하지 않습니다** — description 매칭에만 의존하기 때문입니다. **[Likely]**

현재 프로젝트의 7개 skills가 모두 `user-invocable: false`로 설정되어 있어, 자동 발동에만 의존하면 20% 발동률 문제에 직면할 수 있습니다.

- **확신도**: [Likely]
- **출처**: [공식 Skills 문서](https://code.claude.com/docs/en/skills), [GitHub Issue #19141](https://github.com/anthropics/claude-code/issues/19141)

---

#### 6. 가장 확실한 해결책: Agent에 Skills Preload

Agent의 `skills` 필드로 preload하면 **skills 전체 내용이 agent 시작 시 context에 주입**되므로, 발동 여부와 무관하게 **100% 로딩이 보장**됩니다. 이는 자동 발동 메커니즘을 완전히 우회합니다. **[Confirmed]**

```yaml
# .claude/agents/flutter-developer.md
---
skills:
  - dart-coding
  - flutter-patterns
  - tdd
  # ...
---
```

> "The full content of each skill is injected into the subagent's context, not just made available for invocation."

현재 프로젝트의 `flutter-developer.md`와 `code-reviewer.md`가 이미 이 방식을 사용하고 있으므로, **agent를 통해 호출하면 발동률 문제를 회피**할 수 있습니다.

- **확신도**: [Confirmed]
- **출처**: [Claude Code Subagents 문서](https://code.claude.com/docs/en/sub-agents), [Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)

---

#### 7. 대안 해결책: CLAUDE.md에 핵심 규칙 인라인

CLAUDE.md는 **항상 로드**되므로 발동률 문제가 없습니다. 가장 중요한 규칙은 skills가 아닌 CLAUDE.md에 직접 작성하는 것이 안정적입니다. 단, CLAUDE.md가 너무 길어지면 instruction-following 품질이 저하됩니다 (150-200개 instruction이 한계). **[Confirmed]**

- **확신도**: [Confirmed]
- **출처**: [gend.co - Skills and CLAUDE.md Guide](https://www.gend.co/blog/claude-skills-claude-md-guide), [alexop.dev - Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)

---

### Comparisons: 해결 방법 비교

| 방법 | 발동률 | 복잡도 | 비용 | 권장도 |
|------|--------|--------|------|--------|
| description만 의존 | 20% | 낮음 | 없음 | 비권장 |
| CLAUDE.md에 참조 추가 | 40-50% | 낮음 | 없음 | 보조 수단 |
| Hook 기반 강제 발동 | 50-84% | 높음 | 약간 | 특수 케이스 |
| `/skill-name` 수동 호출 | 100% | 없음 | 없음 | 권장 (task skills) |
| **Agent에 preload** | **100%** | 낮음 | 없음 | **최우선 권장** |
| CLAUDE.md 인라인 | 100% | 낮음 | context 소비 | 핵심 규칙만 |

**권장**: Agent에 skills preload 방식 — [Confirmed]

---

### 현재 프로젝트 적용 분석

현재 프로젝트의 skills/agents 구성을 분석하면:

**문제 없는 부분:**
- `flutter-developer` agent와 `code-reviewer` agent에 7개 skills가 모두 preload되어 있음
- Agent를 통해 호출하면 100% skills 내용이 context에 주입됨

**잠재적 문제:**
- 7개 skills가 모두 `user-invocable: false`로 설정되어 있어, **메인 대화에서는 자동 발동에 의존**해야 함
- 메인 대화에서 agent 없이 직접 코드를 작성하면 skills가 적용되지 않을 수 있음 (20% 발동률)

**권장 조치:**
1. `flutter-developer` agent 사용을 명시적으로 요청하거나, CLAUDE.md에 "코드 작성 시 flutter-developer agent를 사용할 것"이라는 지침 추가
2. 가장 중요한 규칙(TDD 필수, Clean Architecture 의존성 규칙)은 CLAUDE.md에도 인라인으로 추가

---

### Edge Cases & Caveats

- **Agent preload 시 context 소비**: 7개 skills 전체가 주입되면 상당한 context를 소비함. SKILL.md는 500줄 이하 권장
- **Agent는 다른 agent를 spawn할 수 없음**: flutter-developer agent가 code-reviewer agent를 호출할 수 없음. 체이닝은 메인 대화에서만 가능
- **`SLASH_COMMAND_TOOL_CHAR_BUDGET` 증가의 부작용**: 30,000으로 늘리면 system prompt가 커져 전체 응답 품질에 영향 가능
- **LLM instruction-following 한계**: system prompt에 이미 ~50개 instruction이 있어, skills/CLAUDE.md 추가 시 총 150-200개 한계에 주의

---

### Contradictions Found

- **공식 문서 vs 실제**: 공식 문서는 "Claude uses skills when relevant"이라고 설명하지만, 실제 발동률은 20%에 불과 → 미해결 (공식적으로 인정되지 않음)
- **`user-invocable: false` 의도 vs 실제**: 이 설정은 "Claude만 자동 호출"을 의도하지만, 자동 호출 자체가 비신뢰적 → 미해결

---

### Sources

1. [Scott Spence - How to Make Claude Code Skills Activate Reliably](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably) — 기술 블로그 (실증 테스트)
2. [Scott Spence - Claude Code Skills Don't Auto-Activate](https://scottspence.com/posts/claude-code-skills-dont-auto-activate) — 기술 블로그
3. [Scott Spence - Claude Code Skills Not Recognised](https://scottspence.com/posts/claude-code-skills-not-recognised) — 기술 블로그
4. [fsck.com - Claude Code Skills Not Triggering](https://blog.fsck.com/2025/12/17/claude-code-skills-not-triggering/) — 기술 블로그
5. [Lee Han Chung - Claude Agent Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) — 1차 자료 (리버스 엔지니어링)
6. [paddo.dev - Claude Skills Controllability Problem](https://paddo.dev/blog/claude-skills-controllability-problem/) — 기술 블로그
7. [Claude Code Skills 공식 문서](https://code.claude.com/docs/en/skills) — 공식 문서
8. [Claude Code Subagents 공식 문서](https://code.claude.com/docs/en/sub-agents) — 공식 문서
9. [GitHub Issue #19308 - Skills Systematically Ignored](https://github.com/anthropics/claude-code/issues/19308) — 커뮤니티
10. [GitHub Issue #13099 - Document Character Budget](https://github.com/anthropics/claude-code/issues/13099) — 커뮤니티
11. [GitHub Issue #11266 - Skills Not Auto-Discovered](https://github.com/anthropics/claude-code/issues/11266) — 커뮤니티
12. [GitHub Issue #17417 - Skills Not Loading](https://github.com/anthropics/claude-code/issues/17417) — 커뮤니티
13. [GitHub Issue #21428 - Skills Caching Issues](https://github.com/anthropics/claude-code/issues/21428) — 커뮤니티
14. [GitHub Issue #22081 - Skills Not Recognized](https://github.com/anthropics/claude-code/issues/22081) — 커뮤니티
15. [GitHub Issue #19141 - user-invocable vs disable-model-invocation](https://github.com/anthropics/claude-code/issues/19141) — 커뮤니티
16. [gend.co - Claude Skills and CLAUDE.md Guide](https://www.gend.co/blog/claude-skills-claude-md-guide) — 기술 블로그
17. [alexop.dev - Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/) — 기술 블로그

---

### Research Metadata

- 검색 쿼리 수: 7 (일반 6 + SNS 1)
- 수집 출처 수: 17
- 출처 유형 분포: 공식 문서 2, 1차 자료 1, 기술 블로그 7, 커뮤니티(GitHub Issues) 7
- 확신도 분포: Confirmed 6, Likely 1, Uncertain 0, Unverified 0
- SNS 출처: Reddit 0건 (관련 스레드 미발견)
- 조사 일시: 2026-02-04
