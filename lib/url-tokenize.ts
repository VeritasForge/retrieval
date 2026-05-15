export type UrlToken =
  | { type: "text"; text: string }
  | { type: "url"; url: string };

const URL_PATTERN = /https?:\/\/[^\s]+/g;

export function tokenizeUrls(input: string): UrlToken[] {
  if (!input) return [];

  const tokens: UrlToken[] = [];
  let lastIndex = 0;
  for (const match of input.matchAll(URL_PATTERN)) {
    const start = match.index ?? 0;
    if (start > lastIndex) {
      tokens.push({ type: "text", text: input.slice(lastIndex, start) });
    }
    tokens.push({ type: "url", url: match[0] });
    lastIndex = start + match[0].length;
  }
  if (lastIndex < input.length) {
    tokens.push({ type: "text", text: input.slice(lastIndex) });
  }
  return tokens;
}
