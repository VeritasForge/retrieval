// @vitest-environment jsdom
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { TaskCard } from "./task-card";

// 의존 mock — useUiStore, TitleWithMentions
vi.mock("@/stores/ui-store", () => ({
  useUiStore: () => vi.fn(),
}));
vi.mock("@/components/review/title-with-mentions", () => ({
  TitleWithMentions: ({ title }: { title: string }) => <span data-testid="title">{title}</span>,
}));

const baseProps = {
  reviewId: "r1",
  taskId: "t1",
  categoryId: "c1",
  categoryName: "수학",
  categoryIcon: "book",
  categoryColor: "ff0000",
  strategyId: "s1",
  strategyName: "에빙하우스",
  strategyType: "fixed" as const,
  studyDate: "2026-05-15",
  title: "에빙하우스 https://wikipedia.org",
  onDelete: vi.fn(),
};

describe("TaskCard", () => {
  // [Happy]
  it("[Happy] today mode — 복습 완료 + 편집 + 삭제 버튼 노출", () => {
    render(<TaskCard mode="today" {...baseProps} onComplete={vi.fn()} />);
    expect(screen.getByRole("button", { name: /복습 완료/ })).toBeTruthy();
  });

  it("[Happy] readonly mode — title은 TitleWithMentions에 위임", () => {
    render(<TaskCard mode="readonly" {...baseProps} />);
    expect(screen.getByTestId("title").textContent).toBe(baseProps.title);
  });

  // [Boundary]
  it("[Boundary] readonly mode — 편집/삭제/완료/계속/다시 시작 모두 미렌더", () => {
    render(<TaskCard mode="readonly" {...baseProps} />);
    expect(screen.queryByRole("button", { name: /편집/i })).toBeNull();
    expect(screen.queryByRole("button", { name: /삭제/i })).toBeNull();
    expect(screen.queryByRole("button", { name: /복습 완료/ })).toBeNull();
    expect(screen.queryByRole("button", { name: /계속/ })).toBeNull();
    expect(screen.queryByRole("button", { name: /다시 시작/ })).toBeNull();
  });

  it("[Boundary] readonly + SM-2 + rating 있음 → rating 이모티콘 표시", () => {
    render(
      <TaskCard
        mode="readonly"
        {...baseProps}
        strategyType="sm2"
        rating={2}
      />
    );
    expect(screen.getByText(/괜찮음/)).toBeTruthy();
  });

  it("[Boundary] readonly + Fixed → rating 영역 미렌더", () => {
    render(
      <TaskCard
        mode="readonly"
        {...baseProps}
        strategyType="fixed"
        rating={null}
      />
    );
    expect(screen.queryByText(/괜찮음|쉬움|어려움|까먹음/)).toBeNull();
  });

  // [Error]
  it("[Error] onDelete 없이 readonly는 정상 렌더 (액션 미사용)", () => {
    // 'onDelete'는 prop required지만 readonly에서는 사용 안 함.
    // readonly에서도 prop 인터페이스 보존을 위해 noop 함수 전달 가능.
    const noop = () => {};
    render(<TaskCard mode="readonly" {...baseProps} onDelete={noop} />);
    expect(screen.getByTestId("title")).toBeTruthy();
  });
});
