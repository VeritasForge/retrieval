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
import { Plus, GripVertical, Pencil, Trash2 } from "lucide-react";

type Category = {
  id: string;
  name: string;
  iconName: string;
  colorHex: string;
  isDefault: boolean;
  displayOrder: number;
};

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [editModal, setEditModal] = useState<{
    open: boolean;
    category?: Category;
  }>({ open: false });
  const [form, setForm] = useState({ name: "", iconName: "", colorHex: "" });

  async function fetchCategories() {
    const res = await fetch("/api/categories");
    setCategories(await res.json());
  }

  useEffect(() => {
    fetchCategories();
  }, []);

  function openCreate() {
    setForm({ name: "", iconName: "menu_book", colorHex: "6366F1" });
    setEditModal({ open: true });
  }

  function openEdit(cat: Category) {
    setForm({ name: cat.name, iconName: cat.iconName, colorHex: cat.colorHex });
    setEditModal({ open: true, category: cat });
  }

  async function handleSave() {
    if (editModal.category) {
      await fetch(`/api/categories/${editModal.category.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
    } else {
      await fetch("/api/categories", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
    }
    setEditModal({ open: false });
    fetchCategories();
  }

  async function handleDelete(id: string) {
    await fetch(`/api/categories/${id}`, { method: "DELETE" });
    fetchCategories();
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">카테고리</h1>
        <Button size="sm" onClick={openCreate}>
          <Plus className="h-4 w-4 mr-1" />
          추가
        </Button>
      </div>

      <div className="space-y-2">
        {categories.map((cat) => (
          <Card key={cat.id}>
            <CardContent className="flex items-center gap-3 p-3">
              <GripVertical className="h-4 w-4 text-muted-foreground cursor-grab" />
              <div
                className="h-4 w-4 rounded-full"
                style={{ backgroundColor: `#${cat.colorHex}` }}
              />
              <span className="flex-1 font-medium">{cat.name}</span>
              <span className="text-xs text-muted-foreground">#{cat.colorHex}</span>
              <Button variant="ghost" size="icon" onClick={() => openEdit(cat)}>
                <Pencil className="h-4 w-4" />
              </Button>
              {!cat.isDefault && (
                <Button variant="ghost" size="icon" onClick={() => handleDelete(cat.id)}>
                  <Trash2 className="h-4 w-4" />
                </Button>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      <Dialog open={editModal.open} onOpenChange={(open) => setEditModal({ open })}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>
              {editModal.category ? "카테고리 수정" : "새 카테고리"}
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
              <Label>아이콘</Label>
              <Input
                value={form.iconName}
                onChange={(e) => setForm({ ...form, iconName: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label>색상 (HEX)</Label>
              <div className="flex gap-2 items-center">
                <Input
                  value={form.colorHex}
                  onChange={(e) => setForm({ ...form, colorHex: e.target.value })}
                />
                <div
                  className="h-8 w-8 rounded border"
                  style={{ backgroundColor: `#${form.colorHex}` }}
                />
              </div>
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
