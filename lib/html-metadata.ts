import { parse } from "node-html-parser";

export type ParsedMetadata = {
  title: string | null;
  faviconUrl: string | null;
};

export function parseHtmlMetadata(html: string, baseUrl: string): ParsedMetadata {
  const root = parse(html);

  const titleEl = root.querySelector("title");
  const titleText = titleEl?.text?.trim() ?? "";
  const title = titleText === "" ? null : titleText;

  const iconLink =
    root.querySelector("link[rel='icon']") ??
    root.querySelector("link[rel='shortcut icon']");
  const iconHref = iconLink?.getAttribute("href");

  let faviconUrl: string | null = null;
  try {
    if (iconHref) {
      faviconUrl = new URL(iconHref, baseUrl).toString();
    } else {
      faviconUrl = new URL("/favicon.ico", baseUrl).toString();
    }
  } catch {
    faviconUrl = null;
  }

  return { title, faviconUrl };
}
