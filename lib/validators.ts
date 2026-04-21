import { z } from "zod";

export const createTaskSchema = z.object({
  categoryId: z.string().uuid(),
  strategyId: z.string().uuid(),
  studyDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  title: z.string().min(1),
});

export const createCategorySchema = z.object({
  name: z.string().min(1).max(50),
  iconName: z.string().min(1),
  colorHex: z.string().regex(/^[0-9A-Fa-f]{6}$/),
});

export const updateCategorySchema = createCategorySchema.partial();

export const createStrategySchema = z.object({
  name: z.string().min(1).max(50),
  intervals: z.array(z.number().int().positive()).min(1),
});

export const completeReviewSchema = z.object({
  rating: z.number().int().min(0).max(3).optional(),
});

export const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(1).max(50),
});
