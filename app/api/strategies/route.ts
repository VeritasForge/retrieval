import { NextResponse } from "next/server";
import { db } from "@/db";
import { strategies } from "@/db/schema";
import { eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { createStrategySchema } from "@/lib/validators";

export async function GET() {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const result = await db.select().from(strategies).where(eq(strategies.userId, userId));
  return NextResponse.json(result);
}

export async function POST(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const body = await request.json();
  const parsed = createStrategySchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
  const [created] = await db.insert(strategies).values({ userId, name: parsed.data.name, type: "fixed", intervals: parsed.data.intervals, isDefault: false }).returning();
  return NextResponse.json(created, { status: 201 });
}
