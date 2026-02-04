---
description: CLAUDE.md 문서 동기화 검증 및 업데이트
allowed-tools: Read, Grep, Glob, Edit
---

# /wrap — CLAUDE.md 문서 동기화 검증 및 업데이트

이 커맨드는 CLAUDE.md가 실제 프로젝트 구조(features, agents, skills, rules, commands)와 일치하는지 검증하고, 불일치 발견 시 CLAUDE.md를 업데이트합니다.

## 모드

- `/wrap` — 분석 + 불일치 감지 + CLAUDE.md 자동 업데이트
- `/wrap --check` — 분석 + 불일치 감지만 (수정 없음)

인자: $ARGUMENTS

---

## 실행 절차

### Step 1: 실제 파일 스캔

다음 경로의 파일을 스캔하여 현재 상태를 수집합니다:

1. **Features**: `lib/features/*/` 디렉터리 목록 (디렉터리명 = feature 이름). 각 feature의 layer(domain/data/presentation) 구조 확인
2. **Core**: `lib/core/` 하위 파일 목록
3. **Agents**: `.claude/agents/*.md` 파일 목록 (파일명에서 `.md` 제거 = agent 이름)
4. **Skills**: `.claude/skills/*/SKILL.md` 파일 목록 (상위 디렉터리명 = skill 이름)
5. **Rules**: `.claude/rules/*.md` 파일 목록 (파일명에서 `.md` 제거 = rule 이름)
6. **Commands**: `.claude/commands/*.md` 파일 목록 (파일명에서 `.md` 제거 = command 이름)
7. **Tests**: `test/` 하위 파일 목록 및 테스트 커버리지 현황

### Step 2: CLAUDE.md 파싱

CLAUDE.md에서 다음 정보를 추출합니다:

1. **기술 스택** 섹션의 기술 목록
2. **아키텍처** 섹션의 설명
3. **복습 주기 옵션** 목록
4. 기타 프로젝트 구조 관련 섹션

### Step 3: 불일치 감지

다음 항목을 비교하여 불일치를 감지합니다:

| # | 검사 항목 | 비교 방법 |
|---|-----------|-----------|
| 1 | Feature 목록 | Step 1 feature 디렉터리 vs CLAUDE.md에 기재된 feature |
| 2 | 기술 스택 | pubspec.yaml 의존성 vs CLAUDE.md 기술 스택 |
| 3 | 복습 주기 | ReviewCycle enum 값 vs CLAUDE.md 복습 주기 옵션 |
| 4 | Agent 목록 | Step 1 agent 파일 vs CLAUDE.md에 기재된 agent |
| 5 | Skill 목록 | Step 1 skill 디렉터리 vs CLAUDE.md에 기재된 skill |
| 6 | Rule 목록 | Step 1 rule 파일 vs CLAUDE.md에 기재된 rule |
| 7 | Command 목록 | Step 1 command 파일 vs CLAUDE.md에 기재된 command |

### Step 4: 결과 보고

불일치 감지 결과를 다음 형식으로 출력합니다:

```
## /wrap 검증 결과

### 현재 상태
- Features: {n}개 (CLAUDE.md: {m}개) {일치 | 불일치}
- Core modules: {n}개
- Agents: {n}개
- Skills: {n}개
- Rules: {n}개
- Commands: {n}개
- Tests: {n}개 파일

### 불일치 목록
| # | 유형 | 항목 | 실제 | CLAUDE.md | 조치 |
|---|------|------|------|-----------|------|
| 1 | ... | ... | ... | ... | ... |

### 요약
- 총 {n}건의 불일치 감지
- {조치 요약}
```

### Step 5: CLAUDE.md 업데이트 (기본 모드)

`$ARGUMENTS`에 `--check`가 **포함되지 않은** 경우에만 실행합니다.

불일치가 감지되면 CLAUDE.md를 업데이트합니다:

1. **기술 스택**: pubspec.yaml 기준으로 주요 의존성 반영
2. **아키텍처**: 실제 feature/layer 구조 반영
3. **복습 주기 옵션**: ReviewCycle enum 기준으로 동기화
4. **프로젝트 구조**: 실제 디렉터리/파일 구조 반영

### Step 5 (대체): --check 모드

`$ARGUMENTS`에 `--check`가 **포함된** 경우:

- 불일치 목록만 출력하고 종료
- "CLAUDE.md 업데이트가 필요합니다. `/wrap`을 실행하세요." 메시지 출력
- 불일치가 없으면 "CLAUDE.md가 최신 상태입니다." 출력
