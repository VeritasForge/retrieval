# Remove Subtasks + FAB Button Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Simplify task structure from 1 card = N subtasks to 1 card = 1 title, and move the add button from TodayReviews section to a floating action button (FAB).

**Architecture:** Remove `subtasks` JSONB column from tasks table, add `title` TEXT column. Strip all subtask-related UI (checkboxes, toggle, add/remove). Replace "Add" button inside TodayReviews with a fixed-position FAB at bottom-right corner.

**Tech Stack:** Next.js 16, Drizzle ORM, PostgreSQL (Neon), Zustand, TypeScript, @base-ui/react

---

### Task 1: DB Schema — Replace subtasks with title

**Files:**
- Modify: `db/schema/tasks.ts`

- [ ] **Step 1: Remove SubtaskJson type and subtasks column, add title column**

Replace the entire file content with:

```ts
import { boolean, date, integer, pgTable, real, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { users } from "./users";
import { categories } from "./categories";
import { strategies } from "./strategies";

export const tasks = pgTable("tasks", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id").notNull().references(() => users.id, { onDelete: "cascade" }),
  categoryId: uuid("category_id").notNull().references(() => categories.id),
  strategyId: uuid("strategy_id").notNull().references(() => strategies.id),
  title: text("title").notNull().default(""),
  studyDate: date("study_date").notNull(),
  level: integer("level").notNull().default(0),
  easinessFactor: real("easiness_factor").notNull().default(2.5),
  interval: integer("interval").notNull().default(0),
  repetitions: integer("repetitions").notNull().default(0),
  graduated: boolean("graduated").notNull().default(false),
  graduatedAt: timestamp("graduated_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
```

Key changes:
- Removed `SubtaskJson` type export (lines 6-10)
- Removed `jsonb` import, added `text` import
- Replaced `subtasks: jsonb(...)` with `title: text("title").notNull().default("")`

- [ ] **Step 2: Verify schema index still exports correctly**

`db/schema/index.ts` does `export * from "./tasks"` — since `SubtaskJson` is removed, any file importing it will fail at compile time. That's expected and will be fixed in later tasks.

- [ ] **Step 3: Commit**

```bash
git add db/schema/tasks.ts
git commit -m "refactor: replace subtasks JSONB with title TEXT column in tasks schema"
```

---

### Task 2: Validator — subtasks array to single title

**Files:**
- Modify: `lib/validators.ts`

- [ ] **Step 1: Replace subtasks with title in createTaskSchema**

Change lines 3-12 from:

```ts
export const createTaskSchema = z.object({
  categoryId: z.string().uuid(),
  strategyId: z.string().uuid(),
  studyDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  subtasks: z.array(
    z.object({
      title: z.string().min(1),
    })
  ),
});
```

To:

```ts
export const createTaskSchema = z.object({
  categoryId: z.string().uuid(),
  strategyId: z.string().uuid(),
  studyDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  title: z.string().min(1),
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/validators.ts
git commit -m "refactor: replace subtasks array with single title in createTaskSchema"
```

---

### Task 3: Task Creation API — remove subtask logic

**Files:**
- Modify: `app/api/tasks/route.ts`

- [ ] **Step 1: Simplify POST handler**

Replace the entire file with:

```ts
import { NextResponse } from "next/server";
import { db } from "@/db";
import { tasks, strategies, reviewSchedules } from "@/db/schema";
import { eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { createTaskSchema } from "@/lib/validators";
import { calculateFirstReviewDate } from "@/lib/review-scheduler";

export async function GET() {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const result = await db.select().from(tasks).where(eq(tasks.userId, userId));
  return NextResponse.json(result);
}

export async function POST(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const body = await request.json();
  const parsed = createTaskSchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });

  const [strategy] = await db.select().from(strategies).where(eq(strategies.id, parsed.data.strategyId)).limit(1);
  if (!strategy) return NextResponse.json({ error: "전략을 찾을 수 없습니다" }, { status: 400 });

  const [task] = await db.insert(tasks).values({
    userId,
    categoryId: parsed.data.categoryId,
    strategyId: parsed.data.strategyId,
    title: parsed.data.title,
    studyDate: parsed.data.studyDate,
  }).returning();

  const firstDate = calculateFirstReviewDate(parsed.data.studyDate, strategy.type, strategy.intervals);
  await db.insert(reviewSchedules).values({
    userId,
    taskId: task.id,
    scheduledDate: firstDate,
    reviewOrder: 0,
  });

  return NextResponse.json(task, { status: 201 });
}
```

