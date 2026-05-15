"use client";

import { BaseBarChart } from "./base-bar-chart";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type DailyCountItem = { date: string; count: number };

export function DailyReviewsChart({ data }: { data: DailyCountItem[] }) {
  const formatted = data.map((d) => ({
    label: new Date(d.date + "T00:00:00").toLocaleDateString("ko-KR", {
      month: "short",
      day: "numeric",
    }),
    value: d.count,
    date: d.date,
  }));

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">일별 복습수</CardTitle>
      </CardHeader>
      <CardContent>
        <BaseBarChart
          data={formatted}
          orientation="horizontal"
          tooltipFormatter={(v) => `${v}건`}
        />
      </CardContent>
    </Card>
  );
}
