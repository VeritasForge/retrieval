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
