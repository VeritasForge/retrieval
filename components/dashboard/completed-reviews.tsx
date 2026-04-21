"use client";

import { TaskCard } from "./task-card";
import { CollapsibleSection } from "./collapsible-section";

type CompletedItem = {
  review: { id: string };
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

type CompletedReviewsProps = {
  reviews: CompletedItem[];
  onDelete: (taskId: string) => void;
};

export function CompletedReviews({ reviews, onDelete }: CompletedReviewsProps) {
  if (reviews.length === 0) return null;

  return (
    <CollapsibleSection title="완료" count={reviews.length} sectionKey="completed">
      <div className="space-y-3">
        {reviews.map((item) => (
          <TaskCard
            key={item.review.id}
            mode="completed"
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
            onDelete={onDelete}
          />
        ))}
      </div>
    </CollapsibleSection>
  );
}
