import { boolean, jsonb, pgEnum, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { users } from "./users";

export const strategyTypeEnum = pgEnum("strategy_type", ["fixed", "sm2"]);

export const strategies = pgTable("strategies", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id").notNull().references(() => users.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  type: strategyTypeEnum("type").notNull().default("fixed"),
  intervals: jsonb("intervals").$type<number[]>(),
  isDefault: boolean("is_default").notNull().default(false),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
