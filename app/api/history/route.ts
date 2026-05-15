import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, categories, strategies } from "@/db/schema";
import { and, eq, desc } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";

export async function GET(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();

  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get("page") ?? "1", 10);
  const limit = 20;
  const offset = (page - 1) * limit;

  const result = await db
    .select({
      review: reviewSchedules,
      task: tasks,
      category: categories,
      strategy: strategies,
    })
    .from(reviewSchedules)
    .innerJoin(tasks, eq(reviewSchedules.taskId, tasks.id))
    .innerJoin(categories, eq(tasks.categoryId, categories.id))
    .innerJoin(strategies, eq(tasks.strategyId, strategies.id))
    .where(
      and(
        eq(reviewSchedules.userId, userId),
        eq(reviewSchedules.status, "completed")
      )
    )
    .orderBy(desc(reviewSchedules.completedAt))
    .limit(limit)
    .offset(offset);

  return NextResponse.json(result);
}
