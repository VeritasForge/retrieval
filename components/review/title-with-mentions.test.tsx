// @vitest-environment jsdom
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { TitleWithMentions } from "./title-with-mentions";

// UrlMention은 mock — 내부 fetch 회피
vi.mock("./url-mention", () => ({
  UrlMention: ({ url }: { url: string }) => <span data-testid="url-mention">{url}</span>,
}));

describe("TitleWithMentions", () => {
  // [Happy]
  it("[Happy] 텍스트 + URL 혼합 토큰 렌더", () => {
    render(<TitleWithMentions title="에빙하우스 https://wikipedia.org/foo" />);
    expect(screen.getByText(/에빙하우스/)).toBeTruthy();
    expect(screen.getByTestId("url-mention").textContent).toBe("https://wikipedia.org/foo");
  });

  it("[Happy] URL 여러 개", () => {
    render(<TitleWithMentions title="https://a.com https://b.com" />);
    const mentions = screen.getAllByTestId("url-mention");
    expect(mentions).toHaveLength(2);
  });

  // [Boundary] H2: 빈 title이면 null 반환 (row 2 숨김 — 카드 높이 일관)
  it("[Boundary] 빈 title이면 컴포넌트 자체가 null 렌더 (row 숨김)", () => {
    const { container } = render(<TitleWithMentions title="" />);
    expect(container.firstChild).toBeNull();
  });

  it("[Boundary] 텍스트만", () => {
    render(<TitleWithMentions title="에빙하우스 망각곡선" />);
    expect(screen.getByText("에빙하우스 망각곡선")).toBeTruthy();
    expect(screen.queryByTestId("url-mention")).toBeNull();
  });
});
