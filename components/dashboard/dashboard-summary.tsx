"use client";

import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Flame } from "lucide-react";

type DashboardSummaryProps = {
  totalToday: number;
  completedToday: number;
  streak: number;
};

export function DashboardSummary({
  totalToday,
  completedToday,
  streak,
}: DashboardSummaryProps) {
  const rate = totalToday > 0 ? Math.round((completedToday / totalToday) * 100) : 0;

  return (
    <Card className="mb-6">
      <CardContent className="p-4 flex items-center gap-6">
        <div className="flex-1">
          <p className="text-sm text-muted-foreground">오늘 복습</p>
          <p className="text-2xl font-bold">
            {completedToday} / {totalToday}
          </p>
          <Progress value={rate} className="mt-2 h-2" />
        </div>
        <div className="flex items-center gap-2 text-orange-500">
          <Flame className="h-6 w-6" />
          <div>
            <p className="text-2xl font-bold">{streak}</p>
            <p className="text-xs text-muted-foreground">일 연속</p>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
