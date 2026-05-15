import { describe, it, expect } from "vitest";
import { normalizeUrl } from "./url-normalize";

describe("normalizeUrl", () => {
  // [Happy]
  it("[Happy] 표준 URL은 그대로", () => {
    expect(normalizeUrl("https://wikipedia.org/wiki/Foo")).toBe("https://wikipedia.org/wiki/Foo");
  });

  // [Boundary]
  it("[Boundary] trailing slash 제거 (root path 제외)", () => {
    expect(normalizeUrl("https://wikipedia.org/wiki/Foo/")).toBe("https://wikipedia.org/wiki/Foo");
  });

  it("[Boundary] root path는 trailing slash 유지", () => {
    expect(normalizeUrl("https://wikipedia.org/")).toBe("https://wikipedia.org/");
  });

  it("[Boundary] fragment 제거 + host lowercase + scheme lowercase", () => {
    expect(normalizeUrl("HTTPS://Wikipedia.ORG/wiki/Foo#section")).toBe("https://wikipedia.org/wiki/Foo");
  });

  it("[Boundary] credentials(user:pass@host) strip (H3 — 캐시 키/응답 노출 방지)", () => {
    expect(normalizeUrl("https://user:secret@example.com/path")).toBe("https://example.com/path");
  });

  // [Error]
  it("[Error] 잘못된 URL은 입력 그대로 반환 (fallback)", () => {
    expect(normalizeUrl("not a url")).toBe("not a url");
  });
});
