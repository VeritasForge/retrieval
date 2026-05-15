"use client";

import { useState } from "react";
import useSWR from "swr";
import { Link as LinkIcon } from "lucide-react";

type Metadata = {
  title: string | null;
  faviconUrl: string | null;
  host: string;
};

function getHost(url: string): string {
  try {
    return new URL(url).host;
  } catch {
    return url;
  }
}

const fetcher = async (url: string): Promise<Metadata> => {
  const res = await fetch(url);
  if (!res.ok) throw new Error("fetch failed");
  return res.json();
};

export function UrlMention({ url }: { url: string }) {
  const apiUrl = `/api/url-metadata?url=${encodeURIComponent(url)}`;
  const { data, error } = useSWR<Metadata>(apiUrl, fetcher, {
    revalidateOnFocus: false,
    dedupingInterval: 60_000,
    shouldRetryOnError: false,
  });
  const [faviconFailed, setFaviconFailed] = useState(false); // H1

  const fallbackHost = getHost(url);
  const label =
    !data || error || !data.title ? (data?.host ?? fallbackHost) : data.title;
  const favicon = data?.faviconUrl ?? null;
  const showFavicon = favicon && !faviconFailed; // H1

  return (
    <a
      href={url}
      target="_blank"
      rel="noopener noreferrer"
      className="inline-flex items-center gap-1 hover:underline text-primary"
    >
      {showFavicon ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={favicon}
          alt="favicon"
          className="h-3 w-3"
          aria-hidden
          onError={() => setFaviconFailed(true)} // H1
        />
      ) : (
        <LinkIcon className="h-3 w-3" aria-hidden />
      )}
      <span className="truncate">{label}</span>
    </a>
  );
}
