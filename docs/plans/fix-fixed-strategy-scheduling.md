# 플랜 v6 — Fixed(에빙하우스) 전략 정책 정리 + Reset 도입 + 관련 버그 수정

> **버전 이력**:
> - v3: 초안 (today() 기준 변경)
> - v4: doc-review walk-through 결정 반영 (누적 의미 유지 + reset 도입)
> - v5: rl-verify Iteration 1 발견 19건 반영
> - **v6**: rl-verify Iteration 2 신규 MEDIUM 4건(N1/N3/N5/N8) 반영. 수렴 종료.

---

## 🎯 변경 요약 (10건 묶음)

| ID | 변경 | 대상 |
|----|------|------|
| **A** | overdue 카드 액션 set 재설계: `오늘로 이동` + `건너뛰기` 제거, `계속` + `다시 시작` 추가, `삭제` 유지. SM-2 task 강제 `다시 시작` 버튼 hide 가드 (F02) | UI |
| **B** | 신규 `/api/reviews/[id]/reset` 엔드포인트 — task의 `level=0`, `studyDate=today()`로 초기화하고 기존 pending review 삭제 후 새 Lv0 review 삽입. 사전 검증을 트랜잭션 진입 전에 배치 (F06) | API |
| **C** | Fixed 전략 마지막 단계(`nextLevel >= intervals.length`) 완료 시 `graduated: true`, `graduatedAt: now()` 기록 — SM-2와 동일 패턴 | API |
| **D** | skip + reschedule 기능 완전 제거. `reviewSchedules.status` enum의 `"skipped"` 값은 **유지**(pgEnum 파괴적 변경 방지). history 읽기 경로에서는 처리 제거 (E) | 다중 |
| **E** | history 페이지/API에서 `"skipped"` 처리 제거. statistics route도 점검 (F05) | UI/API |
| **F** | `/complete` 와 `/reset` 핸들러에 `db.transaction` 도입. **atomic claim을 트랜잭션 첫 작업**으로 (F04). 더블탭 보호 + race 안전망 (F15 motivation) | API |
| **G** | `lib/utils.ts` `today()`/`daysBetween`/`addDays`/`formatDate` 모두 KST(Asia/Seoul) 명시 — server + client 양쪽 일관 (F01) | 유틸 |
| **H** | 일회성 보정 SQL: 기존 `level >= intervals.length` Fixed task에 `graduated: true` 적용. `UPDATE ... FROM ... JOIN ...` 형식 채택 (F07) | DB script |
| **I** | vitest 설치 + `lib/review-scheduler.ts`/reset 로직/KST 단위 테스트 5~7개 + 통합 테스트 1~2개(transaction race) (F11) | 테스트 |
| **J** | `/complete` 즉시 클릭 보호 — 클라이언트에서 클릭 후 짧은 disable + 서버측 atomic claim으로 더블 보호 (F08) | UI |

---

## ✅ 1. 완료조건 (Completion Criteria)

