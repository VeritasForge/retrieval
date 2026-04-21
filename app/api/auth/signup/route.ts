import { NextResponse } from "next/server";
import { hash } from "bcryptjs";
import { db } from "@/db";
import { users } from "@/db/schema";
import { eq } from "drizzle-orm";
import { seedDefaultsForUser } from "@/db/seed-defaults";

export async function POST(request: Request) {
  const body = await request.json();
  const { email, password, name } = body;

  const existing = await db
    .select()
    .from(users)
    .where(eq(users.email, email))
    .limit(1);

  if (existing.length > 0) {
    return NextResponse.json(
      { error: "이미 존재하는 이메일입니다" },
      { status: 409 }
    );
  }

  const passwordHash = await hash(password, 12);

  const [user] = await db
    .insert(users)
    .values({ email, name, passwordHash })
    .returning();

  await seedDefaultsForUser(user.id);

  return NextResponse.json({ id: user.id }, { status: 201 });
}
