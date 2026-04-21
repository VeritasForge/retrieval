"use client";

import { TaskCard } from "./task-card";
import { CollapsibleSection } from "./collapsible-section";

type ReviewItem = {
  review: { id: string; reviewOrder: number; status: string };
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

type TodayReviewsProps = {
  reviews: ReviewItem[];
  onComplete: (reviewId: string, rating?: number) => void;
  onDelete: (taskId: string) => void;
};

export function TodayReviews({ reviews, onComplete, onDelete }: TodayReviewsProps) {
  return (
    <CollapsibleSection title="오늘 복습할 것" count={reviews.length} sectionKey="today">
      <div className="space-y-3">
        {reviews.map((item) => (
          <TaskCard
            key={item.review.id}
            mode="today"
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
            easinessFactor={item.task.easinessFactor}
            interval={item.task.interval}
            repetitions={item.task.repetitions}
            onComplete={onComplete}
            onDelete={onDelete}
          />
        ))}
        {reviews.length === 0 && (
          <p className="text-sm text-muted-foreground text-center py-8">
            오늘 복습할 항목이 없습니다
          </p>
        )}
      </div>
    </CollapsibleSection>
  );
}