| # | 기준 | 검증 |
|---|------|------|
| 1.1 | `calculateNextFixedDate`는 **변경 없음** (현재 코드 유지) | 회귀 테스트 |
| 1.2 | overdue 카드에서 `계속` 클릭 시 → `/complete` 호출 → 다음 level 진행 | 시나리오 검증 |
| 1.3 | overdue 카드에서 `다시 시작` 클릭 시 → `/reset` 호출 → `level=0`, `studyDate=today()`, 기존 pending review 삭제, 새 Lv0 review 삽입 | 단위 + 시나리오 |
| 1.4 | Fixed 마지막 단계 완료 시 `graduated: true`, `graduatedAt: now()` 기록 | 단위 + DB select |
| 1.5 | skip/reschedule UI/API 모두 제거. **grep 패턴 좁힘**(F12): `grep -rn 'SkipForward\|onSkip\|onReschedule\|handleOverdueSkip\|handleOverdueReschedule\|/api/reviews/.*/skip\|/api/reviews/overdue' app components`. 결과 0건 | grep |
| 1.6 | history 페이지에 `"skipped"` badge 안 보임, history API + statistics route(F05)의 `"skipped"` 참조 제거 | grep + 시나리오 |
| 1.7 | `/complete`와 `/reset`의 핵심 mutation이 `db.transaction`으로 감싸짐. **atomic claim이 트랜잭션 첫 작업**(F04). 사전 검증(권한, strategy.type)은 트랜잭션 진입 전에 배치(F06) | 코드 리뷰 + 통합 테스트 |
| 1.8 | `today()`/`daysBetween`/`addDays`/`formatDate` 모두 KST 기반. **client component(`dashboard-header`, `upcoming-reviews`, `overdue-panel`, `add-task-modal`)에서 호출 시에도 KST 출력 일관**(F01) | 단위 테스트 (KST 자정 경계) + 시나리오 |
| 1.9 | 일회성 보정 SQL 실행 후 `SELECT count(*) FROM tasks t JOIN strategies s ON t.strategy_id=s.id WHERE s.type='fixed' AND t.level >= jsonb_array_length(s.intervals) AND t.graduated=false` 결과 0건 | DB 쿼리 |
| 1.10 | vitest 설치, `npm test` 실행 가능, 단위 테스트 5~7개 + 통합 테스트 1~2개 PASS (transaction rollback 시나리오 포함) (F11) | `npm test` |
| 1.11 | `npm run build` PASS, `npm run lint` PASS | `npm run build` |
| 1.12 | 시나리오 재현: studyDate=1/1, today=2/15에서 overdue — `계속` 클릭 시 다음 review가 today에 잡힘. `다시 시작` 클릭 시 task가 reset되어 새 Lv0 review가 2/16에 잡힘 | 수동 |
| 1.13 | overdue 카드에서 SM-2 task에는 `다시 시작` 버튼이 **렌더되지 않음** (F02) | 시나리오 검증 |
| 1.14 | `계속` 버튼은 클릭 후 1초간 disable + `다시 시작`은 confirm 다이얼로그 노출 (F08) | 시나리오 검증 |

---

## 🚫 2. 금지사항 (Don'ts)

- ~~`calculateNextFixedDate` 시그니처 변경~~ → **건드리지 마라**
- ~~`calculateFirstReviewDate` 수정~~ → **건드리지 마라**
- ~~SM-2 분기 코드 수정~~ → **이번 범위 밖**
- ~~`tasks.studyDate` 컬럼 삭제/마이그레이션~~ → **유지**
- ~~`reviewSchedules.status` enum의 `"skipped"` 값 제거~~ → **유지** (pgEnum 파괴적 변경 방지). 단, **읽기 경로에서는 처리 제거**
- ~~`db/schema/review-schedules.ts:5` `pgEnum` 배열 수정~~ → drizzle-kit destructive ALTER TYPE 방지
- ~~기존 history skipped 데이터 삭제~~ → SQL DELETE 금지. 읽기 경로만 차단
- ~~Task 5에서 `RotateCcw` 아이콘 import 제거~~ → **`SkipForward`만 제거**, `RotateCcw`는 Task 6 "다시 시작" 버튼에 재사용 (F03)
- ~~보정 SQL을 `UPDATE ... WHERE id IN (SELECT ...)` 형식으로 작성~~ → `UPDATE ... FROM ... JOIN ...` 형식 (F07)

---

## ⚠️ 3. 고려사항 (Considerations)

