import { NextResponse } from "next/server";
import { db } from "@/db";
import { categories } from "@/db/schema";
import { eq, asc } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { createCategorySchema } from "@/lib/validators";

export async function GET() {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const result = await db.select().from(categories).where(eq(categories.userId, userId)).orderBy(asc(categories.displayOrder));
  return NextResponse.json(result);
}

export async function POST(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const body = await request.json();
  const parsed = createCategorySchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
  const existing = await db.select().from(categories).where(eq(categories.userId, userId));
  const [created] = await db.insert(categories).values({ userId, ...parsed.data, displayOrder: existing.length, isDefault: false }).returning();
  return NextResponse.json(created, { status: 201 });
}
