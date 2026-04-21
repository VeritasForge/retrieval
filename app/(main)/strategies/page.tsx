"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Plus, Pencil, Trash2 } from "lucide-react";

type Strategy = {
  id: string;
  name: string;
  type: "fixed" | "sm2";
  intervals: number[] | null;
  isDefault: boolean;
};

export default function StrategiesPage() {
  const [strategies, setStrategies] = useState<Strategy[]>([]);
  const [editModal, setEditModal] = useState<{
    open: boolean;
    strategy?: Strategy;
  }>({ open: false });
  const [form, setForm] = useState({ name: "", intervals: "" });

  async function fetchStrategies() {
    const res = await fetch("/api/strategies");
    setStrategies(await res.json());
  }

  useEffect(() => {
    fetchStrategies();
  }, []);

  function openCreate() {
    setForm({ name: "", intervals: "" });
    setEditModal({ open: true });
  }

  function openEdit(strat: Strategy) {
    setForm({
      name: strat.name,
      intervals: strat.intervals?.join(", ") ?? "",
    });
    setEditModal({ open: true, strategy: strat });
  }

  async function handleSave() {
    const intervals = form.intervals
      .split(",")
      .map((s) => parseInt(s.trim(), 10))
      .filter((n) => !isNaN(n) && n > 0);

    const body = { name: form.name, intervals };

    if (editModal.strategy) {
      await fetch(`/api/strategies/${editModal.strategy.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
    } else {
      await fetch("/api/strategies", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
    }
    setEditModal({ open: false });
    fetchStrategies();
  }

  async function handleDelete(id: string) {
    await fetch(`/api/strategies/${id}`, { method: "DELETE" });
    fetchStrategies();
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">전략</h1>
        <Button size="sm" onClick={openCreate}>
          <Plus className="h-4 w-4 mr-1" />
          추가
        </Button>
      </div>

      <div className="space-y-2">
        {strategies.map((strat) => (
          <Card key={strat.id}>
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-medium">{strat.name}</span>
                    {strat.isDefault && (
                      <Badge variant="secondary" className="text-xs">기본</Badge>
                    )}
                  </div>
                  <p className="text-sm text-muted-foreground mt-1">
                    {strat.type === "sm2"
                      ? "난이도 기반 자동 간격 조절"
                      : strat.intervals?.join(" → ") + "일"}
                  </p>
                </div>
                <div className="flex gap-1">
                  {strat.type !== "sm2" && (
                    <Button variant="ghost" size="icon" onClick={() => openEdit(strat)}>
                      <Pencil className="h-4 w-4" />
                    </Button>
                  )}
                  {!strat.isDefault && (
                    <Button variant="ghost" size="icon" onClick={() => handleDelete(strat.id)}>
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Dialog open={editModal.open} onOpenChange={(open) => setEditModal({ open })}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>
              {editModal.strategy ? "전략 수정" : "새 전략"}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>이름</Label>
              <Input
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label>간격 (일, 쉼표로 구분)</Label>
              <Input
                value={form.intervals}
                onChange={(e) => setForm({ ...form, intervals: e.target.value })}
                placeholder="1, 3, 7, 14, 30"
              />
            </div>
            <Button className="w-full" onClick={handleSave}>
              저장
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