### 기술적
- **타임존(F01 확장)**: server-side와 client-side 모두 KST 통일. `Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Seoul" })` 패턴은 client에서도 정상 작동. `formatDate`/`addDays`/`daysBetween` 모두 KST 통일 필요
- **동시성(F15 motivation)**: `db.transaction` + atomic claim 도입 motivation은 (a) 더블탭 보호 (b) 두 탭/디바이스 동시 클릭 race 방지 (c) idempotency 안전망. client-side debounce(Task J)는 1차 보호, 서버측 atomic claim은 최종 보호
- **atomic claim 분기의 트랜잭션 의미론(N8)**: claim 실패 시 `if (!claimed) return NextResponse.json(..., 404)` 분기는 throw가 아니므로 트랜잭션 자동 commit. mutation 0건이므로 commit 자체는 무해. 후속 mutation 도중 throw가 발생할 때만 rollback이 의미를 가짐. "throw → rollback" 표현은 후속 단계에 한정해 해석할 것 (스니펫 변경 없음, 의미만 명확화)
- **Reset 핸들러 동시성(N3)**: 동일 task에 대한 두 reset 동시 호출 시 `tasks` 행에 advisory lock/`SELECT FOR UPDATE` 미적용으로 두 Lv0 review가 삽입될 수 있음. **personal app 단일 사용자 가정에선 무시 가능**. 향후 멀티유저 확장 시 `tx.select().from(tasks).where(eq(id, X)).for("update")`를 트랜잭션 첫 작업으로 추가 필요. 본 plan에선 가정 명시만
- **`/complete` atomic claim 순서(F04)**: `db.transaction` 진입 후 첫 작업이 `UPDATE reviewSchedules SET status='completed' WHERE id=X AND userId=Y AND status='pending' RETURNING ...`. 결과가 빈 배열이면 즉시 404 throw → 트랜잭션 자동 rollback
- **Reset 트랜잭션 early return 패턴(F06)**: 사전 검증(getAuthUserId, review 존재 + ownership, strategy.type === "fixed")은 트랜잭션 진입 전. 트랜잭션 내부에서는 mutation만
- **Reset 시 기존 pending review 처리**: 삭제(DELETE) — pending은 history 아님
- **`intervals` 배열 가정**: `intervals[i] >= 1`. 같은 날 인터벌 미지원
- **함수 시그니처 비대칭은 의도된 것**: `calculateFirstReviewDate`는 클램프 유지, `calculateNextFixedDate`는 호출부 책임. 통합 금지
- **SM-2 task UI 가드(F02)**: `task-card.tsx`에서 `strategyType === "fixed"`일 때만 "다시 시작" 버튼 렌더. 이외에는 hide. 백엔드 400은 fail-safe 2차 방어
- **`intervals as number[]` 캐스트(F13)**: Reset 핸들러에서 `strategy.intervals as number[]`로 명시 캐스트. `/complete/route.ts:29`와 동일 패턴
- **stranded data 보정 시점(F17)**: Task 9는 변경 D/B/E 머지 후 1회 실행. personal app 환경에서 락 영향 무시 가능하나 백업 필수(`.claude/rules/db-migration-protocol.md` 정신)
- **vitest + 통합 테스트(F11)**: 단위 테스트는 `lib/review-scheduler.ts`, KST 자정 경계, reset 로직. 통합 테스트는 transaction rollback 시나리오 1~2개 (test DB 또는 in-memory fixture). race 시뮬레이션은 두 동시 호출이 한쪽은 success, 다른쪽은 404임을 검증

### 정책 / Open Questions (미결정)
- **F09 백데이트 우회**: task 수정 UI에서 `studyDate`를 직접 편집하면 reset 의도가 침식 가능. 결정 필요:
  - (a) studyDate 편집 차단
  - (b) studyDate 편집 시 자동 level=0 reset 강제
  - (c) 사용자 책임으로 두고 plan은 가정만 명시
  - **현 plan v5 default**: (c) — 사용자 책임. 향후 결정 시 별도 PR
- **F19 graduated 재학습**: 졸업한 task를 다시 시작하고 싶은 경우 path 부재. task 상세 페이지에서 "처음부터 다시 시작" 버튼 추가는 **이번 범위 밖**
- **F18 통계 영향**: 같은 날 다단계 졸업이 통계에서 "1일/3일/7일/14일/30일 모두 했다"로 집계됨. 의도와 괴리 가능. **이번 범위 밖**
- **F16 출장 TZ**: 사용자가 한국 외 지역에서 사용 시 자정 경계 ±9시간 영향. **현 plan v5 default**: 단일 사용자 한국어 personal app 가정으로 KST 고정 수용
- **F14 reset URL semantics**: `[id]`가 review ID인 점은 약간 어색. task ID로 호출하는 게 더 정확. **현 plan v5 default**: 호출부 UX(overdue 카드의 reviewId) 우선해 review-scoped 유지

---

## 🔒 4. 제약사항 (Constraints)

- Stack: Next.js 15 App Router + Drizzle ORM + Base UI + TypeScript
- DB 스키마 변경 없음
- Postgres pgEnum 값 추가/제거 없음
- 영향 파일 수: 14개 (수정 11 + 삭제 1 + 신규 2)

