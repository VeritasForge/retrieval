"use client";

import { useEffect, useState, useCallback } from "react";
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

export default function HistoryPage() {
  const [items, setItems] = useState<HistoryItem[]>([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  const fetchHistory = useCallback(async (p: number) => {
    const res = await fetch(`/api/history?page=${p}`);
    const data = await res.json();
    if (data.length < 20) setHasMore(false);
    setItems((prev) => (p === 1 ? data : [...prev, ...data]));
  }, []);

  useEffect(() => {
    fetchHistory(1);
  }, [fetchHistory]);

  function loadMore() {
    const nextPage = page + 1;
    setPage(nextPage);
    fetchHistory(nextPage);
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
      <h1 className="text-2xl font-bold mb-6">복습 기록</h1>

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

      {hasMore && (
        <Button variant="outline" className="w-full" onClick={loadMore}>
          더 보기
        </Button>
      )}

      {items.length === 0 && (
        <p className="text-center text-muted-foreground py-8">
          아직 복습 기록이 없습니다
        </p>
      )}
    </div>
  );
}
