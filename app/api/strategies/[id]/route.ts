import { NextResponse } from "next/server";
import { db } from "@/db";
import { strategies } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { createStrategySchema } from "@/lib/validators";

export async function PATCH(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const [existing] = await db.select().from(strategies).where(and(eq(strategies.id, id), eq(strategies.userId, userId))).limit(1);
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });
  if (existing.type === "sm2") return NextResponse.json({ error: "SM-2 전략은 수정할 수 없습니다" }, { status: 400 });
  const body = await request.json();
  const parsed = createStrategySchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
  const [updated] = await db.update(strategies).set({ name: parsed.data.name, intervals: parsed.data.intervals }).where(and(eq(strategies.id, id), eq(strategies.userId, userId))).returning();
  return NextResponse.json(updated);
}

export async function DELETE(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const [existing] = await db.select().from(strategies).where(and(eq(strategies.id, id), eq(strategies.userId, userId))).limit(1);
  if (!existing) return NextResponse.json({ error: "Not found" }, { status: 404 });
  if (existing.isDefault) return NextResponse.json({ error: "기본 전략은 삭제할 수 없습니다" }, { status: 400 });
  await db.delete(strategies).where(and(eq(strategies.id, id), eq(strategies.userId, userId)));
  return NextResponse.json({ success: true });
}
