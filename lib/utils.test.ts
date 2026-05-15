import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { today, addDays, daysBetween, isPast, formatDate } from "./utils";

describe("KST timezone utils", () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  describe("today()", () => {
    it("KST 자정 직후 — UTC 15:00은 다음날 00:00 KST", () => {
      // 2026-05-09 15:00 UTC = 2026-05-10 00:00 KST
      vi.setSystemTime(new Date("2026-05-09T15:00:00Z"));
      expect(today()).toBe("2026-05-10");
    });

    it("KST 자정 직전 — UTC 14:59은 같은날 23:59 KST", () => {
      // 2026-05-09 14:59 UTC = 2026-05-09 23:59 KST
      vi.setSystemTime(new Date("2026-05-09T14:59:00Z"));
      expect(today()).toBe("2026-05-09");
    });

    it("UTC 자정과 KST는 9시간 차이", () => {
      // 2026-05-09 00:00 UTC = 2026-05-09 09:00 KST → 2026-05-09
      vi.setSystemTime(new Date("2026-05-09T00:00:00Z"));
      expect(today()).toBe("2026-05-09");
    });
  });

  describe("addDays()", () => {
    it("양수 일수 추가", () => {
      expect(addDays("2026-01-01", 3)).toBe("2026-01-04");
    });

    it("음수 일수 빼기", () => {
      expect(addDays("2026-01-04", -3)).toBe("2026-01-01");
    });

    it("월 경계 넘기", () => {
      expect(addDays("2026-01-30", 5)).toBe("2026-02-04");
    });

    it("연도 경계 넘기", () => {
      expect(addDays("2025-12-30", 5)).toBe("2026-01-04");
    });

    it("0일 추가는 동일 날짜", () => {
      expect(addDays("2026-05-09", 0)).toBe("2026-05-09");
    });
  });

  describe("daysBetween()", () => {
    it("미래 - 과거 = 양수", () => {
      expect(daysBetween("2026-01-01", "2026-01-04")).toBe(3);
    });

    it("같은 날 = 0", () => {
      expect(daysBetween("2026-05-09", "2026-05-09")).toBe(0);
    });

    it("과거 - 미래 = 음수", () => {
      expect(daysBetween("2026-01-04", "2026-01-01")).toBe(-3);
    });

    it("월 경계 정확", () => {
      expect(daysBetween("2026-01-30", "2026-02-04")).toBe(5);
    });
  });

  describe("isPast()", () => {
    it("과거 날짜 true", () => {
      vi.setSystemTime(new Date("2026-05-09T03:00:00Z")); // KST 12:00
      expect(isPast("2026-05-08")).toBe(true);
    });

    it("오늘 false", () => {
      vi.setSystemTime(new Date("2026-05-09T03:00:00Z"));
      expect(isPast("2026-05-09")).toBe(false);
    });

    it("미래 false", () => {
      vi.setSystemTime(new Date("2026-05-09T03:00:00Z"));
      expect(isPast("2026-05-10")).toBe(false);
    });
  });

  describe("formatDate()", () => {
    it("ko-KR locale로 포맷", () => {
      const result = formatDate("2026-05-09");
      // ko-KR: "2026년 5월 9일"
      expect(result).toContain("2026");
      expect(result).toContain("5");
      expect(result).toContain("9");
    });
  });
});
