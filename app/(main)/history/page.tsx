"use client";

import { useEffect, useState, useCallback, Suspense } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { TaskCard } from "@/components/dashboard/task-card";
import { formatDate } from "@/lib/utils";

type HistoryItem = {
  review: {
    id: string;
    scheduledDate: string;
    status: string;
    rating: number | null;
    completedAt: string;
  };
  task: {
    id: string;
    categoryId: string;
    strategyId: string;
    studyDate: string;
    title: string;
  };
  category: { id: string; name: string; iconName: string | null; colorHex: string };
  strategy: { id: string; name: string; type: "fixed" | "sm2" };
};

function HistoryContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const dateFilter = searchParams.get("date");
  const [items, setItems] = useState<HistoryItem[]>([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  const fetchHistory = useCallback(
    async (p: number) => {
      const params = new URLSearchParams({ page: String(p) });
      if (dateFilter) params.set("date", dateFilter);
      const res = await fetch(`/api/history?${params.toString()}`);
      const data = await res.json();
      if (data.length < 20) setHasMore(false);
      setItems((prev) => (p === 1 ? data : [...prev, ...data]));
    },
    [dateFilter]
  );

  useEffect(() => {
    setItems([]);
    setPage(1);
    setHasMore(true);
    fetchHistory(1);
  }, [fetchHistory]);

  function loadMore() {
    const nextPage = page + 1;
    setPage(nextPage);
    fetchHistory(nextPage);
  }

  function clearFilter() {
    router.push("/history");
  }

  // 날짜별 그룹
  const grouped = new Map<string, HistoryItem[]>();
  for (const item of items) {
    const dateKey = item.review.completedAt?.split("T")[0] ?? item.review.scheduledDate;
    const existing = grouped.get(dateKey) || [];
    existing.push(item);
    grouped.set(dateKey, existing);
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">복습 기록</h1>
        {dateFilter && (
          <div className="flex items-center gap-2 text-sm">
            <span className="text-muted-foreground">
              {formatDate(dateFilter)} 필터링 중
            </span>
            <Button variant="ghost" size="sm" onClick={clearFilter}>
              전체 보기
            </Button>
          </div>
        )}
      </div>

      {Array.from(grouped.entries()).map(([date, dateItems]) => (
        <div key={date} className="mb-6">
          <h2 className="text-sm font-medium text-muted-foreground mb-2">
            {formatDate(date)}
          </h2>
          <div className="space-y-2">
            {dateItems.map((item) => (
              <TaskCard
                key={item.review.id}
                mode="readonly"
                reviewId={item.review.id}
                taskId={item.task.id}
                categoryId={item.task.categoryId}
                categoryName={item.category.name}
                categoryIcon={item.category.iconName ?? "book"}
                categoryColor={item.category.colorHex}
                strategyId={item.task.strategyId}
                strategyName={item.strategy.name}
                strategyType={item.strategy.type}
                studyDate={item.task.studyDate}
                title={item.task.title}
                rating={item.review.rating}
                onDelete={() => {}}
              />
            ))}
          </div>
        </div>
      ))}

      {hasMore && items.length > 0 && (
        <Button variant="outline" className="w-full" onClick={loadMore}>
          더 보기
        </Button>
      )}

      {items.length === 0 && (
        <p className="text-center text-muted-foreground py-8">
          {dateFilter
            ? "해당 날짜에 복습 기록이 없습니다"
            : "아직 복습 기록이 없습니다"}
        </p>
      )}
    </div>
  );
}

export default function HistoryPage() {
  return (
    <Suspense fallback={<div className="animate-pulse">로딩 중...</div>}>
      <HistoryContent />
    </Suspense>
  );
}
