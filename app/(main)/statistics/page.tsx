"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { DailyReviewsChart } from "@/components/statistics/daily-reviews-chart";
import { CompletionRate } from "@/components/statistics/completion-rate";
import { StreakCard } from "@/components/statistics/streak-card";
import { ContributionGraph } from "@/components/statistics/contribution-graph";
import { CategoryPerformance } from "@/components/statistics/category-performance";
import { GraduationStatus } from "@/components/statistics/graduation-status";
import { today } from "@/lib/utils";
import type { HeatmapDay } from "@/lib/heatmap-grid";

type Stats = {
  dailyCounts: { date: string; count: number }[];
  completionRate: { total: number; completed: number };
  streak: { current: number };
  heatmap: HeatmapDay[];
  availableYears: number[];
  categoryPerformance: {
    categoryName: string;
    colorHex: string;
    total: number;
    completed: number;
  }[];
  graduation: { count: number };
};

export default function StatisticsPage() {
  const [stats, setStats] = useState<Stats | null>(null);

  useEffect(() => {
    fetch("/api/statistics")
      .then((res) => res.json())
      .then(setStats);
  }, []);

  if (!stats) {
    return <div className="animate-pulse">로딩 중...</div>;
  }

  const todayISO = today();

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">통계</h1>
        <Link href="/history" className="text-sm text-primary hover:underline">
          복습 기록 보기
        </Link>
      </div>

      {/* 그룹 1: 오늘/최근 */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <DailyReviewsChart data={stats.dailyCounts} />
        <CompletionRate
          total={stats.completionRate.total}
          completed={stats.completionRate.completed}
        />
        <StreakCard current={stats.streak.current} />
      </div>

      {/* 그룹 2: 장기 추세 */}
      <div className="space-y-4">
        <ContributionGraph
          data={stats.heatmap}
          availableYears={stats.availableYears}
          todayISO={todayISO}
        />
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <CategoryPerformance data={stats.categoryPerformance} />
          <GraduationStatus count={stats.graduation.count} />
        </div>
      </div>
    </div>
  );
}
