import { describe, it, expect, vi } from "vitest";
import { validateUrlForFetch } from "./url-validate";

// dns.lookup mocking
vi.mock("node:dns/promises", () => ({
  lookup: vi.fn(async (host: string) => {
    if (host === "wikipedia.org") return { address: "208.80.154.224", family: 4 };
    if (host === "localhost") return { address: "127.0.0.1", family: 4 };
    if (host === "internal.local") return { address: "10.0.0.1", family: 4 };
    if (host === "linklocal.test") return { address: "169.254.1.1", family: 4 };
    if (host === "ipv6.test") return { address: "::1", family: 6 };
    if (host === "unresolvable.test") throw new Error("ENOTFOUND");
    return { address: "1.2.3.4", family: 4 };
  }),
}));

describe("validateUrlForFetch", () => {
  // [Happy]
  it("[Happy] public URL 허용", async () => {
    const result = await validateUrlForFetch("https://wikipedia.org/foo");
    expect(result.ok).toBe(true);
  });

  // [Boundary]
  it("[Boundary] HTTP (HTTPS 아닌) 허용", async () => {
    const result = await validateUrlForFetch("http://wikipedia.org/foo");
    expect(result.ok).toBe(true);
  });

  // [Error]
  it("[Error] ftp:// 스킴 거부", async () => {
    const result = await validateUrlForFetch("ftp://wikipedia.org/foo");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/scheme/i);
  });

  it("[Error] localhost (127.0.0.1) 거부", async () => {
    const result = await validateUrlForFetch("http://localhost/foo");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/private|loopback/i);
  });

  it("[Error] RFC1918 사설 IP (10.x) 거부", async () => {
    const result = await validateUrlForFetch("http://internal.local/foo");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/private/i);
  });

  it("[Error] link-local (169.254.x) 거부", async () => {
    const result = await validateUrlForFetch("http://linklocal.test/foo");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/link-local|private/i);
  });

  it("[Error] IPv6 loopback (::1) 거부", async () => {
    const result = await validateUrlForFetch("http://ipv6.test/foo");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/loopback/i);
  });

  it("[Error] DNS 해석 실패 거부", async () => {
    const result = await validateUrlForFetch("http://unresolvable.test/foo");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/dns|resolve/i);
  });
});