**파일 영향 표**:

| 파일 | 변경 종류 | 작업 |
|------|-----------|------|
| `lib/utils.ts` | 수정 | KST 명시 — `today`, `daysBetween`, `addDays`, `formatDate` 모두 (G, F01) |
| `lib/review-scheduler.ts` | 변경 없음 | — |
| `app/api/reviews/[id]/complete/route.ts` | 수정 | graduated 플래그 (C), atomic claim 순서 (F), debounce 보강 |
| `app/api/reviews/[id]/skip/route.ts` | 삭제 | (D) |
| `app/api/reviews/[id]/reset/route.ts` | 신규 | reset 핸들러 (B), transaction (F), early return 사전 검증 (F06) |
| `app/api/reviews/overdue/route.ts` | 삭제 | (D) |
| `app/api/history/route.ts` | 수정 | inArray에서 `"skipped"` 제거 (E) |
| `app/api/statistics/route.ts` | 점검/수정 | `"skipped"` 참조 점검 (F05). 있으면 제거, 없으면 변경 없음 |
| `app/(main)/history/page.tsx` | 수정 | "건너뜀" badge 제거 (E) |
| `components/dashboard/task-card.tsx` | 수정 | overdue 모드 액션 재설계 (A), SM-2 가드 (F02), 클릭 disable (J) |
| `components/dashboard/overdue-panel.tsx` | 수정 | props 재설계 (A) |
| `app/(main)/page.tsx` | 수정 | handler 재설계 (A) |
| `db/schema/review-schedules.ts` | 변경 없음 | — (enum 보존) |
| `package.json` | 수정 | vitest devDep + test 스크립트 (I) |
| `vitest.config.ts` | 신규 | (I) |
| `lib/review-scheduler.test.ts` | 신규 | (I) |
| `lib/utils.test.ts` | 신규 | KST 단위 테스트 (I, F01) |
| `app/api/reviews/[id]/reset/route.test.ts` | 신규 | reset + transaction integration test (I, F11) |
| `scripts/backfill-graduated-fixed-tasks.sql` | 신규 | 일회성 보정 (H, F07) |

---

## 🧰 5. 스킬 매핑 테이블

| 스킬/도구 | 용도 | 적용 Task |
|-----------|------|-----------|
| `Read` / `Edit` / `Write` / `Bash` | 코드 작성/실행 | 전반 |
| `superpowers:test-driven-development` | TDD 사이클 | T2~T6 |
| `superpowers:verification-before-completion` | 완료 전 증거 기반 확인 | T10 |
| `compound-engineering:ce-doc-review` | 본 plan 문서 품질 검증 | (완료) |
| `rl-verify` | 본 plan 기술적 정확성 검증 | (진행 중) |
| `vercel-react-best-practices` | UI 핸들러 재설계 참고 | T7 |

---

## 📝 6. Task List (순차 실행)

### Task 0 — vitest 설치 + 환경 부트스트랩 (변경 I, 일부)
- **완료조건**:
  - `package.json`에 `vitest`, `@vitest/ui`(선택), `tsx` devDependency 추가
  - scripts에 `"test": "vitest run"`, `"test:watch": "vitest"` 추가
  - `vitest.config.ts` 생성 (path alias `@/` 매핑)
  - `npm test` "no tests found" 정상 종료
- **스킬 매핑**: `Edit`, `Write`, `Bash`

### Task 1 — 환경/스키마/사용처 확인
- **완료조건**:
  - `lib/utils.ts:today()`/`daysBetween`/`addDays`/`formatDate` 동작 (TZ) 확인
  - `db/schema/tasks.ts` `graduated`, `graduatedAt` 컬럼 타입 확인
  - `db/schema/strategies.ts` `intervals` 컬럼 타입 확인 (확인됨: jsonb)
  - `db/schema/review-schedules.ts` status enum 확인
  - **`graduated` + `"skipped"` 사용처 grep — `app`, `components`, `lib`, `db` 전체** (F05 statistics 포함)
  - 기존 stranded task 카운트:
    ```sql
    SELECT count(*) FROM tasks t JOIN strategies s ON t.strategy_id=s.id
    WHERE s.type='fixed' AND t.level >= jsonb_array_length(s.intervals) AND t.graduated=false;
    ```
  - **overdue 쿼리(`/api/reviews/route.ts`)가 `tasks.graduated` 필터를 가지는지 확인 (F10, N1)**. 결과에 따라:
    - 필터 있음 → 변경 없음
    - 필터 없음 → **Task 5에 보강 작업 추가**: `app/api/reviews/route.ts`의 overdue/today/upcoming 쿼리에 `eq(tasks.graduated, false)` 조건 추가. 보정 SQL(Task 7) 후 graduated task가 dashboard에서 자동 제외되어야 함