Key changes:
- Removed `randomUUID` import
- Removed `subtasksWithIds` mapping logic
- Replaced `subtasks: subtasksWithIds` with `title: parsed.data.title`

- [ ] **Step 2: Commit**

```bash
git add app/api/tasks/route.ts
git commit -m "refactor: simplify task creation to use title instead of subtasks"
```

---

### Task 4: Delete subtask toggle API

**Files:**
- Delete: `app/api/tasks/[id]/subtasks/route.ts`

- [ ] **Step 1: Remove the subtasks endpoint file**

```bash
rm app/api/tasks/[id]/subtasks/route.ts
rmdir app/api/tasks/[id]/subtasks/
```

- [ ] **Step 2: Commit**

```bash
git add -A app/api/tasks/[id]/subtasks/
git commit -m "refactor: remove subtask toggle API endpoint"
```

---

### Task 5: Review completion — remove subtask reset

**Files:**
- Modify: `app/api/reviews/[id]/complete/route.ts`

- [ ] **Step 1: Remove subtask reset logic**

Replace the entire file with:

```ts
import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, strategies } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { completeReviewSchema } from "@/lib/validators";
import { calculateSm2 } from "@/lib/sm2";
import { calculateNextFixedDate, calculateNextSm2Date } from "@/lib/review-scheduler";

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const body = await request.json();
  const parsed = completeReviewSchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });

  const [review] = await db.select().from(reviewSchedules).where(and(eq(reviewSchedules.id, id), eq(reviewSchedules.userId, userId))).limit(1);
  if (!review || review.status !== "pending") return NextResponse.json({ error: "Not found or already completed" }, { status: 404 });

  const [task] = await db.select().from(tasks).where(eq(tasks.id, review.taskId)).limit(1);
  const [strategy] = await db.select().from(strategies).where(eq(strategies.id, task.strategyId)).limit(1);

  await db.update(reviewSchedules).set({ status: "completed", rating: parsed.data.rating ?? null, completedAt: new Date() }).where(eq(reviewSchedules.id, id));

  if (strategy.type === "fixed") {
    const nextLevel = task.level + 1;
    await db.update(tasks).set({ level: nextLevel }).where(eq(tasks.id, task.id));
    const nextDate = calculateNextFixedDate(task.studyDate, strategy.intervals as number[], nextLevel);
    if (nextDate) {
      await db.insert(reviewSchedules).values({ userId, taskId: task.id, scheduledDate: nextDate, reviewOrder: nextLevel });
    }
  } else {
    const rating = parsed.data.rating ?? 2;
    const sm2Result = calculateSm2({ easinessFactor: task.easinessFactor, interval: task.interval, repetitions: task.repetitions, rating });
    const taskUpdate: Record<string, unknown> = {
      easinessFactor: sm2Result.easinessFactor,
      interval: sm2Result.interval,
      repetitions: sm2Result.repetitions,
    };
    if (sm2Result.graduated) {
      taskUpdate.graduated = true;
      taskUpdate.graduatedAt = new Date();
    }
    await db.update(tasks).set(taskUpdate).where(eq(tasks.id, task.id));
    if (!sm2Result.graduated) {
      const nextDate = calculateNextSm2Date(sm2Result.interval);
      await db.insert(reviewSchedules).values({ userId, taskId: task.id, scheduledDate: nextDate, reviewOrder: review.reviewOrder + 1 });
    }
  }

  return NextResponse.json({ success: true });
}
```

Key changes:
- Removed `type SubtaskJson` import
- Removed `resetSubtasks` variable (old line 26)
- Fixed branch: `set({ level: nextLevel })` without subtasks
- SM2 branch: removed `subtasks: resetSubtasks` from taskUpdate

