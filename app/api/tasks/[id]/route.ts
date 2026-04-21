import { NextResponse } from "next/server";
import { db } from "@/db";
import { tasks, reviewSchedules } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";

export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const [task] = await db.select().from(tasks).where(and(eq(tasks.id, id), eq(tasks.userId, userId))).limit(1);
  if (!task) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(task);
}

export async function PATCH(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const body = await request.json();
  const [updated] = await db.update(tasks).set(body).where(and(eq(tasks.id, id), eq(tasks.userId, userId))).returning();
  if (!updated) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(updated);
}

export async function DELETE(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  await db.delete(reviewSchedules).where(and(eq(reviewSchedules.taskId, id), eq(reviewSchedules.userId, userId)));
  await db.delete(tasks).where(and(eq(tasks.id, id), eq(tasks.userId, userId)));
  return NextResponse.json({ success: true });
}
