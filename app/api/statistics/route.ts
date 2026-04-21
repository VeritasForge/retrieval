import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, categories } from "@/db/schema";
import { and, eq, sql, gte } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { today, addDays } from "@/lib/utils";

export async function GET() {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();

  const todayStr = today();
  const twoWeeksAgo = addDays(todayStr, -14);
  const oneYearAgo = addDays(todayStr, -365);

  // 일별 복습수 (최근 2주)
  const dailyCounts = await db
    .select({
      date: reviewSchedules.scheduledDate,
      count: sql<number>`count(*)::int`,
    })
    .from(reviewSchedules)
    .where(
      and(
        eq(reviewSchedules.userId, userId),
        eq(reviewSchedules.status, "completed"),
        gte(reviewSchedules.scheduledDate, twoWeeksAgo)
      )
    )
    .groupBy(reviewSchedules.scheduledDate)
    .orderBy(reviewSchedules.scheduledDate);

  // 이번 주 완료율
  const weekStart = addDays(todayStr, -new Date().getDay());
  const weekStats = await db
    .select({
      total: sql<number>`count(*)::int`,
      completed: sql<number>`count(*) filter (where ${reviewSchedules.status} = 'completed')::int`,
    })
    .from(reviewSchedules)
    .where(
      and(
        eq(reviewSchedules.userId, userId),
        gte(reviewSchedules.scheduledDate, weekStart),
        sql`${reviewSchedules.scheduledDate} <= ${todayStr}`
      )
    );

  // 스트릭 계산
  let currentStreak = 0;
  let checkDate = todayStr;
  while (true) {
    const [result] = await db
      .select({ count: sql<number>`count(*)::int` })
      .from(reviewSchedules)
      .where(
        and(
          eq(reviewSchedules.userId, userId),
          eq(reviewSchedules.status, "completed"),
          eq(reviewSchedules.scheduledDate, checkDate)
        )
      );
    if (result.count === 0) break;
    currentStreak++;
    checkDate = addDays(checkDate, -1);
  }

  // 히트맵 (최근 1년)
  const heatmapData = await db
    .select({
      date: reviewSchedules.scheduledDate,
      count: sql<number>`count(*)::int`,
    })
    .from(reviewSchedules)
    .where(
      and(
        eq(reviewSchedules.userId, userId),
        eq(reviewSchedules.status, "completed"),
        gte(reviewSchedules.scheduledDate, oneYearAgo)
      )
    )
    .groupBy(reviewSchedules.scheduledDate);

  // 카테고리별 성과
  const categoryPerf = await db
    .select({
      categoryId: tasks.categoryId,
      categoryName: categories.name,
      colorHex: categories.colorHex,
      total: sql<number>`count(${reviewSchedules.id})::int`,
      completed: sql<number>`count(*) filter (where ${reviewSchedules.status} = 'completed')::int`,
    })
    .from(reviewSchedules)
    .innerJoin(tasks, eq(reviewSchedules.taskId, tasks.id))
    .innerJoin(categories, eq(tasks.categoryId, categories.id))
    .where(eq(reviewSchedules.userId, userId))
    .groupBy(tasks.categoryId, categories.name, categories.colorHex);

  // 졸업 현황
  const graduatedTasks = await db
    .select({
      id: tasks.id,
      categoryId: tasks.categoryId,
      graduatedAt: tasks.graduatedAt,
    })
    .from(tasks)
    .where(and(eq(tasks.userId, userId), eq(tasks.graduated, true)));

  return NextResponse.json({
    dailyCounts,
    completionRate: {
      total: weekStats[0]?.total ?? 0,
      completed: weekStats[0]?.completed ?? 0,
    },
    streak: { current: currentStreak },
    heatmap: heatmapData,
    categoryPerformance: categoryPerf,
    graduation: {
      count: graduatedTasks.length,
      tasks: graduatedTasks,
    },
  });
}
