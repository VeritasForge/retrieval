"use client";

import { BaseBarChart } from "./base-bar-chart";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type CatPerf = {
  categoryName: string;
  colorHex: string;
  total: number;
  completed: number;
};

export function CategoryPerformance({ data }: { data: CatPerf[] }) {
  const formatted = data.map((d) => ({
    label: d.categoryName,
    value: d.total > 0 ? Math.round((d.completed / d.total) * 100) : 0,
    colorHex: d.colorHex,
  }));

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">카테고리별 성과</CardTitle>
      </CardHeader>
      <CardContent>
        <BaseBarChart
          data={formatted}
          orientation="vertical"
          domain={[0, 100]}
          colorAccessor={(item) => `#${item.colorHex}`}
          tooltipFormatter={(v) => `${v}%`}
        />
      </CardContent>
    </Card>
  );
}
