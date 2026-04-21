"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { previewSm2 } from "@/lib/sm2";

type DifficultyRatingProps = {
  easinessFactor: number;
  interval: number;
  repetitions: number;
  onSelect: (rating: number) => void;
  onCancel: () => void;
};

const RATINGS = [
  { value: 0, label: "까먹음", emoji: "\u{1F635}" },
  { value: 1, label: "어려움", emoji: "\u{1F613}" },
  { value: 2, label: "괜찮음", emoji: "\u{1F60A}" },
  { value: 3, label: "쉬움", emoji: "\u{1F60E}" },
];

export function DifficultyRating({
  easinessFactor,
  interval,
  repetitions,
  onSelect,
  onCancel,
}: DifficultyRatingProps) {
  const [hovered, setHovered] = useState<number | null>(null);
  const preview = previewSm2({ easinessFactor, interval, repetitions });

  return (
    <div className="mt-3 rounded-md border p-3 bg-muted/50">
      <p className="text-sm font-medium mb-2">이 복습은 어땠나요?</p>
      <div className="flex gap-2">
        {RATINGS.map((r) => (
          <Button
            key={r.value}
            variant="outline"
            size="sm"
            className="flex-1 flex-col h-auto py-2"
            onMouseEnter={() => setHovered(r.value)}
            onMouseLeave={() => setHovered(null)}
            onClick={() => onSelect(r.value)}
          >
            <span className="text-lg">{r.emoji}</span>
            <span className="text-xs">{r.label}</span>
          </Button>
        ))}
      </div>
      {hovered !== null && (
        <p className="text-xs text-muted-foreground mt-2 text-center">
          다음 복습: {preview[hovered]}일 후
        </p>
      )}
      <Button
        variant="ghost"
        size="sm"
        className="w-full mt-2"
        onClick={onCancel}
      >
        취소
      </Button>
    </div>
  );
}
