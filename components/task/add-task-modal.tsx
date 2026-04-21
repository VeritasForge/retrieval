"use client";

import { useState, useMemo } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useUiStore } from "@/stores/ui-store";
import { today } from "@/lib/utils";

type Category = { id: string; name: string; iconName: string; colorHex: string };
type Strategy = { id: string; name: string; type: string; intervals: number[] | null };

type AddTaskModalProps = {
  categories: Category[];
  strategies: Strategy[];
  onAdd: (data: {
    categoryId: string;
    strategyId: string;
    studyDate: string;
    title: string;
  }) => void;
};

export function AddTaskModal({ categories, strategies, onAdd }: AddTaskModalProps) {
  const { addTaskModalOpen, closeAddTaskModal } = useUiStore();

  const defaultCategoryId = useMemo(
    () => categories.find((c) => c.name === "알고리즘")?.id ?? categories[0]?.id ?? "",
    [categories]
  );
  const defaultStrategyId = useMemo(
    () => strategies.find((s) => s.name === "에빙하우스 (표준)")?.id ?? strategies[0]?.id ?? "",
    [strategies]
  );

  const [categoryId, setCategoryId] = useState("");
  const [strategyId, setStrategyId] = useState("");
  const [studyDate, setStudyDate] = useState(today());
  const [title, setTitle] = useState("");

  const effectiveCategoryId = categoryId || defaultCategoryId;
  const effectiveStrategyId = strategyId || defaultStrategyId;

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!effectiveCategoryId || !effectiveStrategyId || !title.trim()) return;

    onAdd({ categoryId: effectiveCategoryId, strategyId: effectiveStrategyId, studyDate, title: title.trim() });
    closeAddTaskModal();
    setCategoryId("");
    setStrategyId("");
    setStudyDate(today());
    setTitle("");
  }

  return (
    <Dialog open={addTaskModalOpen} onOpenChange={(open) => !open && closeAddTaskModal()}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>새 학습 추가</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>제목</Label>
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="복습할 내용"
              autoFocus
            />
          </div>

          <div className="space-y-2">
            <Label>카테고리</Label>
            <Select value={effectiveCategoryId} onValueChange={(v) => setCategoryId(v ?? "")}>
              <SelectTrigger>
                <SelectValue placeholder="카테고리 선택">
                  {(value: string | null) => {
                    const cat = categories.find((c) => c.id === value);
                    return cat ? <span style={{ color: `#${cat.colorHex}` }}>{cat.name}</span> : "카테고리 선택";
                  }}
                </SelectValue>
              </SelectTrigger>
              <SelectContent>
                {categories.map((c) => (
                  <SelectItem key={c.id} value={c.id}>
                    <span style={{ color: `#${c.colorHex}` }}>{c.name}</span>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>전략</Label>
            <Select value={effectiveStrategyId} onValueChange={(v) => setStrategyId(v ?? "")}>
              <SelectTrigger>
                <SelectValue placeholder="전략 선택">
                  {(value: string | null) => {
                    const strat = strategies.find((s) => s.id === value);
                    return strat ? strat.name : "전략 선택";
                  }}
                </SelectValue>
              </SelectTrigger>
              <SelectContent>
                {strategies.map((s) => (
                  <SelectItem key={s.id} value={s.id}>
                    {s.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>공부한 날</Label>
            <Input
              type="date"
              value={studyDate}
              onChange={(e) => setStudyDate(e.target.value)}
            />
          </div>

          <div className="flex justify-end gap-2">
            <Button type="button" variant="outline" onClick={closeAddTaskModal}>
              취소
            </Button>
            <Button type="submit">추가하기</Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