- [ ] **Step 2: Commit**

```bash
git add app/api/reviews/[id]/complete/route.ts
git commit -m "refactor: remove subtask reset from review completion"
```

---

### Task 6: UI Store — EditTaskTarget subtasks to title

**Files:**
- Modify: `stores/ui-store.ts`

- [ ] **Step 1: Replace subtasks with title in EditTaskTarget**

Replace lines 3-9:

```ts
type EditTaskTarget = {
  taskId: string;
  categoryId: string;
  strategyId: string;
  studyDate: string;
  subtasks: { id: string; title: string; isCompleted: boolean }[];
} | null;
```

With:

```ts
type EditTaskTarget = {
  taskId: string;
  categoryId: string;
  strategyId: string;
  studyDate: string;
  title: string;
} | null;
```

- [ ] **Step 2: Commit**

```bash
git add stores/ui-store.ts
git commit -m "refactor: update EditTaskTarget type to use title instead of subtasks"
```

---

### Task 7: AddTaskModal — single title input

**Files:**
- Modify: `components/task/add-task-modal.tsx`

- [ ] **Step 1: Replace subtask multi-input with single title**

Replace the entire file with:

```tsx
"use client";

import { useState } from "react";
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
  const [categoryId, setCategoryId] = useState("");
  const [strategyId, setStrategyId] = useState("");
  const [studyDate, setStudyDate] = useState(today());
  const [title, setTitle] = useState("");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!categoryId || !strategyId || !title.trim()) return;

    onAdd({ categoryId, strategyId, studyDate, title: title.trim() });
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
```

Key changes:
- Removed `X, Plus` icon imports (no longer needed for add/remove subtask buttons)
- `subtasks` state array replaced with single `title` string state
- Removed `addSubtask`, `removeSubtask`, `updateSubtask` functions
- Subtask multi-input section replaced with single "제목" Input field (placed at top with `autoFocus`)
- `onAdd` type: `subtasks: { title: string }[]` replaced with `title: string`
- Dialog title changed from "새 태스크 추가" to "새 학습 추가"

- [ ] **Step 2: Commit**

```bash
git add components/task/add-task-modal.tsx
git commit -m "refactor: simplify AddTaskModal to single title input"
```

---

### Task 8: EditTaskModal — single title edit

**Files:**
- Modify: `components/task/edit-task-modal.tsx`

- [ ] **Step 1: Replace subtask editing with single title**

Replace the entire file with:

```tsx
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
```

Key changes:
- Removed `X, Plus` imports
- `subtasks` state replaced with `title` state
- Removed `addSubtask`, `removeSubtask`, `updateSubtask` functions
- `onEdit` type: `subtasks` replaced with `title: string`
- Subtask section replaced with single "제목" Input

- [ ] **Step 2: Commit**

```bash
git add components/task/edit-task-modal.tsx
git commit -m "refactor: simplify EditTaskModal to single title edit"
```

---

### Task 9: TaskCard — replace checkbox list with title display

**Files:**
- Modify: `components/dashboard/task-card.tsx`

- [ ] **Step 1: Remove subtask rendering, add title display**

Replace the entire file with:

