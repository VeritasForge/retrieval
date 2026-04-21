"use client";

import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { DifficultyRating } from "@/components/review/difficulty-rating";
import { Check, Pencil, Trash2, RotateCcw, SkipForward } from "lucide-react";
import { useUiStore } from "@/stores/ui-store";

type CardMode = "today" | "completed" | "upcoming" | "overdue";

type TaskCardProps = {
  mode: CardMode;
  reviewId: string;
  taskId: string;
  categoryId: string;
  categoryName: string;
  categoryIcon: string;
  categoryColor: string;
  strategyId: string;
  strategyName: string;
  strategyType: "fixed" | "sm2";
  studyDate: string;
  title: string;
  easinessFactor?: number;
  interval?: number;
  repetitions?: number;
  daysLate?: number;
  onComplete?: (reviewId: string, rating?: number) => void;
  onDelete: (taskId: string) => void;
  onReschedule?: (reviewId: string) => void;
  onSkip?: (reviewId: string) => void;
};

export function TaskCard({
  mode,
  reviewId,
  taskId,
  categoryId,
  categoryName,
  categoryColor,
  strategyId,
  strategyName,
  strategyType,
  studyDate,
  title,
  easinessFactor = 2.5,
  interval = 0,
  repetitions = 0,
  daysLate,
  onComplete,
  onDelete,
  onReschedule,
  onSkip,
}: TaskCardProps) {
  const openEditTaskModal = useUiStore((s) => s.openEditTaskModal);
  const [showRating, setShowRating] = useState(false);

  function handleEdit() {
    openEditTaskModal({
      taskId,
      categoryId,
      strategyId,
      studyDate,
      title,
    });
  }

  function handleComplete() {
    if (!onComplete) return;
    if (strategyType === "sm2") {
      setShowRating(true);
    } else {
      onComplete(reviewId);
    }
  }

  function handleRatingSelect(rating: number) {
    onComplete?.(reviewId, rating);
    setShowRating(false);
  }

  return (
    <Card
      className={`border-l-4 ${mode === "completed" ? "opacity-60" : ""}`}
      style={{ borderLeftColor: `#${categoryColor}` }}
    >
      <CardContent className="p-4">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <span className="font-medium">{categoryName}</span>
            <Badge variant="outline" className="text-xs">
              {strategyName}
            </Badge>
            {mode === "overdue" && daysLate != null && (
              <span className="text-xs text-amber-600 dark:text-amber-400">
                {daysLate}일 지남
              </span>
            )}
          </div>
          <div className="flex gap-1">
            <Button size="sm" variant="ghost" onClick={handleEdit}>
              <Pencil className="h-4 w-4" />
            </Button>
            <Button size="sm" variant="ghost" className="text-destructive hover:text-destructive" onClick={() => onDelete(taskId)}>
              <Trash2 className="h-4 w-4" />
            </Button>
            {mode === "today" && (
              <Button size="sm" onClick={handleComplete} disabled={showRating}>
                <Check className="h-4 w-4 mr-1" />
                복습 완료
              </Button>
            )}
            {mode === "completed" && (
              <Badge className="bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300">
                완료
              </Badge>
            )}
          </div>
        </div>

        <p className="text-sm text-muted-foreground">{title}</p>

        {mode === "overdue" && (
          <div className="flex gap-2 mt-2">
            {onReschedule && (
              <Button size="sm" variant="outline" onClick={() => onReschedule(reviewId)}>
                <RotateCcw className="h-3 w-3 mr-1" />
                오늘로 이동
              </Button>
            )}
            {onSkip && (
              <Button size="sm" variant="ghost" onClick={() => onSkip(reviewId)}>
                <SkipForward className="h-3 w-3 mr-1" />
                건너뛰기
              </Button>
            )}
          </div>
        )}

        {showRating && (
          <DifficultyRating
            easinessFactor={easinessFactor}
            interval={interval}
            repetitions={repetitions}
            onSelect={handleRatingSelect}
            onCancel={() => setShowRating(false)}
          />
        )}
      </CardContent>
    </Card>
  );
}
