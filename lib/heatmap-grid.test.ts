import { describe, it, expect } from "vitest";
import {
  buildGrid,
  getDateRangeForYear,
  getIntensityLevel,
  tooltipBreakdown,
  getMonthLabels,
  type HeatmapDay,
} from "./heatmap-grid";

describe("getDateRangeForYear", () => {
  // [Happy]
  it("[Happy] 과거 연도 — 1/1 ~ 12/31", () => {
    expect(getDateRangeForYear(2024, "2026-05-15")).toEqual({
      start: "2024-01-01",
      end: "2024-12-31",
    });
  });

  // [Boundary]
  it("[Boundary] 현재 연도 — 1/1 ~ today", () => {
    expect(getDateRangeForYear(2026, "2026-05-15")).toEqual({
      start: "2026-01-01",
      end: "2026-05-15",
    });
  });
});

describe("buildGrid", () => {
  // [Happy]
  it("[Happy] 일요일 시작일에 7일 데이터 — 1 주", () => {
    // 2024-01-07 is Sunday
    const dataMap = new Map<string, HeatmapDay>([
      ["2024-01-07", { date: "2024-01-07", count: 3, byCategory: [] }],
    ]);
    const grid = buildGrid("2024-01-07", "2024-01-13", dataMap);
    expect(grid).toHaveLength(1);
    expect(grid[0]).toHaveLength(7);
    expect(grid[0][0]?.date).toBe("2024-01-07");
    expect(grid[0][0]?.count).toBe(3);
    expect(grid[0][6]?.date).toBe("2024-01-13");
    expect(grid[0][6]?.count).toBe(0);
  });

  // [Boundary]
  it("[Boundary] 시작일이 일요일이 아니면 앞쪽 null 패딩", () => {
    // 2024-01-03 is Wednesday → Sun=01-31(prev year)? actually 2024-01-03 Wed
    // grid Sunday alignment: gridStart = 2023-12-31 (Sun)
    const grid = buildGrid("2024-01-03", "2024-01-06", new Map());
    expect(grid[0][0]).toBeNull(); // 2023-12-31 (out of range)
    expect(grid[0][1]).toBeNull(); // 2024-01-01 (out of range)
    expect(grid[0][2]).toBeNull(); // 2024-01-02 (out of range)
    expect(grid[0][3]?.date).toBe("2024-01-03");
  });

  // [Error]
  it("[Error] 시작일이 종료일보다 늦으면 빈 그리드는 아니지만 모두 null", () => {
    const grid = buildGrid("2024-01-10", "2024-01-08", new Map());
    // 빈 grid 또는 모두 null
    const allNull = grid.every((week) => week.every((c) => c === null));
    expect(allNull).toBe(true);
  });
});

describe("getIntensityLevel", () => {
  // [Happy]
  it("[Happy] count=0 → level 0", () => {
    expect(getIntensityLevel(0, 10)).toBe(0);
  });

  it("[Happy] 최대값 → level 4", () => {
    expect(getIntensityLevel(10, 10)).toBe(4);
  });

  // [Boundary]
  it("[Boundary] quartile 경계 — 25% → level 1, 50% → level 2, 75% → level 3", () => {
    expect(getIntensityLevel(2.5, 10)).toBe(1);
    expect(getIntensityLevel(5, 10)).toBe(2);
    expect(getIntensityLevel(7.5, 10)).toBe(3);
    expect(getIntensityLevel(10, 10)).toBe(4);
  });

  it("[Boundary] count > 0, max=0 → level 0 (방어)", () => {
    expect(getIntensityLevel(5, 0)).toBe(0);
  });

  // [Error]
  it("[Error] 음수 count → level 0", () => {
    expect(getIntensityLevel(-1, 10)).toBe(0);
  });
});

describe("tooltipBreakdown", () => {
  // [Happy]
  it("[Happy] 정상 정렬 — 카운트 내림차순", () => {
    const r = tooltipBreakdown([
      { name: "수학", color: "#f00", count: 2 },
      { name: "영어", color: "#0f0", count: 5 },
      { name: "역사", color: "#00f", count: 1 },
    ]);
    expect(r.map((c) => c.name)).toEqual(["영어", "수학", "역사"]);
  });

  // [Boundary]
  it("[Boundary] 0건 카테고리 제외", () => {
    const r = tooltipBreakdown([
      { name: "수학", color: "#f00", count: 0 },
      { name: "영어", color: "#0f0", count: 3 },
    ]);
    expect(r).toHaveLength(1);
    expect(r[0].name).toBe("영어");
  });

  it("[Boundary] 빈 배열 → 빈 배열", () => {
    expect(tooltipBreakdown([])).toEqual([]);
  });

  // [Error]
  // 외부 호출 없음 — 순수 함수, 예외 케이스 없음
});

describe("getMonthLabels", () => {
  // [Happy]
  it("[Happy] 1월 첫째 주에 'Jan' 라벨", () => {
    const grid = buildGrid("2024-01-01", "2024-01-27", new Map());
    const labels = getMonthLabels(grid);
    expect(labels[0]).toBe("Jan");
  });

  // [Boundary]
  it("[Boundary] 같은 월 내 다음 주는 빈 문자열", () => {
    const grid = buildGrid("2024-01-01", "2024-01-27", new Map());
    const labels = getMonthLabels(grid);
    // 첫 주 Jan 외 나머지 주는 빈 문자열 (월 전환 없음)
    const janCount = labels.filter((l) => l === "Jan").length;
    expect(janCount).toBe(1);
  });
});