```tsx
"use client";

import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { DifficultyRating } from "@/components/review/difficulty-rating";
import { Check, Pencil, Trash2 } from "lucide-react";
import { useUiStore } from "@/stores/ui-store";

type TaskCardProps = {
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
  onComplete: (reviewId: string, rating?: number) => void;
  onDelete: (taskId: string) => void;
};

export function TaskCard({
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
  onComplete,
  onDelete,
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
    if (strategyType === "sm2") {
      setShowRating(true);
    } else {
      onComplete(reviewId);
    }
  }

  function handleRatingSelect(rating: number) {
    onComplete(reviewId, rating);
    setShowRating(false);
  }

  return (
    <Card className="border-l-4" style={{ borderLeftColor: `#${categoryColor}` }}>
      <CardContent className="p-4">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <span className="font-medium">{categoryName}</span>
            <Badge variant="outline" className="text-xs">
              {strategyName}
            </Badge>
          </div>
          <div className="flex gap-1">
            <Button size="sm" variant="ghost" onClick={handleEdit}>
              <Pencil className="h-4 w-4" />
            </Button>
            <Button size="sm" variant="ghost" className="text-destructive hover:text-destructive" onClick={() => onDelete(taskId)}>
              <Trash2 className="h-4 w-4" />
            </Button>
            <Button size="sm" onClick={handleComplete} disabled={showRating}>
              <Check className="h-4 w-4 mr-1" />
              복습 완료
            </Button>
          </div>
        </div>

        <p className="text-sm text-muted-foreground">{title}</p>

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
```

Key changes:
- Removed `Checkbox` import
- Removed `Subtask` type, `subtasks` prop, `onToggleSubtask` prop
- Added `title: string` prop
- Replaced subtask checkbox list (`<div className="space-y-1">...`) with `<p className="text-sm text-muted-foreground">{title}</p>`
- `handleEdit` now passes `title` instead of `subtasks`

- [ ] **Step 2: Commit**

```bash
git add components/dashboard/task-card.tsx
git commit -m "refactor: replace subtask checkboxes with title display in TaskCard"
```

---

### Task 10: TodayReviews — remove add button, remove subtask props

**Files:**
- Modify: `components/dashboard/today-reviews.tsx`

- [ ] **Step 1: Strip subtask references and add button**

Replace the entire file with:

```tsx
"use client";

import { TaskCard } from "./task-card";

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

