# Dashboard Unification Design

## Goal

리팩토링(subtasks → title) 이후 깨진 대시보드를 복구하고, 모든 섹션을 통일된 카드 + 접기/펼치기 UX로 개선한다.

## Problems

1. UpcomingReviews: 숫자 카운트만 표시, API에 strategy 누락
2. CompletedReviews: 점+이름만 표시, title 미표시
3. OverduePanel: 카테고리명만 표시, title 미표시
4. TodayReviews: 접기/펼치기 없음
5. 접기 상태 기억 미구현
6. 복습 완료율 갱신 확인 필요

## Design

### CollapsibleSection 컴포넌트 (신규)

모든 대시보드 섹션이 공유하는 래퍼. `children`을 감싸서 접기/펼치기 제공.

Props: `title`, `count`, `sectionKey` (Zustand persist에 사용), `children`

### TaskCard mode 확장

기존 TaskCard에 `mode` prop 추가:
- `"today"` → [수정][삭제][복습 완료]
- `"completed"` → [수정][삭제] + ✅ 표시
- `"upcoming"` → [수정][삭제]만
- `"overdue"` → [수정][삭제] + [오늘로 이동][건너뛰기]

### UI Store 변경

Zustand persist 미들웨어로 접기 상태 localStorage 저장:
```
collapsedSections: { today: false, completed: false, upcoming: false, overdue: false }
toggleSection: (key) => ...
```

### API 수정

`/api/reviews` GET — upcoming 쿼리에 strategies JOIN 추가.

### 컴포넌트별 변경

- **TodayReviews**: CollapsibleSection 래핑
- **CompletedReviews**: 전면 교체 → CollapsibleSection + TaskCard(mode="completed")
- **UpcomingReviews**: 전면 교체 → CollapsibleSection + 날짜 그룹 + TaskCard(mode="upcoming")
- **OverduePanel**: 전면 교체 → CollapsibleSection + TaskCard(mode="overdue")
- **Dashboard page**: onToggleSubtask 잔여 참조 정리, overdue 핸들러를 카드 단위로 변경

## Tech

- Zustand persist middleware (localStorage)
- 기존 @base-ui/react Collapsible 컴포넌트 활용
- Next.js 16, TypeScript
