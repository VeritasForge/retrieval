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

  return await db.transaction(async (tx) => {
    // Atomic claim — 트랜잭션 첫 작업.
    // claim 실패 시 mutation 0건 commit (무해), 후속 throw 시에만 rollback 의미.
    const [claimed] = await tx
      .update(reviewSchedules)
      .set({ status: "completed", rating: parsed.data.rating ?? null, completedAt: new Date() })
      .where(and(
        eq(reviewSchedules.id, id),
        eq(reviewSchedules.userId, userId),
        eq(reviewSchedules.status, "pending"),
      ))
      .returning();

    if (!claimed) {
      return NextResponse.json({ error: "Not found or already completed" }, { status: 404 });
    }

    const [task] = await tx.select().from(tasks).where(eq(tasks.id, claimed.taskId)).limit(1);
    const [strategy] = await tx.select().from(strategies).where(eq(strategies.id, task.strategyId)).limit(1);

    if (strategy.type === "fixed") {
      const nextLevel = task.level + 1;
      const nextDate = calculateNextFixedDate(task.studyDate, strategy.intervals as number[], nextLevel);
      const taskUpdate: Record<string, unknown> = { level: nextLevel };
      if (!nextDate) {
        taskUpdate.graduated = true;
        taskUpdate.graduatedAt = new Date();
      }
      await tx.update(tasks).set(taskUpdate).where(eq(tasks.id, task.id));
      if (nextDate) {
        await tx.insert(reviewSchedules).values({
          userId, taskId: task.id, scheduledDate: nextDate, reviewOrder: nextLevel,
        });
      }
    } else {
      const rating = parsed.data.rating ?? 2;
      const sm2Result = calculateSm2({
        easinessFactor: task.easinessFactor,
        interval: task.interval,
        repetitions: task.repetitions,
        rating,
      });
      const taskUpdate: Record<string, unknown> = {
        easinessFactor: sm2Result.easinessFactor,
        interval: sm2Result.interval,
        repetitions: sm2Result.repetitions,
      };
      if (sm2Result.graduated) {
        taskUpdate.graduated = true;
        taskUpdate.graduatedAt = new Date();
      }
      await tx.update(tasks).set(taskUpdate).where(eq(tasks.id, task.id));
      if (!sm2Result.graduated) {
        const nextDate = calculateNextSm2Date(sm2Result.interval);
        await tx.insert(reviewSchedules).values({
          userId, taskId: task.id, scheduledDate: nextDate, reviewOrder: claimed.reviewOrder + 1,
        });
      }
    }

    return NextResponse.json({ success: true });
  });
}
