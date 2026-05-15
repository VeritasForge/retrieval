import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules, tasks, strategies } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { today } from "@/lib/utils";
import { calculateFirstReviewDate } from "@/lib/review-scheduler";

export async function POST(_req: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;

  // 사전 검증 — 트랜잭션 외부 (F06)
  const [review] = await db
    .select()
    .from(reviewSchedules)
    .where(and(eq(reviewSchedules.id, id), eq(reviewSchedules.userId, userId)))
    .limit(1);
  if (!review) return NextResponse.json({ error: "Not found" }, { status: 404 });

  const [task] = await db.select().from(tasks).where(eq(tasks.id, review.taskId)).limit(1);
  if (!task) return NextResponse.json({ error: "Not found" }, { status: 404 });

  const [strategy] = await db.select().from(strategies).where(eq(strategies.id, task.strategyId)).limit(1);
  if (!strategy) return NextResponse.json({ error: "Not found" }, { status: 404 });

  if (strategy.type !== "fixed") {
    return NextResponse.json(
      { error: "Reset is only supported for fixed strategy" },
      { status: 400 }
    );
  }

  // mutation — 트랜잭션 내부
  const newStudyDate = today();
  const firstDate = calculateFirstReviewDate(
    newStudyDate,
    strategy.type,
    strategy.intervals as number[]
  );

  await db.transaction(async (tx) => {
    await tx
      .delete(reviewSchedules)
      .where(and(eq(reviewSchedules.taskId, task.id), eq(reviewSchedules.status, "pending")));
    await tx
      .update(tasks)
      .set({ level: 0, studyDate: newStudyDate, graduated: false, graduatedAt: null })
      .where(eq(tasks.id, task.id));
    await tx.insert(reviewSchedules).values({
      userId,
      taskId: task.id,
      scheduledDate: firstDate,
      reviewOrder: 0,
    });
  });

  return NextResponse.json({ success: true });
}
