"use client";

import { TaskCard } from "./task-card";
import { CollapsibleSection } from "./collapsible-section";
import { daysBetween, today } from "@/lib/utils";

type OverdueItem = {
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

type OverduePanelProps = {
  reviews: OverdueItem[];
  onReschedule: (reviewId: string) => void;
  onSkip: (reviewId: string) => void;
  onDelete: (taskId: string) => void;
};

export function OverduePanel({ reviews, onReschedule, onSkip, onDelete }: OverduePanelProps) {
  if (reviews.length === 0) return null;

  return (
    <CollapsibleSection title="밀린 복습" count={reviews.length} sectionKey="overdue">
      <div className="space-y-3">
        {reviews.map((item) => (
          <TaskCard
            key={item.review.id}
            mode="overdue"
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
            daysLate={daysBetween(item.review.scheduledDate, today())}
            onDelete={onDelete}
            onReschedule={onReschedule}
            onSkip={onSkip}
          />
        ))}
      </div>
    </CollapsibleSection>
  );
}
