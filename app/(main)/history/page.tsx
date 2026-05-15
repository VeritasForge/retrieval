"use client";

import { useEffect, useState, useCallback } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate } from "@/lib/utils";

const RATING_LABELS: Record<number, string> = {
  0: "😵 까먹음",
  1: "😓 어려움",
  2: "😊 괜찮음",
  3: "😎 쉬움",
};

type HistoryItem = {
  review: {
    id: string;
    scheduledDate: string;
    status: string;
    rating: number | null;
    completedAt: string;
  };
  task: { id: string };
  category: { name: string; colorHex: string };
  strategy: { name: string; type: string };
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
              <Card key={item.review.id}>
                <CardContent className="flex items-center gap-3 p-3">
                  <div
                    className="h-3 w-3 rounded-full"
                    style={{ backgroundColor: `#${item.category.colorHex}` }}
                  />
                  <span className="flex-1 text-sm">{item.category.name}</span>
                  <Badge variant="outline" className="text-xs">
                    {item.strategy.name}
                  </Badge>
                  {item.review.rating !== null && (
                    <span className="text-xs">
                      {RATING_LABELS[item.review.rating]}
                    </span>
                  )}
                </CardContent>
              </Card>
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
