"use client";

import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { DifficultyRating } from "@/components/review/difficulty-rating";
import { TitleWithMentions } from "@/components/review/title-with-mentions";
import { Check, Pencil, Trash2, RotateCcw } from "lucide-react";
import { useUiStore } from "@/stores/ui-store";

type CardMode = "today" | "completed" | "upcoming" | "overdue" | "readonly";

const RATING_LABELS: Record<number, string> = {
  0: "😵 까먹음",
  1: "😓 어려움",
  2: "😊 괜찮음",
  3: "😎 쉬움",
};

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
  rating?: number | null;
  onComplete?: (reviewId: string, rating?: number) => void;
  onDelete: (taskId: string) => void;
  onContinue?: (reviewId: string) => void;
  onReset?: (reviewId: string) => void;
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
  rating,
  onComplete,
  onDelete,
  onContinue,
  onReset,
}: TaskCardProps) {
  const openEditTaskModal = useUiStore((s) => s.openEditTaskModal);
  const [showRating, setShowRating] = useState(false);
  const [continueDisabled, setContinueDisabled] = useState(false);

  const isReadonly = mode === "readonly";

  function handleEdit() {
    openEditTaskModal({ taskId, categoryId, strategyId, studyDate, title });
  }

  function handleComplete() {
    if (!onComplete) return;
    if (strategyType === "sm2") {
      setShowRating(true);
    } else {
      onComplete(reviewId);
    }
  }

  function handleRatingSelect(r: number) {
    onComplete?.(reviewId, r);
    setShowRating(false);
  }

  function handleContinueClick() {
    if (continueDisabled || !onContinue) return;
    setContinueDisabled(true);
    setTimeout(() => setContinueDisabled(false), 1000);
    onContinue(reviewId);
  }

  function handleResetClick() {
    if (!onReset) return;
    if (confirm("학습 진도를 처음부터 다시 시작하시겠습니까? 이전 복습 기록은 보존됩니다.")) {
      onReset(reviewId);
    }
  }

  return (
    <Card
      className={`border-l-4 ${mode === "completed" ? "opacity-60" : ""}`}
      style={{ borderLeftColor: `#${categoryColor}` }}
    >
      <CardContent className="p-3">
        {/* 1줄: 메타 + 액션 */}
        <div className="flex items-center justify-between mb-1">
          <div className="flex items-center gap-2 min-w-0">
            <span className="font-medium truncate">{categoryName}</span>
            <Badge variant="outline" className="text-xs shrink-0">
              {strategyName}
            </Badge>
            {mode === "overdue" && daysLate != null && (
              <span className="text-xs text-amber-600 dark:text-amber-400 shrink-0">
                {daysLate}일 지남
              </span>
            )}
            {isReadonly && strategyType === "sm2" && typeof rating === "number" && (
              <span className="text-xs shrink-0">{RATING_LABELS[rating]}</span>
            )}
          </div>
          <div className="flex gap-1 shrink-0">
            {!isReadonly && (
              <>
                <Button size="sm" variant="ghost" onClick={handleEdit} aria-label="편집">
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button
                  size="sm"
                  variant="ghost"
                  className="text-destructive hover:text-destructive"
                  onClick={() => onDelete(taskId)}
                  aria-label="삭제"
                >
                  <Trash2 className="h-4 w-4" />
                </Button>
              </>
            )}
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
            {mode === "overdue" && onContinue && (
              <Button size="sm" onClick={handleContinueClick} disabled={continueDisabled}>
                <Check className="h-3 w-3 mr-1" />
                계속
              </Button>
            )}
            {mode === "overdue" && onReset && strategyType === "fixed" && (
              <Button size="sm" variant="outline" onClick={handleResetClick}>
                <RotateCcw className="h-3 w-3 mr-1" />
                다시 시작
              </Button>
            )}
          </div>
        </div>

        {/* 2줄: title (URL mention 포함) */}
        <TitleWithMentions title={title} />

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
