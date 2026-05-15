import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

const KST_FORMATTER = new Intl.DateTimeFormat("en-CA", {
  timeZone: "Asia/Seoul",
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
});

const KST_DISPLAY_FORMATTER = new Intl.DateTimeFormat("ko-KR", {
  timeZone: "Asia/Seoul",
  year: "numeric",
  month: "long",
  day: "numeric",
});

function dateStringToKstMillis(dateStr: string): number {
  const [y, m, d] = dateStr.split("-").map(Number);
  // KST 자정(UTC+9) → UTC epoch ms
  return Date.UTC(y, m - 1, d, -9, 0, 0, 0);
}

function kstMillisToDateString(ms: number): string {
  return KST_FORMATTER.format(new Date(ms));
}

export function today(): string {
  return KST_FORMATTER.format(new Date());
}

export function addDays(dateStr: string, days: number): string {
  const base = dateStringToKstMillis(dateStr);
  return kstMillisToDateString(base + days * 86400000);
}

export function daysBetween(from: string, to: string): number {
  const a = dateStringToKstMillis(from);
  const b = dateStringToKstMillis(to);
  return Math.round((b - a) / 86400000);
}

export function isPast(dateStr: string): boolean {
  return dateStr < today();
}

export function formatDate(dateStr: string): string {
  return KST_DISPLAY_FORMATTER.format(new Date(dateStringToKstMillis(dateStr)));
}
