import { lookup } from "node:dns/promises";
import { isIPv4, isIPv6 } from "node:net";

const ALLOWED_SCHEMES = ["http:", "https:"];

export type UrlValidationResult =
  | { ok: true; resolvedAddress: string }
  | { ok: false; reason: string };

function isPrivateIPv4(ip: string): boolean {
  if (!isIPv4(ip)) return false;
  const parts = ip.split(".").map(Number);
  // loopback 127.0.0.0/8
  if (parts[0] === 127) return true;
  // RFC1918: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
  if (parts[0] === 10) return true;
  if (parts[0] === 172 && parts[1] >= 16 && parts[1] <= 31) return true;
  if (parts[0] === 192 && parts[1] === 168) return true;
  // link-local 169.254.0.0/16
  if (parts[0] === 169 && parts[1] === 254) return true;
  // 0.0.0.0/8 (current network)
  if (parts[0] === 0) return true;
  return false;
}

function isPrivateIPv6(ip: string): boolean {
  if (!isIPv6(ip)) return false;
  const lower = ip.toLowerCase();
  if (lower === "::1") return true; // loopback
  if (lower.startsWith("fc") || lower.startsWith("fd")) return true; // ULA fc00::/7
  if (lower.startsWith("fe80:")) return true; // link-local
  if (lower === "::") return true; // unspecified
  return false;
}

export async function validateUrlForFetch(rawUrl: string): Promise<UrlValidationResult> {
  let parsed: URL;
  try {
    parsed = new URL(rawUrl);
  } catch {
    return { ok: false, reason: "invalid url" };
  }

  if (!ALLOWED_SCHEMES.includes(parsed.protocol)) {
    return { ok: false, reason: "scheme not allowed" };
  }

  let address: string;
  try {
    const result = await lookup(parsed.hostname);
    address = result.address;
  } catch {
    return { ok: false, reason: "dns resolve failed" };
  }

  if (isPrivateIPv4(address)) {
    return { ok: false, reason: "private ipv4 address" };
  }
  if (isPrivateIPv6(address)) {
    return { ok: false, reason: "loopback or private ipv6 address" };
  }

  return { ok: true, resolvedAddress: address };
}
