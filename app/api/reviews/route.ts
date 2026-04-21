import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, categories, strategies } from "@/db/schema";
import { and, eq, sql } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { today } from "@/lib/utils";

export async function GET() {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const todayStr = today();

  const result = await db
    .select({ review: reviewSchedules, task: tasks, category: categories, strategy: strategies })
    .from(reviewSchedules)
    .innerJoin(tasks, eq(reviewSchedules.taskId, tasks.id))
    .innerJoin(categories, eq(tasks.categoryId, categories.id))
    .innerJoin(strategies, eq(tasks.strategyId, strategies.id))
    .where(and(
      eq(reviewSchedules.userId, userId),
      sql`(
        (${reviewSchedules.status} = 'pending' AND ${reviewSchedules.scheduledDate} <= ${todayStr})
        OR
        (${reviewSchedules.status} = 'completed' AND ${reviewSchedules.completedAt}::date = ${todayStr}::date)
      )`
    ));

  const todayReviews = result.filter((r) => r.review.status === "pending" && r.review.scheduledDate === todayStr);
  const overdueReviews = result.filter((r) => r.review.status === "pending" && r.review.scheduledDate < todayStr);
  const completedToday = result.filter((r) => r.review.status === "completed");

  const upcomingResult = await db
    .select({ review: reviewSchedules, task: tasks, category: categories, strategy: strategies })
    .from(reviewSchedules)
    .innerJoin(tasks, eq(reviewSchedules.taskId, tasks.id))
    .innerJoin(categories, eq(tasks.categoryId, categories.id))
    .innerJoin(strategies, eq(tasks.strategyId, strategies.id))
    .where(and(
      eq(reviewSchedules.userId, userId),
      eq(reviewSchedules.status, "pending"),
      sql`${reviewSchedules.scheduledDate} > ${todayStr}`,
      sql`${reviewSchedules.scheduledDate} <= ${todayStr}::date + interval '7 days'`
    ));

  return NextResponse.json({ today: todayReviews, overdue: overdueReviews, completed: completedToday, upcoming: upcomingResult });
}
