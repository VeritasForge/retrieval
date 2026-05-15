import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  calculateNextFixedDate,
  calculateNextSm2Date,
  calculateFirstReviewDate,
} from "./review-scheduler";

describe("calculateNextFixedDate (현재 동작 보존 검증)", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    // 2026-05-09 KST 기준
    vi.setSystemTime(new Date("2026-05-09T03:00:00Z"));
  });
  afterEach(() => vi.useRealTimers());

  it("정시 진행 — studyDate + intervals[nextLevel]", () => {
    // studyDate=2026-05-09, intervals=[1,3,7,14,30], nextLevel=1 → +3일
    expect(calculateNextFixedDate("2026-05-09", [1, 3, 7, 14, 30], 1)).toBe("2026-05-12");
  });

  it("studyDate + intervals[i]가 과거이면 today()로 클램프", () => {
    // studyDate=2026-04-01, today=2026-05-09, intervals[1]=3 → 2026-04-04 → 과거 → today
    expect(calculateNextFixedDate("2026-04-01", [1, 3, 7, 14, 30], 1)).toBe("2026-05-09");
  });

  it("마지막 단계 (nextLevel >= intervals.length) → null", () => {
    expect(calculateNextFixedDate("2026-05-09", [1, 3, 7, 14, 30], 5)).toBeNull();
  });

  it("nextLevel === intervals.length-1 → 마지막 유효 인덱스", () => {
    expect(calculateNextFixedDate("2026-05-09", [1, 3, 7, 14, 30], 4)).toBe("2026-06-08");
  });
});

describe("calculateNextSm2Date", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-05-09T03:00:00Z"));
  });
  afterEach(() => vi.useRealTimers());

  it("today + interval", () => {
    expect(calculateNextSm2Date(7)).toBe("2026-05-16");
  });

  it("interval 1일", () => {
    expect(calculateNextSm2Date(1)).toBe("2026-05-10");
  });
});

describe("calculateFirstReviewDate", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-05-09T03:00:00Z"));
  });
  afterEach(() => vi.useRealTimers());

  it("Fixed 전략 — studyDate + intervals[0]", () => {
    expect(calculateFirstReviewDate("2026-05-09", "fixed", [1, 3, 7])).toBe("2026-05-10");
  });

  it("Fixed 전략 — intervals[0]이 0인 경우 최소 tomorrow 보장", () => {
    expect(calculateFirstReviewDate("2026-05-09", "fixed", [0, 3, 7])).toBe("2026-05-10");
  });

  it("SM-2 전략 — tomorrow", () => {
    expect(calculateFirstReviewDate("2026-05-09", "sm2", null)).toBe("2026-05-10");
  });

  it("studyDate가 과거인 경우 today() 클램프", () => {
    expect(calculateFirstReviewDate("2026-04-01", "fixed", [1, 3, 7])).toBe("2026-05-09");
  });
});