- **스킬 매핑**: `Read`, `Bash`

### Task 2 — 변경 G: `lib/utils.ts` KST 고정 (server + client 일관)
- **완료조건**:
  - `today()`: `Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Seoul" })` 사용 → `YYYY-MM-DD` 보장
  - `daysBetween(from, to)`: KST 기준 자정 경계로 일수 계산
  - `addDays(date, days)`: KST 기준
  - `formatDate(dateStr)`: KST locale 명시 (`"ko-KR"` + `timeZone: "Asia/Seoul"`)
  - 단위 테스트 PASS (`lib/utils.test.ts`):
    - KST 자정 직전/직후 케이스
    - 입력 string `"2026-01-01"`이 KST 자정으로 파싱되는지
    - DST 영향 없는지(KST는 DST 없음)
  - 클라이언트 컴포넌트(`dashboard-header`, `upcoming-reviews`, `overdue-panel`, `add-task-modal`)에서 같은 함수 import해서 사용 시 동일 결과 확인
- **스킬 매핑**: `Edit`, `superpowers:test-driven-development`

### Task 3 — 변경 C + F: `/complete` 핸들러 — graduated 플래그 + transaction (atomic claim 첫 작업)
- **완료조건**:
  - 핸들러 진입 시 사전 검증: `getAuthUserId`만 트랜잭션 외부에서
  - `db.transaction` 진입 후 첫 작업: `UPDATE reviewSchedules SET status='completed', rating, completedAt WHERE id=X AND userId=Y AND status='pending' RETURNING *` (F04)
  - 결과 빈 배열 → throw → rollback → 404 응답
  - claim 성공 후 task/strategy select, 분기, 다음 review 삽입 또는 graduated 설정
  - Fixed 분기에서 `nextDate === null`일 때 `graduated: true`, `graduatedAt: new Date()` 추가
  - SM-2 분기와 동일 패턴
  - 단위 + 통합 테스트:
    - 정상 완료 케이스
    - graduated 케이스
    - 동시 호출 race 케이스 (한 호출 success, 한 호출 404)
- **스킬 매핑**: `Edit`, `superpowers:test-driven-development`

### Task 4 — 변경 B + F: `/api/reviews/[id]/reset` 신규 핸들러
- **완료조건**:
  - 사전 검증(트랜잭션 외부): `getAuthUserId`, review select + ownership 확인, task select, strategy select, `strategy.type === "fixed"` (F06)
  - 검증 실패 시 즉시 NextResponse 반환(404/400) — 트랜잭션 미진입
  - `db.transaction` 진입 후:
    1. 해당 task의 `status='pending'` reviewSchedules 모두 DELETE
    2. tasks UPDATE: `level=0`, `studyDate=today()`, `graduated=false`, `graduatedAt=null`
    3. 새 Lv0 reviewSchedules INSERT: `scheduledDate = calculateFirstReviewDate(today(), strategy.type, strategy.intervals as number[])`, `reviewOrder=0` (F13 캐스트)
  - 단위 + 통합 테스트
- **스킬 매핑**: `Write`, `Edit`, `superpowers:test-driven-development`

### Task 5 — 변경 D + E: skip/reschedule + history skipped 처리 제거 (statistics 점검 포함)
- **완료조건**:
  - `app/api/reviews/[id]/skip/route.ts` 파일 삭제
  - `app/api/reviews/overdue/route.ts` 파일 삭제
  - `app/(main)/page.tsx`에서 `handleOverdueReschedule`, `handleOverdueSkip` 함수 제거
  - `components/dashboard/overdue-panel.tsx`에서 `onReschedule`, `onSkip` props 제거
  - `components/dashboard/task-card.tsx`에서 `SkipForward` 아이콘 import 제거 (**`RotateCcw`는 보존** — F03), 해당 버튼 JSX 제거
  - `app/api/history/route.ts`에서 inArray의 `"skipped"` 제거
  - `app/(main)/history/page.tsx`에서 "건너뜀" badge 제거
  - `app/api/statistics/route.ts` 점검 (F05): `"skipped"` 참조 있으면 제거, 없으면 변경 없음
  - 완료조건 1.5 grep 0건
