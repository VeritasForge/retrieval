import { NextResponse } from "next/server";
import { db } from "@/db";
import { categories } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { updateCategorySchema } from "@/lib/validators";

export async function PATCH(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const body = await request.json();
  const parsed = updateCategorySchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
  const [updated] = await db.update(categories).set(parsed.data).where(and(eq(categories.id, id), eq(categories.userId, userId))).returning();
  if (!updated) return NextResponse.json({ error: "Not found" }, { status: 404 });
  return NextResponse.json(updated);
}

export async function DELETE(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const { id } = await params;
  const [category] = await db.select().from(categories).where(and(eq(categories.id, id), eq(categories.userId, userId))).limit(1);
  if (!category) return NextResponse.json({ error: "Not found" }, { status: 404 });
  if (category.isDefault) return NextResponse.json({ error: "기본 카테고리는 삭제할 수 없습니다" }, { status: 400 });
  await db.delete(categories).where(and(eq(categories.id, id), eq(categories.userId, userId)));
  return NextResponse.json({ success: true });
}
