import { boolean, date, integer, pgTable, real, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { users } from "./users";
import { categories } from "./categories";
import { strategies } from "./strategies";

export const tasks = pgTable("tasks", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id").notNull().references(() => users.id, { onDelete: "cascade" }),
  categoryId: uuid("category_id").notNull().references(() => categories.id),
  strategyId: uuid("strategy_id").notNull().references(() => strategies.id),
  title: text("title").notNull().default(""),
  studyDate: date("study_date").notNull(),
  level: integer("level").notNull().default(0),
  easinessFactor: real("easiness_factor").notNull().default(2.5),
  interval: integer("interval").notNull().default(0),
  repetitions: integer("repetitions").notNull().default(0),
  graduated: boolean("graduated").notNull().default(false),
  graduatedAt: timestamp("graduated_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