- **스킬 매핑**: `Edit`, `Bash`

### Task 6 — 변경 A + J: overdue 카드 액션 재설계 (SM-2 가드 + 클릭 disable)
- **완료조건**:
  - `task-card.tsx` overdue 모드:
    - `계속` 버튼 (Check 아이콘, 모든 strategyType에 노출)
    - `다시 시작` 버튼 (RotateCcw 아이콘, **`strategyType === "fixed"`일 때만 렌더** — F02). confirm 다이얼로그 노출
    - `삭제` 버튼 (Trash2 아이콘, 그대로)
  - `계속` 버튼 클릭 후 1초간 disable (F08, J) — useState로 처리
  - `overdue-panel.tsx` props: `onContinue`, `onReset`, `onDelete`
  - `app/(main)/page.tsx`에 `handleOverdueContinue` (`/complete` POST) + `handleOverdueReset` (`/reset` POST)
  - 시나리오 검증: 계속/다시 시작/삭제 각 액션, SM-2 task에 다시 시작 버튼 미노출
- **스킬 매핑**: `Edit`, `vercel-react-best-practices`

### Task 7 — 변경 H: 보정 SQL 스크립트 작성 (UPDATE FROM JOIN 형식)
- **완료조건**:
  - `scripts/backfill-graduated-fixed-tasks.sql` 작성:
    ```sql
    UPDATE tasks t
    SET graduated = true, graduated_at = now()
    FROM strategies s
    WHERE t.strategy_id = s.id
      AND s.type = 'fixed'
      AND t.level >= jsonb_array_length(s.intervals)
      AND t.graduated = false;
    ```
  - **사용자 승인 + 백업 후** 실행 (`.claude/rules/db-migration-protocol.md` 준수)
- **스킬 매핑**: `Bash`, 사용자 승인

### Task 8 — 통합 테스트 추가 (F11, N5)
- **완료조건**:
  - `app/api/reviews/[id]/reset/route.test.ts` 또는 별도 통합 테스트 파일:
    - reset 정상 케이스
    - SM-2 task에 reset 시도 → 400
    - 권한 없는 review에 reset → 404
    - reset 트랜잭션 도중 에러 발생 시 rollback (mock으로 강제 throw 검증)
  - `app/api/reviews/[id]/complete/route.test.ts`:
    - 동시 호출 race — 한 호출 success, 다른 호출 404
  - **race 테스트 인프라 명시(N5)**: 진정한 DB-level race 재현은 두 개 별도 connection에서 동시에 BEGIN+UPDATE 필요. 단일 connection `Promise.all(POST,POST)`는 직렬화 가능. **선택지**:
    - (a) 두 connection 인프라 (testcontainers + 두 클라이언트) — 정확하지만 무거움
    - (b) 단일 connection으로 시뮬레이션, 주석에 "atomic claim의 `WHERE status='pending'` 조건이 race 안전을 보장한다는 단위 검증" 명시
    - **default: (b)** — personal app 환경에선 (b)가 비용 대비 가치 적정. 단, 한계는 테스트 코드 주석에 명시
- **스킬 매핑**: `Write`, `superpowers:test-driven-development`

### Task 9 — 일회성 보정 실행 (Task 7 SQL)
- **완료조건**: 사용자 승인 후 SQL 실행 → 1.9 검증 PASS
- **스킬 매핑**: `Bash`, 사용자 승인

### Task 10 — 통합 회귀 + 시나리오
- **완료조건**:
  - `npm test` 전체 PASS (단위 + 통합)
  - `npm run lint` PASS
  - `npm run build` PASS
  - 시나리오 1.12 + 1.13 + 1.14 수동 검증
- **스킬 매핑**: `Bash`, `superpowers:verification-before-completion`

---