export function TodayReviews({
  reviews,
  onComplete,
  onDelete,
}: TodayReviewsProps) {
  return (
    <section className="mb-6">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-lg font-semibold">
          오늘 복습할 것 ({reviews.length})
        </h2>
      </div>
      <div className="space-y-3">
        {reviews.map((item) => (
          <TaskCard
            key={item.review.id}
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
    </section>
  );
}
```

Key changes:
- Removed `Button`, `Plus`, `useUiStore` imports (add button moved to FAB)
- Removed `onToggleSubtask` from props
- Removed "추가" Button from header
- ReviewItem type: `subtasks` replaced with `title: string`
- TaskCard: `subtasks` prop replaced with `title`, removed `onToggleSubtask`

- [ ] **Step 2: Commit**

```bash
git add components/dashboard/today-reviews.tsx
git commit -m "refactor: remove add button and subtask props from TodayReviews"
```

---

### Task 11: CompletedReviews — remove subtask type reference

**Files:**
- Modify: `components/dashboard/completed-reviews.tsx`

- [ ] **Step 1: Replace subtasks with title in CompletedItem type**

Change lines 8-13 from:

```ts
type CompletedItem = {
  review: { id: string };
  task: { id: string; subtasks: { id: string; title: string; isCompleted: boolean }[] };
  category: { name: string; colorHex: string };
  strategy: { name: string };
};
```

To:

```ts
type CompletedItem = {
  review: { id: string };
  task: { id: string; title: string };
  category: { name: string; colorHex: string };
  strategy: { name: string };
};
```

- [ ] **Step 2: Commit**

```bash
git add components/dashboard/completed-reviews.tsx
git commit -m "refactor: update CompletedItem type to use title"
```

---

### Task 12: Dashboard page — remove subtask handlers, add FAB

**Files:**
- Modify: `app/(main)/page.tsx`

- [ ] **Step 1: Replace entire dashboard page**

Replace the entire file with:

```tsx
"use client";

import { useEffect, useState, useCallback } from "react";
import { DashboardHeader } from "@/components/dashboard/dashboard-header";
import { DashboardSummary } from "@/components/dashboard/dashboard-summary";
import { TodayReviews } from "@/components/dashboard/today-reviews";
import { CompletedReviews } from "@/components/dashboard/completed-reviews";
import { UpcomingReviews } from "@/components/dashboard/upcoming-reviews";
import { OverduePanel } from "@/components/dashboard/overdue-panel";
import { AddTaskModal } from "@/components/task/add-task-modal";
import { EditTaskModal } from "@/components/task/edit-task-modal";
import { useUiStore } from "@/stores/ui-store";
import { Plus } from "lucide-react";

type DashboardData = {
  today: any[];
  overdue: any[];
  completed: any[];
  upcoming: any[];
};

type Category = { id: string; name: string; iconName: string; colorHex: string };
type Strategy = { id: string; name: string; type: string; intervals: number[] | null };

export default function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [categories, setCategories] = useState<Category[]>([]);
  const [strategies, setStrategies] = useState<Strategy[]>([]);
  const [streak, setStreak] = useState(0);
  const openAddTaskModal = useUiStore((s) => s.openAddTaskModal);

  const fetchData = useCallback(async () => {
    const [reviewsRes, catsRes, stratsRes, statsRes] = await Promise.all([
      fetch("/api/reviews"),
      fetch("/api/categories"),
      fetch("/api/strategies"),
      fetch("/api/statistics").catch(() => null),
    ]);
    setData(await reviewsRes.json());
    setCategories(await catsRes.json());
    setStrategies(await stratsRes.json());
    if (statsRes && statsRes.ok) {
      const stats = await statsRes.json();
      setStreak(stats.streak?.current ?? 0);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  async function handleComplete(reviewId: string, rating?: number) {
    await fetch(`/api/reviews/${reviewId}/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ rating }),
    });
    fetchData();
  }

  async function handleAddTask(taskData: {
    categoryId: string;
    strategyId: string;
    studyDate: string;
    title: string;
  }) {
    await fetch("/api/tasks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(taskData),
    });
    fetchData();
  }

  async function handleEditTask(taskId: string, data: {
    categoryId: string;
    strategyId: string;
    studyDate: string;
    title: string;
  }) {
    await fetch(`/api/tasks/${taskId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    fetchData();
  }

  async function handleDeleteTask(taskId: string) {
    await fetch(`/api/tasks/${taskId}`, {
      method: "DELETE",
    });
    fetchData();
  }

  async function handleOverdueReschedule(reviewIds: string[]) {
    await fetch("/api/reviews/overdue", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ reviewIds, action: "reschedule" }),
    });
    fetchData();
  }

  async function handleOverdueSkip(reviewIds: string[]) {
    await fetch("/api/reviews/overdue", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ reviewIds, action: "skip" }),
    });
    fetchData();
  }

  if (!data) {
    return <div className="animate-pulse">로딩 중...</div>;
  }

  const totalToday = data.today.length + data.completed.length;

  return (
    <>
      <DashboardHeader />
      <DashboardSummary
        totalToday={totalToday}
        completedToday={data.completed.length}
        streak={streak}
      />
      <TodayReviews
        reviews={data.today}
        onComplete={handleComplete}
        onDelete={handleDeleteTask}
      />
      <CompletedReviews reviews={data.completed} />
      <UpcomingReviews reviews={data.upcoming} />
      <OverduePanel
        reviews={data.overdue}
        onReschedule={handleOverdueReschedule}
        onDelete={handleDeleteTask}
        onSkip={handleOverdueSkip}
      />
      <AddTaskModal
        categories={categories}
        strategies={strategies}
        onAdd={handleAddTask}
      />
      <EditTaskModal
        categories={categories}
        strategies={strategies}
        onEdit={handleEditTask}
        onDelete={handleDeleteTask}
      />

      {/* FAB - Floating Add Button */}
      <button
        onClick={openAddTaskModal}
        className="fixed bottom-6 right-6 h-14 w-14 rounded-full bg-primary text-primary-foreground shadow-lg flex items-center justify-center hover:bg-primary/90 transition-colors z-50"
      >
        <Plus className="h-6 w-6" />
      </button>
    </>
  );
}
```

Key changes:
- Added `useUiStore` and `Plus` imports
- Removed `handleToggleSubtask` function entirely
- `handleAddTask` type: `subtasks` replaced with `title`
- `handleEditTask` type: `subtasks` replaced with `title`
- Removed `onToggleSubtask` from TodayReviews props
- Added FAB button at bottom of JSX: fixed position, bottom-right, rounded, primary color

- [ ] **Step 2: Commit**

```bash
git add app/(main)/page.tsx
git commit -m "feat: add FAB button, remove subtask handlers from dashboard"
```

---

### Task 13: Task detail page — remove subtask section

**Files:**
- Modify: `app/(main)/tasks/[id]/page.tsx`

- [ ] **Step 1: Replace subtask section with title display**

Replace the entire file with:

```tsx
"use client";

import { useEffect, useState } from "react";
import { useRouter, useParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, Trash2 } from "lucide-react";
import { formatDate } from "@/lib/utils";

type Task = {
  id: string;
  categoryId: string;
  strategyId: string;
  title: string;
  studyDate: string;
  level: number;
  easinessFactor: number;
  interval: number;
  repetitions: number;
  graduated: boolean;
  createdAt: string;
};

export default function TaskDetailPage() {
  const router = useRouter();
  const params = useParams();
  const [task, setTask] = useState<Task | null>(null);

  useEffect(() => {
    fetch(`/api/tasks/${params.id}`)
      .then((res) => res.json())
      .then(setTask);
  }, [params.id]);

  async function handleDelete() {
    if (!confirm("이 태스크를 삭제하시겠습니까?")) return;
    await fetch(`/api/tasks/${params.id}`, { method: "DELETE" });
    router.push("/");
  }

  if (!task) {
    return <div className="animate-pulse">로딩 중...</div>;
  }

  return (
    <div>
      <Button variant="ghost" size="sm" onClick={() => router.back()} className="mb-4">
        <ArrowLeft className="h-4 w-4 mr-1" />
        뒤로
      </Button>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span>{task.title || "태스크 상세"}</span>
            {task.graduated && <Badge className="bg-indigo-500">졸업</Badge>}
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div>
            <Label className="text-muted-foreground">공부한 날</Label>
            <p>{formatDate(task.studyDate)}</p>
          </div>
          <div>
            <Label className="text-muted-foreground">복습 단계</Label>
            <p>Level {task.level}</p>
          </div>
          <div>
            <Label className="text-muted-foreground">EF / 간격 / 반복수</Label>
            <p>
              {task.easinessFactor.toFixed(2)} / {task.interval}일 / {task.repetitions}회
            </p>
          </div>
        </CardContent>
      </Card>

      <Button variant="destructive" onClick={handleDelete}>
        <Trash2 className="h-4 w-4 mr-1" />
        태스크 삭제
      </Button>
    </div>
  );
}
```

Key changes:
- Removed `Checkbox` import
- Removed `Subtask` type, replaced `subtasks` with `title` in Task type
- Removed `handleToggleSubtask` function
- Removed entire "서브태스크" Card section (old lines 91-111)
- Card title now shows `task.title` instead of "태스크 상세"

- [ ] **Step 2: Commit**

```bash
git add app/(main)/tasks/[id]/page.tsx
git commit -m "refactor: replace subtask section with title on task detail page"
```

---

### Task 14: Generate and apply DB migration

- [ ] **Step 1: Generate migration SQL**

Run: `npx drizzle-kit generate`

Expected: Creates a migration file in `drizzle/` directory with SQL that:
- Adds `title TEXT NOT NULL DEFAULT ''` column
- Drops `subtasks` column

- [ ] **Step 2: Review the generated SQL**

Read the generated migration file and verify it contains the expected ALTER TABLE statements.

- [ ] **Step 3: Apply migration**

Run: `npx drizzle-kit push`

Expected: Schema changes applied to database.

- [ ] **Step 4: Commit migration**

```bash
git add drizzle/
git commit -m "chore: add migration for subtasks removal and title column"
```

---

### Task 15: Final verification

- [ ] **Step 1: TypeScript type check**

Run: `npx tsc --noEmit`
Expected: No errors

- [ ] **Step 2: Build check**

Run: `npx next build`
Expected: Build succeeds with no errors

- [ ] **Step 3: Commit all remaining changes**

If any uncommitted files remain:

```bash
git add -A
git commit -m "chore: final cleanup after subtask removal"
```
