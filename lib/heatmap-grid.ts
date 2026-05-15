export type HeatmapCategoryCount = {
  name: string;
  color: string;
  count: number;
};

export type HeatmapDay = {
  date: string;
  count: number;
  byCategory: HeatmapCategoryCount[];
};

export type GridCell = HeatmapDay | { date: string; count: 0; byCategory: [] };

const MS_PER_DAY = 86400000;

function pad2(n: number): string {
  return n < 10 ? `0${n}` : String(n);
}

function toISODate(d: Date): string {
  return `${d.getUTCFullYear()}-${pad2(d.getUTCMonth() + 1)}-${pad2(d.getUTCDate())}`;
}

function utcDate(year: number, month: number, day: number): Date {
  return new Date(Date.UTC(year, month, day));
}

export function getDateRangeForYear(
  year: number,
  todayISO: string
): { start: string; end: string } {
  const currentYear = parseInt(todayISO.slice(0, 4), 10);
  if (year === currentYear) {
    return { start: toISODate(utcDate(year, 0, 1)), end: todayISO };
  }
  return {
    start: toISODate(utcDate(year, 0, 1)),
    end: toISODate(utcDate(year, 11, 31)),
  };
}

/**
 * GitHub-style 주별 그리드 빌드.
 * 컬럼: 각 주의 일요일을 기준 (Sun=0)
 * 행: 요일 (0=Sun ~ 6=Sat)
 *
 * - end 이후 날짜는 그리드 컬럼에 포함될 수 있지만 `null` 셀로 표시
 * - 가장 첫 컬럼은 start 직전의 일요일까지 거슬러 가서 7일 단위 정렬
 */
export function buildGrid(
  start: string,
  end: string,
  dataByDate: Map<string, HeatmapDay>
): (GridCell | null)[][] {
  const [sy, sm, sd] = start.split("-").map(Number);
  const [ey, em, ed] = end.split("-").map(Number);
  const startDate = utcDate(sy, sm - 1, sd);
  const endDate = utcDate(ey, em - 1, ed);

  // 시작 컬럼을 일요일로 정렬
  const startWeekday = startDate.getUTCDay();
  const gridStart = new Date(startDate.getTime() - startWeekday * MS_PER_DAY);

  // 끝 컬럼은 endDate가 속한 주의 토요일까지
  const endWeekday = endDate.getUTCDay();
  const gridEnd = new Date(
    endDate.getTime() + (6 - endWeekday) * MS_PER_DAY
  );

  const totalDays =
    Math.round((gridEnd.getTime() - gridStart.getTime()) / MS_PER_DAY) + 1;
  const totalWeeks = Math.ceil(totalDays / 7);

  const grid: (GridCell | null)[][] = [];
  for (let w = 0; w < totalWeeks; w++) {
    const week: (GridCell | null)[] = [];
    for (let d = 0; d < 7; d++) {
      const cur = new Date(gridStart.getTime() + (w * 7 + d) * MS_PER_DAY);
      const iso = toISODate(cur);
      if (cur < startDate || cur > endDate) {
        week.push(null);
      } else {
        const data = dataByDate.get(iso);
        week.push(data ?? { date: iso, count: 0, byCategory: [] });
      }
    }
    grid.push(week);
  }
  return grid;
}

/**
 * GitHub style 5단계 강도 (0~4).
 * 0 = 활동 없음
 * 1~4 = quartile 기반 분류
 */
export function getIntensityLevel(count: number, max: number): 0 | 1 | 2 | 3 | 4 {
  if (count <= 0) return 0;
  if (max <= 0) return 0;
  const ratio = count / max;
  if (ratio <= 0.25) return 1;
  if (ratio <= 0.5) return 2;
  if (ratio <= 0.75) return 3;
  return 4;
}

/**
 * 0건 카테고리 제외 + 카운트 내림차순 정렬한 breakdown 반환.
 */
export function tooltipBreakdown(
  byCategory: HeatmapCategoryCount[]
): HeatmapCategoryCount[] {
  return byCategory
    .filter((c) => c.count > 0)
    .sort((a, b) => b.count - a.count);
}

/**
 * 주 컬럼별 월 라벨. 새로운 월이 시작되는 주(해당 주의 7일 중 1일이 포함된 주)에
 * 영어 약어로 라벨을 부여. 그 외 주는 빈 문자열.
 */
export function getMonthLabels(grid: (GridCell | null)[][]): string[] {
  const months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];
  const labels: string[] = [];
  let lastMonth = -1;
  for (const week of grid) {
    const firstReal = week.find((c) => c !== null) as GridCell | undefined;
    if (!firstReal) {
      labels.push("");
      continue;
    }
    const monthIdx = parseInt(firstReal.date.slice(5, 7), 10) - 1;
    if (monthIdx !== lastMonth && week.some((c) => c && c.date.slice(8, 10) <= "07")) {
      labels.push(months[monthIdx]);
      lastMonth = monthIdx;
    } else {
      labels.push("");
    }
  }
  return labels;
}
