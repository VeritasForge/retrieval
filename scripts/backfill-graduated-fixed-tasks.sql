-- backfill-graduated-fixed-tasks.sql
--
-- 일회성 보정 스크립트 — Fixed 전략에서 모든 단계를 완료했지만
-- graduated 플래그가 설정되지 않은 stranded task를 졸업 처리합니다.
--
-- 배경: 기존 /complete 핸들러는 Fixed 전략에서 마지막 단계 완료 시
-- graduated 플래그를 설정하지 않았습니다. SM-2 분기와 일관되도록
-- plan v6의 변경 C가 도입되었으나, 변경 전 이미 마지막 단계에 도달한
-- task는 graduated=false인 채로 남아 통계/UI에서 졸업 표시되지 않습니다.
--
-- 실행 전 점검 (변경 전 카운트):
--   SELECT count(*) FROM tasks t
--   JOIN strategies s ON t.strategy_id = s.id
--   WHERE s.type = 'fixed'
--     AND t.level >= jsonb_array_length(s.intervals)
--     AND t.graduated = false;
--
-- 실행 후 검증 (위 쿼리 결과 0건이어야 함).
--
-- 안전:
--   - tasks 테이블만 UPDATE
--   - WHERE 필터: Fixed 전략 + level이 intervals 길이 이상 + graduated=false
--   - 다른 전략(SM-2)이나 졸업하지 않은 task에는 영향 없음
--   - 트랜잭션 안에서 실행 권장 (실패 시 rollback)
--
-- 롤백 방법: 실행 시각 기준 백업 dump 복원.

BEGIN;

UPDATE tasks t
SET graduated = true,
    graduated_at = now()
FROM strategies s
WHERE t.strategy_id = s.id
  AND s.type = 'fixed'
  AND t.level >= jsonb_array_length(s.intervals)
  AND t.graduated = false;

-- 검증 (트랜잭션 내):
-- SELECT count(*) FROM tasks t
-- JOIN strategies s ON t.strategy_id = s.id
-- WHERE s.type = 'fixed'
--   AND t.level >= jsonb_array_length(s.intervals)
--   AND t.graduated = false;
-- 결과 0건이면 COMMIT, 아니면 ROLLBACK.

COMMIT;
