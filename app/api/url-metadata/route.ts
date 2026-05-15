import { NextResponse } from "next/server";
import { unstable_cache } from "next/cache";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { validateUrlForFetch } from "@/lib/url-validate";
import { normalizeUrl } from "@/lib/url-normalize";
import { parseHtmlMetadata } from "@/lib/html-metadata";

const FETCH_TIMEOUT_MS = 5000;
const MAX_RESPONSE_BYTES = 1024 * 1024; // 1MB
const REVALIDATE_SECONDS = 60 * 60 * 24 * 14; // 14 days

type Metadata = {
  title: string | null;
  faviconUrl: string | null;
  host: string;
};

async function fetchOnce(target: string): Promise<Response | null> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
  try {
    return await fetch(target, {
      signal: controller.signal,
      redirect: "manual",  // C2: 수동 redirect 처리
      headers: { "User-Agent": "retrieval-web/1.0" },
    });
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

async function fetchAndParseMetadata(url: string): Promise<Metadata> {
  const host = new URL(url).host;
  const fallback: Metadata = { title: null, faviconUrl: null, host };

  try {
    let res = await fetchOnce(url);
    if (!res) return fallback;

    // C2: redirect 1회만 허용 + Location 재검증
    if (res.status >= 300 && res.status < 400) {
      const location = res.headers.get("location");
      if (!location) return fallback;
      const absolute = new URL(location, url).toString();
      const validation = await validateUrlForFetch(absolute);
      if (!validation.ok) return fallback;
      res = await fetchOnce(absolute);
      if (!res) return fallback;
      // 두 번째 redirect는 거부 (1회만 허용)
      if (res.status >= 300 && res.status < 400) return fallback;
    }

    if (!res.ok) return fallback;

    // C3: Content-Length 사전 검사 + text() 후 크기 검증
    const lenHeader = res.headers.get("content-length");
    if (lenHeader && Number(lenHeader) > MAX_RESPONSE_BYTES) return fallback;

    const html = await res.text();
    if (html.length > MAX_RESPONSE_BYTES) return fallback;

    const parsed = parseHtmlMetadata(html, url);
    return { title: parsed.title, faviconUrl: parsed.faviconUrl, host };
  } catch {
    return fallback;
  }
}

const getCachedMetadata = unstable_cache(
  async (url: string): Promise<Metadata> => fetchAndParseMetadata(url),
  ["url-metadata"],
  { revalidate: REVALIDATE_SECONDS, tags: ["url-metadata"] }
);

export async function GET(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();

  const { searchParams } = new URL(request.url);
  const rawUrl = searchParams.get("url");
  if (!rawUrl) {
    return NextResponse.json({ error: "missing url" }, { status: 400 });
  }

  const validation = await validateUrlForFetch(rawUrl);
  if (!validation.ok) {
    return NextResponse.json({ error: validation.reason }, { status: 400 });
  }

  const normalized = normalizeUrl(rawUrl);
  const metadata = await getCachedMetadata(normalized);
  return NextResponse.json(metadata);
}
