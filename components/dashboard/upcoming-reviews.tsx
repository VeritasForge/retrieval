"use client";

import { TaskCard } from "./task-card";
import { CollapsibleSection } from "./collapsible-section";
import { daysBetween, today } from "@/lib/utils";

type UpcomingItem = {
  review: { id: string; scheduledDate: string };
  task: {
    id: string;
    categoryId: string;
    strategyId: string;
    studyDate: string;
    title: string;
    easinessFactor: number;
    interval: number;
    repetitions: number;
  };
  category: { id: string; name: string; iconName: string; colorHex: string };
  strategy: { id: string; name: string; type: "fixed" | "sm2" };
};

type UpcomingReviewsProps = {
  reviews: UpcomingItem[];
  onDelete: (taskId: string) => void;
};

export function UpcomingReviews({ reviews, onDelete }: UpcomingReviewsProps) {
  if (reviews.length === 0) return null;

  const grouped = new Map<number, UpcomingItem[]>();
  for (const item of reviews) {
    const days = daysBetween(today(), item.review.scheduledDate);
    const existing = grouped.get(days) || [];
    existing.push(item);
    grouped.set(days, existing);
  }

  return (
    <CollapsibleSection title="예정" count={reviews.length} sectionKey="upcoming">
      <div className="space-y-4">
        {Array.from(grouped.entries())
          .sort(([a], [b]) => a - b)
          .map(([days, items]) => (
            <div key={days}>
              <p className="text-sm font-medium text-muted-foreground mb-2">
                {days === 1 ? "내일" : `${days}일 후`}
              </p>
              <div className="space-y-3">
                {items.map((item) => (
                  <TaskCard
                    key={item.review.id}
                    mode="upcoming"
                    reviewId={item.review.id}
                    taskId={item.task.id}
                    categoryId={item.task.categoryId}
                    categoryName={item.category.name}
                    categoryIcon={item.category.iconName}
                    categoryColor={item.category.colorHex}
                    strategyId={item.task.strategyId}
                    strategyName={item.strategy.name}
                    strategyType={item.strategy.type}
                    studyDate={item.task.studyDate}
                    title={item.task.title}
                    onDelete={onDelete}
                  />
                ))}
              </div>
            </div>
          ))}
      </div>
    </CollapsibleSection>
  );
}
