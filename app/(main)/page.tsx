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

  async function handleOverdueReschedule(reviewId: string) {
    await fetch("/api/reviews/overdue", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ reviewIds: [reviewId], action: "reschedule" }),
    });
    fetchData();
  }

  async function handleOverdueSkip(reviewId: string) {
    await fetch("/api/reviews/overdue", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ reviewIds: [reviewId], action: "skip" }),
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
      <CompletedReviews
        reviews={data.completed}
        onDelete={handleDeleteTask}
      />
      <UpcomingReviews
        reviews={data.upcoming}
        onDelete={handleDeleteTask}
      />
      <OverduePanel
        reviews={data.overdue}
        onReschedule={handleOverdueReschedule}
        onSkip={handleOverdueSkip}
        onDelete={handleDeleteTask}
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
