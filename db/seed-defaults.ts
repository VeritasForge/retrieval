/**
 * 기본 카테고리 및 전략 시드 데이터
 *
 * 신규 사용자 가입 시 또는 DB 초기화 후 복원 시 사용
 * Flutter 버전 default_categories.dart + seed_default_strategies.dart에서 이식
 *
 * 실행: npx tsx db/seed-defaults.ts
 */

import { db } from "./index";
import { categories, strategies } from "./schema";
import { eq } from "drizzle-orm";

export const DEFAULT_CATEGORIES = [
  { name: "독서", iconName: "menu_book", colorHex: "10B981", displayOrder: 0 },
  { name: "알고리즘", iconName: "code", colorHex: "6366F1", displayOrder: 1 },
  { name: "강의", iconName: "school", colorHex: "F59E0B", displayOrder: 2 },
  { name: "메모", iconName: "description", colorHex: "F43F5E", displayOrder: 3 },
  { name: "CS", iconName: "cpu", colorHex: "8B5CF6", displayOrder: 4 },
  { name: "System Design", iconName: "network", colorHex: "0EA5E9", displayOrder: 5 },
] as const;

export const DEFAULT_STRATEGIES = [
  { name: "에빙하우스 (표준)", type: "fixed" as const, intervals: [1, 3, 7, 14, 30] },
  { name: "피보나치 (자연)", type: "fixed" as const, intervals: [1, 2, 3, 5, 8, 13] },
  { name: "단기 집중 (스피드)", type: "fixed" as const, intervals: [1, 3, 6, 10] },
  { name: "SM-2 (적응형)", type: "sm2" as const, intervals: null },
] as const;

export async function seedDefaultsForUser(userId: string) {
  const existingCats = await db.select().from(categories).where(eq(categories.userId, userId));
  if (existingCats.length === 0) {
    for (const cat of DEFAULT_CATEGORIES) {
      await db.insert(categories).values({ userId, ...cat, isDefault: true });
    }
    console.log(`Seeded ${DEFAULT_CATEGORIES.length} categories for user ${userId}`);
  }

  const existingStrats = await db.select().from(strategies).where(eq(strategies.userId, userId));
  if (existingStrats.length === 0) {
    for (const strat of DEFAULT_STRATEGIES) {
      await db.insert(strategies).values({
        userId,
        name: strat.name,
        type: strat.type,
        intervals: strat.intervals as number[] | null,
        isDefault: true,
      });
    }
    console.log(`Seeded ${DEFAULT_STRATEGIES.length} strategies for user ${userId}`);
  }
}

// CLI 실행 시 모든 사용자에 대해 시딩
async function main() {
  const { users } = await import("./schema");
  const allUsers = await db.select().from(users);
  for (const user of allUsers) {
    await seedDefaultsForUser(user.id);
  }
  console.log("Seed complete");
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
