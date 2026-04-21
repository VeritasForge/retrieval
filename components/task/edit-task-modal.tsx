"use client";

import { useState, useEffect } from "react";
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
import { Trash2 } from "lucide-react";

type Category = { id: string; name: string; iconName: string; colorHex: string };
type Strategy = { id: string; name: string; type: string; intervals: number[] | null };

type EditTaskModalProps = {
  categories: Category[];
  strategies: Strategy[];
  onEdit: (taskId: string, data: {
    categoryId: string;
    strategyId: string;
    studyDate: string;
    title: string;
  }) => void;
  onDelete: (taskId: string) => void;
};

export function EditTaskModal({ categories, strategies, onEdit, onDelete }: EditTaskModalProps) {
  const { editTaskTarget, closeEditTaskModal } = useUiStore();
  const [categoryId, setCategoryId] = useState("");
  const [strategyId, setStrategyId] = useState("");
  const [studyDate, setStudyDate] = useState("");
  const [title, setTitle] = useState("");

  useEffect(() => {
    if (editTaskTarget) {
      setCategoryId(editTaskTarget.categoryId);
      setStrategyId(editTaskTarget.strategyId);
      setStudyDate(editTaskTarget.studyDate);
      setTitle(editTaskTarget.title);
    }
  }, [editTaskTarget]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!editTaskTarget) return;
    if (!categoryId || !strategyId || !title.trim()) return;

    onEdit(editTaskTarget.taskId, {
      categoryId,
      strategyId,
      studyDate,
      title: title.trim(),
    });
    closeEditTaskModal();
  }

  function handleDelete() {
    if (!editTaskTarget) return;
    onDelete(editTaskTarget.taskId);
    closeEditTaskModal();
  }

  return (
    <Dialog open={!!editTaskTarget} onOpenChange={(open) => !open && closeEditTaskModal()}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>학습 수정</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label>제목</Label>
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="복습할 내용"
            />
          </div>

          <div className="space-y-2">
            <Label>카테고리</Label>
            <Select value={categoryId} onValueChange={(v) => setCategoryId(v ?? "")}>
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
            <Select value={strategyId} onValueChange={(v) => setStrategyId(v ?? "")}>
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

          <div className="flex justify-between">
            <Button type="button" variant="destructive" size="sm" onClick={handleDelete}>
              <Trash2 className="h-4 w-4 mr-1" />
              삭제
            </Button>
            <div className="flex gap-2">
              <Button type="button" variant="outline" onClick={closeEditTaskModal}>
                취소
              </Button>
              <Button type="submit">저장</Button>
            </div>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
