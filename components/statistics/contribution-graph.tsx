"use client";

import { useMemo, useState, useRef } from "react";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import {
  buildGrid,
  getDateRangeForYear,
  getIntensityLevel,
  getMonthLabels,
  tooltipBreakdown,
  type HeatmapDay,
} from "@/lib/heatmap-grid";

type Props = {
  data: HeatmapDay[];
  availableYears: number[];
  initialYear?: number;
  todayISO: string;
};

const WEEKDAY_LABELS = ["", "Mon", "", "Wed", "", "Fri", ""];

const INTENSITY_CLASSES: Record<0 | 1 | 2 | 3 | 4, string> = {
  0: "bg-muted",
  1: "bg-emerald-200 dark:bg-emerald-900",
  2: "bg-emerald-400 dark:bg-emerald-700",
  3: "bg-emerald-500 dark:bg-emerald-500",
  4: "bg-emerald-700 dark:bg-emerald-300",
};

function formatDateForDisplay(iso: string): string {
  const [y, m, d] = iso.split("-");
  return `${y}년 ${parseInt(m, 10)}월 ${parseInt(d, 10)}일`;
}

export function ContributionGraph({
  data,
  availableYears,
  initialYear,
  todayISO,
}: Props) {
  const router = useRouter();
  const currentYear = parseInt(todayISO.slice(0, 4), 10);
  const [year, setYear] = useState(initialYear ?? currentYear);
  const [hover, setHover] = useState<{
    day: HeatmapDay;
    x: number;
    y: number;
  } | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const { grid, monthLabels, maxCount, totalCount } = useMemo(() => {
    const { start, end } = getDateRangeForYear(year, todayISO);
    const dataMap = new Map<string, HeatmapDay>(
      data.map((d) => [d.date, d])
    );
    const grid = buildGrid(start, end, dataMap);
    const monthLabels = getMonthLabels(grid);
    let max = 0;
    let total = 0;
    for (const week of grid) {
      for (const cell of week) {
        if (cell && cell.count > max) max = cell.count;
        if (cell) total += cell.count;
      }
    }
    return { grid, monthLabels, maxCount: max, totalCount: total };
  }, [year, todayISO, data]);

  function handleYearChange(e: React.ChangeEvent<HTMLSelectElement>) {
    setYear(parseInt(e.target.value, 10));
  }

  function handleTileClick(day: HeatmapDay) {
    if (day.count === 0) return;
    router.push(`/history?date=${day.date}`);
  }

  function handleTileEnter(
    e: React.MouseEvent<HTMLButtonElement>,
    day: HeatmapDay
  ) {
    const containerRect = containerRef.current?.getBoundingClientRect();
    const tileRect = e.currentTarget.getBoundingClientRect();
    if (!containerRect) return;
    setHover({
      day,
      x: tileRect.left - containerRect.left + tileRect.width / 2,
      y: tileRect.top - containerRect.top,
    });
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0">
        <CardTitle className="text-base">
          복습 활동{" "}
          <span className="text-sm font-normal text-muted-foreground ml-2">
            {totalCount}건
          </span>
        </CardTitle>
        {availableYears.length > 1 && (
          <select
            value={year}
            onChange={handleYearChange}
            className="text-sm border rounded-md px-2 py-1 bg-background"
            aria-label="연도 선택"
          >
            {availableYears.map((y) => (
              <option key={y} value={y}>
                {y}
              </option>
            ))}
          </select>
        )}
      </CardHeader>
      <CardContent className="overflow-x-auto">
        <div ref={containerRef} className="relative">
          {/* 월 라벨 행 */}
          <div className="flex gap-0.5 ml-7 mb-1 text-[10px] text-muted-foreground">
            {monthLabels.map((label, i) => (
              <div key={i} className="w-3">
                {label}
              </div>
            ))}
          </div>
          <div className="flex gap-0.5">
            {/* 요일 라벨 컬럼 */}
            <div className="flex flex-col gap-0.5 mr-1 text-[10px] text-muted-foreground">
              {WEEKDAY_LABELS.map((label, i) => (
                <div key={i} className="h-3 leading-3 w-6">
                  {label}
                </div>
              ))}
            </div>
            {/* 그리드 */}
            {grid.map((week, wi) => (
              <div key={wi} className="flex flex-col gap-0.5">
                {week.map((cell, di) => {
                  if (!cell) {
                    return <div key={di} className="h-3 w-3" />;
                  }
                  const level = getIntensityLevel(cell.count, maxCount);
                  return (
                    <button
                      key={di}
                      type="button"
                      className={cn(
                        "h-3 w-3 rounded-sm transition-opacity",
                        INTENSITY_CLASSES[level],
                        cell.count > 0 && "cursor-pointer hover:opacity-70"
                      )}
                      onMouseEnter={(e) => handleTileEnter(e, cell)}
                      onMouseLeave={() => setHover(null)}
                      onClick={() => handleTileClick(cell)}
                      aria-label={`${cell.date}: ${cell.count}건`}
                    />
                  );
                })}
              </div>
            ))}
          </div>
          {/* Legend */}
          <div className="flex items-center justify-end gap-1 mt-2 text-[10px] text-muted-foreground">
            <span>Less</span>
            <div className={cn("h-3 w-3 rounded-sm", INTENSITY_CLASSES[0])} />
            <div className={cn("h-3 w-3 rounded-sm", INTENSITY_CLASSES[1])} />
            <div className={cn("h-3 w-3 rounded-sm", INTENSITY_CLASSES[2])} />
            <div className={cn("h-3 w-3 rounded-sm", INTENSITY_CLASSES[3])} />
            <div className={cn("h-3 w-3 rounded-sm", INTENSITY_CLASSES[4])} />
            <span>More</span>
          </div>
          {/* Tooltip */}
          {hover && (
            <div
              className="absolute z-10 pointer-events-none rounded-md border bg-popover text-popover-foreground px-2 py-1.5 text-xs shadow-md"
              style={{
                left: hover.x,
                top: hover.y - 4,
                transform: "translate(-50%, -100%)",
                minWidth: "140px",
              }}
              role="tooltip"
            >
              <div className="font-medium">
                {formatDateForDisplay(hover.day.date)}
              </div>
              <div className="text-muted-foreground">
                총 {hover.day.count}건
              </div>
              {tooltipBreakdown(hover.day.byCategory).map((c) => (
                <div key={c.name} className="flex items-center gap-1.5 mt-0.5">
                  <span
                    className="inline-block h-2 w-2 rounded-sm"
                    style={{ backgroundColor: c.color }}
                  />
                  <span>
                    {c.name} {c.count}건
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
