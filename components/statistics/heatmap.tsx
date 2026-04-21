"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";

type HeatmapItem = { date: string; count: number };

export function Heatmap({ data }: { data: HeatmapItem[] }) {
  const map = new Map(data.map((d) => [d.date, d.count]));
  const maxCount = Math.max(...data.map((d) => d.count), 1);

  // 최근 52주 (364일)
  const days: { date: string; count: number }[] = [];
  const today = new Date();
  for (let i = 363; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    const dateStr = d.toISOString().split("T")[0];
    days.push({ date: dateStr, count: map.get(dateStr) ?? 0 });
  }

  function getIntensity(count: number): string {
    if (count === 0) return "bg-muted";
    const ratio = count / maxCount;
    if (ratio < 0.25) return "bg-emerald-200 dark:bg-emerald-900";
    if (ratio < 0.5) return "bg-emerald-400 dark:bg-emerald-700";
    if (ratio < 0.75) return "bg-emerald-500 dark:bg-emerald-500";
    return "bg-emerald-700 dark:bg-emerald-300";
  }

  // 7 rows (days of week) x 52 columns (weeks)
  const weeks: { date: string; count: number }[][] = [];
  let currentWeek: { date: string; count: number }[] = [];
  for (const day of days) {
    currentWeek.push(day);
    if (currentWeek.length === 7) {
      weeks.push(currentWeek);
      currentWeek = [];
    }
  }
  if (currentWeek.length > 0) weeks.push(currentWeek);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">복습 활동</CardTitle>
      </CardHeader>
      <CardContent className="overflow-x-auto">
        <div className="flex gap-0.5">
          {weeks.map((week, wi) => (
            <div key={wi} className="flex flex-col gap-0.5">
              {week.map((day) => (
                <div
                  key={day.date}
                  className={cn("h-3 w-3 rounded-sm", getIntensity(day.count))}
                  title={`${day.date}: ${day.count}건`}
                />
              ))}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
