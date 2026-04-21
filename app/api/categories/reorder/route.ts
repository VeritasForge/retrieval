import { NextResponse } from "next/server";
import { db } from "@/db";
import { categories } from "@/db/schema";
import { and, eq } from "drizzle-orm";
import { getAuthUserId, unauthorized } from "@/lib/auth-utils";
import { z } from "zod";

const reorderSchema = z.object({ orderedIds: z.array(z.string().uuid()) });

export async function POST(request: Request) {
  const userId = await getAuthUserId();
  if (!userId) return unauthorized();
  const body = await request.json();
  const parsed = reorderSchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
  const updates = parsed.data.orderedIds.map((id, index) =>
    db.update(categories).set({ displayOrder: index }).where(and(eq(categories.id, id), eq(categories.userId, userId)))
  );
  await Promise.all(updates);
  return NextResponse.json({ success: true });
}
