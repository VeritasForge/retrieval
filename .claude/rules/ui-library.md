# UI 라이브러리

이 프로젝트의 `components/ui/`는 **`@base-ui/react`** 기반이다 (Radix UI 아님).

## 주의사항

- shadcn 래퍼라고 해서 Radix UI API를 가정하지 말 것
- UI 컴포넌트 수정 시 반드시 `components/ui/` 래퍼 코드 → `node_modules/@base-ui/react` 타입 정의 순으로 실제 API를 확인할 것
- 예: Base UI `Select.Value`는 `children` 함수 `(value) => ReactNode`로 표시 텍스트를 제어함 (`label` prop 아님)