## 🔁 실행 흐름

```
plan v5 작성 (현재)
    ↓
rl-verify Iteration 2 (RESOLVED 확인)
    ↓
수렴 시 → 사용자 최종 승인
    ↓
TaskCreate로 T0~T10 등록
    ↓
순차 실행 (각 Task 후 /rl 검증)
    ↓
모든 Task 완료 → /rl로 plan 단위 완료조건 최종 검증
```

---

## 📌 주요 시그니처/스니펫 (참고용)

### Reset 핸들러 (Task 4) — F06 패턴 적용

```ts
// app/api/reviews/[id]/reset/route.ts
import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, strategies } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { today } from "@/lib/utils";
import { calculateFirstReviewDate } from "@/lib/review-scheduler";

export async function POST(_req: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;

  // 사전 검증 — 트랜잭션 외부 (F06)
  const [review] = await db.select().from(reviewSchedules)
    .where(and(eq(reviewSchedules.id, id), eq(reviewSchedules.userId, userId))).limit(1);
  if (!review) return NextResponse.json({ error: "Not found" }, { status: 404 });

  const [task] = await db.select().from(tasks).where(eq(tasks.id, review.taskId)).limit(1);
  const [strategy] = await db.select().from(strategies).where(eq(strategies.id, task.strategyId)).limit(1);
  if (strategy.type !== "fixed") {
    return NextResponse.json({ error: "Reset is only supported for fixed strategy" }, { status: 400 });
  }

  // mutation — 트랜잭션 내부
  const newStudyDate = today();
  await db.transaction(async (tx) => {
    await tx.delete(reviewSchedules)
      .where(and(eq(reviewSchedules.taskId, task.id), eq(reviewSchedules.status, "pending")));
    await tx.update(tasks).set({
      level: 0, studyDate: newStudyDate, graduated: false, graduatedAt: null
    }).where(eq(tasks.id, task.id));
    const firstDate = calculateFirstReviewDate(newStudyDate, strategy.type, strategy.intervals as number[]);
    await tx.insert(reviewSchedules).values({
      userId, taskId: task.id, scheduledDate: firstDate, reviewOrder: 0
    });
  });

  return NextResponse.json({ success: true });
}
```

### `/complete` atomic claim 패턴 (Task 3 — F04)

```ts
// app/api/reviews/[id]/complete/route.ts (발췌)
const userId = await getAuthUserId();
if (!userId) return unauthorized();

return await db.transaction(async (tx) => {
  // 트랜잭션 첫 작업 — atomic claim
  const [claimed] = await tx.update(reviewSchedules)
    .set({ status: "completed", rating: parsed.data.rating ?? null, completedAt: new Date() })
    .where(and(
      eq(reviewSchedules.id, id),
      eq(reviewSchedules.userId, userId),
      eq(reviewSchedules.status, "pending")
    ))
    .returning();

  if (!claimed) {
    return NextResponse.json({ error: "Not found or already completed" }, { status: 404 });
  }

  const [task] = await tx.select().from(tasks).where(eq(tasks.id, claimed.taskId)).limit(1);
  const [strategy] = await tx.select().from(strategies).where(eq(strategies.id, task.strategyId)).limit(1);

  if (strategy.type === "fixed") {
    const nextLevel = task.level + 1;
    const nextDate = calculateNextFixedDate(task.studyDate, strategy.intervals as number[], nextLevel);
    const taskUpdate: Record<string, unknown> = { level: nextLevel };
    if (!nextDate) {
      taskUpdate.graduated = true;
      taskUpdate.graduatedAt = new Date();
    }
    await tx.update(tasks).set(taskUpdate).where(eq(tasks.id, task.id));
    if (nextDate) {
      await tx.insert(reviewSchedules).values({
        userId, taskId: task.id, scheduledDate: nextDate, reviewOrder: nextLevel
      });
    }
  } else {
    // SM-2 분기 (변경 없음, transaction 안으로 이동만)
    ...
  }

  return NextResponse.json({ success: true });
});
```

### overdue 카드 (Task 6 발췌) — F02, J 적용

