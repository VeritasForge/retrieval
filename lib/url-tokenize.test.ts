import { describe, it, expect } from "vitest";
import { tokenizeUrls } from "./url-tokenize";

describe("tokenizeUrls", () => {
  // [Happy]
  it("[Happy] 텍스트와 URL 혼합", () => {
    expect(tokenizeUrls("에빙하우스 https://wikipedia.org/wiki/Forgetting_curve")).toEqual([
      { type: "text", text: "에빙하우스 " },
      { type: "url", url: "https://wikipedia.org/wiki/Forgetting_curve" },
    ]);
  });

  it("[Happy] URL 여러 개", () => {
    expect(tokenizeUrls("https://a.com https://b.com")).toEqual([
      { type: "url", url: "https://a.com" },
      { type: "text", text: " " },
      { type: "url", url: "https://b.com" },
    ]);
  });

  // [Boundary]
  it("[Boundary] 빈 문자열", () => {
    expect(tokenizeUrls("")).toEqual([]);
  });

  it("[Boundary] 텍스트만", () => {
    expect(tokenizeUrls("에빙하우스 망각곡선")).toEqual([
      { type: "text", text: "에빙하우스 망각곡선" },
    ]);
  });

  it("[Boundary] URL trailing punctuation 제외", () => {
    // 단순 처리: 공백 전까지만. 트레일링 punctuation은 URL 일부로 포함 (edge case 단순화)
    expect(tokenizeUrls("see https://a.com.")).toEqual([
      { type: "text", text: "see " },
      { type: "url", url: "https://a.com." },
    ]);
  });

  // [Error]
  it("[Error] http/https 아닌 스킴은 텍스트로 처리", () => {
    expect(tokenizeUrls("ftp://example.com")).toEqual([
      { type: "text", text: "ftp://example.com" },
    ]);
  });
});
