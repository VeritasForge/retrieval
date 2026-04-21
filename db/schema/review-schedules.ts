import { date, integer, pgEnum, pgTable, timestamp, uuid } from "drizzle-orm/pg-core";
import { users } from "./users";
import { tasks } from "./tasks";

export const reviewStatusEnum = pgEnum("review_status", ["pending", "completed", "skipped"]);

export const reviewSchedules = pgTable("review_schedules", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id").notNull().references(() => users.id, { onDelete: "cascade" }),
  taskId: uuid("task_id").notNull().references(() => tasks.id, { onDelete: "cascade" }),
  scheduledDate: date("scheduled_date").notNull(),
  reviewOrder: integer("review_order").notNull(),
  status: reviewStatusEnum("status").notNull().default("pending"),
  rating: integer("rating"),
  completedAt: timestamp("completed_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
