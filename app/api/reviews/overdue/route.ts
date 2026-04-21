import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules } from "@/db/schema";
import { and, eq, inArray } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { today } from "@/lib/utils";
import { z } from "zod";

const overdueActionSchema = z.object({
  reviewIds: z.array(z.string().uuid()),
  action: z.enum(["reschedule", "skip"]),
});

export async function POST(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const body = await request.json();
  const parsed = overdueActionSchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });

  if (parsed.data.action === "reschedule") {
    await db.update(reviewSchedules).set({ scheduledDate: today() }).where(and(eq(reviewSchedules.userId, userId), inArray(reviewSchedules.id, parsed.data.reviewIds)));
  } else {
    await db.update(reviewSchedules).set({ status: "skipped", completedAt: new Date() }).where(and(eq(reviewSchedules.userId, userId), inArray(reviewSchedules.id, parsed.data.reviewIds)));
  }
  return NextResponse.json({ success: true });
}
