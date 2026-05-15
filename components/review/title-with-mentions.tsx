"use client";

import { tokenizeUrls } from "@/lib/url-tokenize";
import { UrlMention } from "./url-mention";

export function TitleWithMentions({ title }: { title: string }) {
  const tokens = tokenizeUrls(title);
  // H2: 0 토큰이면 row 2 자체를 숨김 (카드 높이 일관)
  if (tokens.length === 0) return null;
  return (
    <p className="text-sm text-muted-foreground truncate">
      {tokens.map((tok, i) =>
        tok.type === "url" ? (
          <UrlMention key={i} url={tok.url} />
        ) : (
          <span key={i}>{tok.text}</span>
        )
      )}
    </p>
  );
}
