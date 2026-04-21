import { NextResponse } from "next/server";
import { db } from "@/db";
import { reviewSchedules } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";

export async function POST(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const [updated] = await db.update(reviewSchedules).set({ status: "skipped", completedAt: new Date() }).where(and(eq(reviewSchedules.id, id), eq(reviewSchedules.userId, userId))).returning();
  if (!updated) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json({ success: true });
}
