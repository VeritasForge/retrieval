import { addDays, today } from "./utils";

export function calculateNextFixedDate(
  studyDate: string,
  intervals: number[],
  nextLevel: number
): string | null {
  if (nextLevel >= intervals.length) return null;

  const nextDate = addDays(studyDate, intervals[nextLevel]);
  return nextDate < today() ? today() : nextDate;
}

export function calculateNextSm2Date(interval: number): string {
  const nextDate = addDays(today(), interval);
  return nextDate;
}

export function calculateFirstReviewDate(
  studyDate: string,
  strategyType: "fixed" | "sm2",
  intervals: number[] | null
): string {
  const tomorrow = addDays(studyDate, 1);

  if (strategyType === "fixed" && intervals && intervals.length > 0) {
    const date = addDays(studyDate, intervals[0]);
    const minDate = date < tomorrow ? tomorrow : date;
    return minDate < today() ? today() : minDate;
  }
  return tomorrow < today() ? today() : tomorrow;
}
