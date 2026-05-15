import { describe, it, expect } from "vitest";
import { parseHtmlMetadata } from "./html-metadata";

const baseUrl = "https://example.com/page";

describe("parseHtmlMetadata", () => {
  // [Happy]
  it("[Happy] title과 favicon 추출", () => {
    const html = `<html><head><title>Foo</title><link rel="icon" href="/icon.png" /></head><body></body></html>`;
    expect(parseHtmlMetadata(html, baseUrl)).toEqual({
      title: "Foo",
      faviconUrl: "https://example.com/icon.png",
    });
  });

  it("[Happy] absolute favicon URL", () => {
    const html = `<html><head><title>Foo</title><link rel="icon" href="https://cdn.example.com/icon.png" /></head></html>`;
    expect(parseHtmlMetadata(html, baseUrl)).toEqual({
      title: "Foo",
      faviconUrl: "https://cdn.example.com/icon.png",
    });
  });

  // [Boundary]
  it("[Boundary] title 없으면 null", () => {
    const html = `<html><head></head><body></body></html>`;
    expect(parseHtmlMetadata(html, baseUrl).title).toBeNull();
  });

  it("[Boundary] favicon 없으면 /favicon.ico fallback", () => {
    const html = `<html><head><title>Foo</title></head></html>`;
    expect(parseHtmlMetadata(html, baseUrl).faviconUrl).toBe("https://example.com/favicon.ico");
  });

  it("[Boundary] title 앞뒤 공백 trim", () => {
    const html = `<html><head><title>  Foo  </title></head></html>`;
    expect(parseHtmlMetadata(html, baseUrl).title).toBe("Foo");
  });

  // [Error]
  it("[Error] 잘못된 HTML도 그대로 처리 (parser가 관대함)", () => {
    const html = `not html`;
    const result = parseHtmlMetadata(html, baseUrl);
    expect(result.title).toBeNull();
    expect(result.faviconUrl).toBe("https://example.com/favicon.ico");
  });
});
