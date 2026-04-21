"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  Cell,
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type CatPerf = {
  categoryName: string;
  colorHex: string;
  total: number;
  completed: number;
};

export function CategoryPerformance({ data }: { data: CatPerf[] }) {
  const formatted = data.map((d) => ({
    ...d,
    rate: d.total > 0 ? Math.round((d.completed / d.total) * 100) : 0,
  }));

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">카테고리별 성과</CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={200}>
          <BarChart data={formatted} layout="vertical">
            <XAxis type="number" domain={[0, 100]} tick={{ fontSize: 12 }} />
            <YAxis dataKey="categoryName" type="category" width={80} tick={{ fontSize: 12 }} />
            <Tooltip formatter={(value) => `${value}%`} />
            <Bar dataKey="rate" radius={[0, 4, 4, 0]}>
              {formatted.map((entry, index) => (
                <Cell key={index} fill={`#${entry.colorHex}`} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
