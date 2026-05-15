// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import { SWRConfig } from "swr";
import { UrlMention } from "./url-mention";

const fetchMock = vi.fn();
global.fetch = fetchMock as unknown as typeof fetch;

// C4: 매 테스트별 fresh SWR cache provider
function renderWithFreshCache(ui: React.ReactElement) {
  return render(
    <SWRConfig value={{ provider: () => new Map() }}>{ui}</SWRConfig>
  );
}

describe("UrlMention", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // [Happy]
  it("[Happy] metadata 성공 시 title 표시", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({
        title: "Foo",
        faviconUrl: "https://example.com/i.png",
        host: "example.com",
      }),
    });
    renderWithFreshCache(<UrlMention url="https://example.com/foo" />);
    await waitFor(() => expect(screen.getByText("Foo")).toBeTruthy());

    const link = screen.getByRole("link") as HTMLAnchorElement;
    expect(link.href).toBe("https://example.com/foo");
    expect(link.target).toBe("_blank");
    expect(link.rel).toBe("noopener noreferrer");
  });

  // [Boundary]
  it("[Boundary] 로딩 중 host fallback", async () => {
    // fetch 미해결 (pending). fresh cache provider라 [Happy] 캐시 영향 없음
    fetchMock.mockReturnValue(new Promise(() => {}));
    renderWithFreshCache(<UrlMention url="https://example.com/foo" />);
    expect(screen.getByText("example.com")).toBeTruthy();
  });

  it("[Boundary] title이 null이면 host로", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({ title: null, faviconUrl: null, host: "example.com" }),
    });
    renderWithFreshCache(<UrlMention url="https://example.com/foo" />);
    await waitFor(() => expect(screen.getByText("example.com")).toBeTruthy());
  });

  // [Boundary] H1: favicon 로드 실패 시 LinkIcon fallback
  it("[Boundary] favicon img onError 시 LinkIcon으로 fallback", async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({
        title: "Foo",
        faviconUrl: "https://example.com/dead-favicon.png",
        host: "example.com",
      }),
    });
    renderWithFreshCache(<UrlMention url="https://example.com/foo" />);
    const img = await screen.findByRole("img", { hidden: true });
    fireEvent.error(img);
    // onError 후 LinkIcon (img가 사라지고 svg로 교체)
    await waitFor(() => {
      expect(screen.queryByRole("img", { hidden: true })).toBeNull();
    });
  });

  // [Error]
  it("[Error] fetch 실패 시 host fallback", async () => {
    fetchMock.mockRejectedValue(new Error("network"));
    renderWithFreshCache(<UrlMention url="https://example.com/foo" />);
    await waitFor(() => expect(screen.getByText("example.com")).toBeTruthy());
  });
});