```tsx
// components/dashboard/task-card.tsx (overdue 모드)
const [continueDisabled, setContinueDisabled] = useState(false);

function handleContinueClick() {
  if (continueDisabled) return;
  setContinueDisabled(true);
  setTimeout(() => setContinueDisabled(false), 1000);
  onContinue?.(reviewId);
}

{mode === "overdue" && (
  <div className="flex gap-2 mt-2">
    {onContinue && (
      <Button size="sm" onClick={handleContinueClick} disabled={continueDisabled}>
        <Check className="h-3 w-3 mr-1" /> 계속
      </Button>
    )}
    {onReset && strategyType === "fixed" && (  // F02 — Fixed에만 렌더
      <Button size="sm" variant="outline" onClick={() => {
        if (confirm("학습 진도를 처음부터 다시 시작하시겠습니까? 이전 복습 기록은 보존됩니다.")) {
          onReset(reviewId);
        }
      }}>
        <RotateCcw className="h-3 w-3 mr-1" /> 다시 시작
      </Button>
    )}
    <Button size="sm" variant="ghost" className="text-destructive" onClick={() => onDelete(taskId)}>
      <Trash2 className="h-3 w-3 mr-1" /> 삭제
    </Button>
  </div>
)}
```

---

## 📋 결정 이력 (Walk-through + rl-verify Iteration 1)

| 결정 | 선택 | 근거 | 출처 |
|------|------|------|------|
| C1: interval 의미 | 누적 유지 + reset 도입 | 사용자 의도 | walk-through |
| Reset 트리거 | 사용자 명시 버튼 | 의도 명확화 | walk-through |
| Reset 시 history | 보존 | 회고 가능 | walk-through |
| Reset 후 studyDate | today | 직관적 | walk-through |
| overdue UX | 계속/다시 시작/삭제 (3개) | 중복 제거 | walk-through |
| "계속" 동작 | 현재 코드 유지 | 사용자 선택 | walk-through |
| C2 테스트 | vitest + 단위 + **통합 1~2개**(F11) | 장기 자산 + race 검증 | walk-through + rl-verify F11 |
| C3 history | skipped 처리 제거 | 일관성 | walk-through |
| C4 stranded | 일회성 보정 SQL **(UPDATE FROM JOIN)**(F07) | 데이터 정합성 + SQL 명료성 | walk-through + rl-verify F07 |
| H3 timezone | KST 고정 **(server + client 일관)**(F01) | 단일 사용자 한국어 앱 + TZ 불일치 차단 | walk-through + rl-verify F01 |
| H4 race | db.transaction + **atomic claim 첫 작업**(F04) | 안정성 + race 차단 | walk-through + rl-verify F04 |
| F02 SM-2 가드 | UI에서 strategyType === "fixed" 가드 + 백엔드 400 fail-safe | UX 데드락 방지 | rl-verify F02 |
| F08 계속 confirm | 클릭 후 1초 disable + 다시 시작은 confirm | 더블탭 보호 | rl-verify F08 |
| F03 RotateCcw | 보존 (다시 시작 버튼에 재사용) | Task 5/6 모순 해소 | rl-verify F03 |
| F06 early return | 사전 검증을 트랜잭션 외부 | 의도치 않은 부분 커밋 방지 | rl-verify F06 |
| N1 graduated 필터 보강 | Task 1 결과 → Task 5 조건부 보강 | 보정 SQL 후 graduated 자동 제외 | rl-verify Iter2 N1 |
| N3 advisory lock | personal app 가정으로 미적용, 멀티유저 시 도입 명시 | 단일 사용자 환경 trade-off | rl-verify Iter2 N3 |
| N5 race 테스트 인프라 | 단일 connection 시뮬레이션, 한계 명시 | 비용 대비 가치 | rl-verify Iter2 N5 |
| N8 atomic claim 분기 | return 패턴 유지, 의미론 명확화 | claim 실패 시 mutation 0건 commit 무해 | rl-verify Iter2 N8 |

### Open Questions (이번 범위 밖)
- **F09**: studyDate 직접 편집 시 reset 우회 — task 수정 UI 정책 결정 필요
- **F18**: 같은 날 다단계 졸업의 통계 영향
- **F19**: graduated task 재학습 path
- **F14**: reset URL semantics (review-id vs task-id)
- **F16**: 한국 외 지역 사용 시 KST 고정 영향
