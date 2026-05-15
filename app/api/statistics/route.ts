import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, categories } from "@/db/schema";
import { and, eq, sql, gte, lte } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { today, addDays } from "@/lib/utils";

export async function GET(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();

  const { searchParams } = new URL(request.url);
  const yearParam = searchParams.get("year");
  const todayStr = today();
  const twoWeeksAgo = addDays(todayStr, -14);

  let heatmapStart: string;
  let heatmapEnd: string;
  if (yearParam && /^\d{4}$/.test(yearParam)) {
    heatmapStart = `${yearParam}-01-01`;
    heatmapEnd = `${yearParam}-12-31`;
  } else {
    heatmapStart = addDays(todayStr, -365);
    heatmapEnd = todayStr;
  }

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

  // 히트맵 (날짜 + 카테고리별 breakdown)
  const heatmapRows = await db
    .select({
      date: reviewSchedules.scheduledDate,
      categoryName: categories.name,
      colorHex: categories.colorHex,
      count: sql<number>`count(*)::int`,
    })
    .from(reviewSchedules)
    .innerJoin(tasks, eq(reviewSchedules.taskId, tasks.id))
    .innerJoin(categories, eq(tasks.categoryId, categories.id))
    .where(
      and(
        eq(reviewSchedules.userId, userId),
        eq(reviewSchedules.status, "completed"),
        gte(reviewSchedules.scheduledDate, heatmapStart),
        lte(reviewSchedules.scheduledDate, heatmapEnd)
      )
    )
    .groupBy(
      reviewSchedules.scheduledDate,
      categories.name,
      categories.colorHex
    );

  type HeatmapDay = {
    date: string;
    count: number;
    byCategory: { name: string; color: string; count: number }[];
  };
  const heatmapMap = new Map<string, HeatmapDay>();
  for (const row of heatmapRows) {
    const existing = heatmapMap.get(row.date) ?? {
      date: row.date,
      count: 0,
      byCategory: [],
    };
    existing.count += row.count;
    existing.byCategory.push({
      name: row.categoryName,
      color: `#${row.colorHex}`,
      count: row.count,
    });
    heatmapMap.set(row.date, existing);
  }
  const heatmap: HeatmapDay[] = Array.from(heatmapMap.values());

  // 사용 가능 연도 목록 (가장 오래된 완료 복습 ~ 현재 연도)
  const [firstCompleted] = await db
    .select({ date: sql<string | null>`min(${reviewSchedules.scheduledDate})` })
    .from(reviewSchedules)
    .where(
      and(
        eq(reviewSchedules.userId, userId),
        eq(reviewSchedules.status, "completed")
      )
    );
  const currentYear = new Date().getFullYear();
  const firstYear = firstCompleted?.date
    ? parseInt(firstCompleted.date.slice(0, 4), 10)
    : currentYear;
  const availableYears: number[] = [];
  for (let y = currentYear; y >= firstYear; y--) {
    availableYears.push(y);
  }

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
    heatmap,
    heatmapRange: { start: heatmapStart, end: heatmapEnd },
    availableYears,
    categoryPerformance: categoryPerf,
    graduation: {
      count: graduatedTasks.length,
      tasks: graduatedTasks,
    },
  });
}
