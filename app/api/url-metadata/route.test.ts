// @vitest-environment node
import { describe, it, expect, vi, beforeEach } from "vitest";

// auth mocking
vi.mock("@/lib/auth-utils", () => ({
  getAuthUserId: vi.fn(),
  unauthorized: () => new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 }),
}));

// url-validate mocking — 실제 DNS 호출 회피
vi.mock("@/lib/url-validate", () => ({
  validateUrlForFetch: vi.fn(),
}));

// next/cache mocking — vitest 환경엔 incrementalCache 없음
vi.mock("next/cache", () => ({
  unstable_cache: <T extends (...args: any[]) => any>(fn: T) => fn,
}));

// fetch mocking
const fetchMock = vi.fn();
global.fetch = fetchMock as any;

import { GET } from "./route";
import { getAuthUserId } from "@/lib/auth-utils";
import { validateUrlForFetch } from "@/lib/url-validate";

function makeRequest(url: string) {
  return new Request(`http://localhost/api/url-metadata?url=${encodeURIComponent(url)}`);
}

describe("GET /api/url-metadata", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // [Happy]
  it("[Happy] 인증 + 검증 + fetch 성공 시 title/favicon 반환", async () => {
    vi.mocked(getAuthUserId).mockResolvedValue("user-1");
    vi.mocked(validateUrlForFetch).mockResolvedValue({ ok: true, resolvedAddress: "1.2.3.4" });
    fetchMock.mockResolvedValue({
      ok: true,
      status: 200,
      headers: new Map([["content-length", "200"]]),
      text: async () => `<html><head><title>Foo</title><link rel="icon" href="/i.png" /></head></html>`,
    });

    const res = await GET(makeRequest("https://example.com/foo"));
    const json = await res.json();
    expect(res.status).toBe(200);
    expect(json.title).toBe("Foo");
    expect(json.faviconUrl).toBe("https://example.com/i.png");
    expect(json.host).toBe("example.com");
  });

  // [Happy] C2: redirect 1회 정상 따라감
  it("[Happy] redirect 1회 + Location 재검증 통과 시 최종 응답 처리", async () => {
    vi.mocked(getAuthUserId).mockResolvedValue("user-1");
    vi.mocked(validateUrlForFetch).mockResolvedValue({ ok: true, resolvedAddress: "1.2.3.4" });
    fetchMock
      .mockResolvedValueOnce({
        ok: false,
        status: 301,
        headers: new Map([["location", "https://example.com/final"]]),
      })
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        headers: new Map([["content-length", "100"]]),
        text: async () => `<html><head><title>Final</title></head></html>`,
      });

    const res = await GET(makeRequest("https://example.com/foo"));
    const json = await res.json();
    expect(json.title).toBe("Final");
  });

  // [Boundary]
  it("[Boundary] fetch가 실패해도 200 + host fallback", async () => {
    vi.mocked(getAuthUserId).mockResolvedValue("user-1");
    vi.mocked(validateUrlForFetch).mockResolvedValue({ ok: true, resolvedAddress: "1.2.3.4" });
    fetchMock.mockRejectedValue(new Error("network"));

    const res = await GET(makeRequest("https://example.com/foo"));
    const json = await res.json();
    expect(res.status).toBe(200);
    expect(json.title).toBeNull();
    expect(json.host).toBe("example.com");
  });

  // [Boundary] C2: redirect 의 Location 이 사설 IP면 fallback
  it("[Boundary] redirect Location 이 검증 실패 시 host fallback", async () => {
    vi.mocked(getAuthUserId).mockResolvedValue("user-1");
    vi.mocked(validateUrlForFetch)
      .mockResolvedValueOnce({ ok: true, resolvedAddress: "1.2.3.4" })  // 첫 URL
      .mockResolvedValueOnce({ ok: false, reason: "private ipv4 address" });  // Location
    fetchMock.mockResolvedValueOnce({
      ok: false,
      status: 301,
      headers: new Map([["location", "http://10.0.0.1/internal"]]),
    });

    const res = await GET(makeRequest("https://example.com/foo"));
    const json = await res.json();
    expect(json.title).toBeNull();
    expect(json.host).toBe("example.com");
  });

  // [Error]
  it("[Error] 비인증 → 401", async () => {
    vi.mocked(getAuthUserId).mockResolvedValue(null);

    const res = await GET(makeRequest("https://example.com/foo"));
    expect(res.status).toBe(401);
  });

  it("[Error] URL 누락 → 400", async () => {
    vi.mocked(getAuthUserId).mockResolvedValue("user-1");

    const req = new Request("http://localhost/api/url-metadata");
    const res = await GET(req);
    expect(res.status).toBe(400);
  });

  it("[Error] 사설 IP/스킴 차단 → 400", async () => {
    vi.mocked(getAuthUserId).mockResolvedValue("user-1");
    vi.mocked(validateUrlForFetch).mockResolvedValue({ ok: false, reason: "private ipv4 address" });

    const res = await GET(makeRequest("http://10.0.0.1/foo"));
    expect(res.status).toBe(400);
  });
});
