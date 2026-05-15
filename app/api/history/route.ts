import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, categories, strategies } from "@/db/schema";
import { and, eq, desc, sql } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

export async function GET(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();

  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get("page") ?? "1", 10);
  const dateParam = searchParams.get("date");
  const limit = 20;
  const offset = (page - 1) * limit;

  const conditions = [
    eq(reviewSchedules.userId, userId),
    eq(reviewSchedules.status, "completed"),
  ];
  if (dateParam && DATE_RE.test(dateParam)) {
    conditions.push(
      sql`date(${reviewSchedules.completedAt} AT TIME ZONE 'Asia/Seoul') = ${dateParam}`
    );
  }

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
    .where(and(...conditions))
    .orderBy(desc(reviewSchedules.completedAt))
    .limit(limit)
    .offset(offset);

  return NextResponse.json(result);
}
