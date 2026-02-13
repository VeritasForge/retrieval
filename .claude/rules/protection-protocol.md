# Test Protection Protocol

코드 변경 시 기존 테스트 보호를 위한 **필수** 워크플로우입니다. 모든 코드 수정 전/후 반드시 수행해야 합니다.

### 변경 전 (Pre-Change Validation)

1. **테스트 존재 확인**
   - Backend: `backend/tests/` 디렉토리 확인
   - Frontend: `frontend/` 내 테스트 파일 확인

2. **기존 테스트 실행 (베이스라인 확보)**
   ```bash
   # Backend
   cd backend && uv run pytest -v

   # Frontend
   cd frontend && npm test
   ```

3. **통과 상태 확인**
   - 모든 테스트가 PASS인지 확인
   - FAIL이 있다면 먼저 수정 후 진행
   - 베이스라인 테스트 결과 기록

### 변경 후 (Post-Change Validation)

1. **전체 테스트 재실행**
   - 변경 범위와 무관하게 **전체 테스트 스위트** 실행
   - 단위 테스트만이 아닌 통합 테스트도 포함

2. **회귀 감지 (Regression Detection)**
   - 변경 전 PASS → 변경 후 FAIL: **Breaking Change 감지**
   - 새로운 FAIL 발생 시 즉시 다음 단계로

3. **개발자 알림 (Immediate Notification)**

   테스트 실패 시 **작업 중단** 후 다음 정보 제공:

   ```
   ⚠️ TEST FAILURE DETECTED

   Failed Test(s):
   - test_rebalancing_calculates_correct_quantities (backend/tests/test_rebalancing.py:45)

   Failure Reason:
   AssertionError: Expected 5, got 3

   Likely Cause:
   [AI 분석] 리밸런싱 로직에서 현금 비중 계산 방식이 변경되어 기존 테스트 가정이 깨졌습니다.

   ❓ Action Required:
   이 변경이 의도된 동작 변경인가요?
   - YES → 테스트 업데이트 승인 필요
   - NO → 코드 수정 필요
   ```

4. **자동 수정 금지**
   - 개발자 승인 없이 실패한 테스트를 수정/삭제/주석 처리하지 않음
   - "테스트가 너무 엄격하다" 판단하지 않음
   - 테스트가 틀렸다고 가정하지 않음


