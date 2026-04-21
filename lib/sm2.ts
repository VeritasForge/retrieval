/**
 * SM-2 Spaced Repetition Algorithm
 *
 * Rating scale:
 *   0 = Blackout (완전 까먹음) → quality 0
 *   1 = Hard (어려움) → quality 2
 *   2 = Good (괜찮음) → quality 4
 *   3 = Easy (쉬움) → quality 5
 */

const RATING_TO_QUALITY: Record<number, number> = {
  0: 0,
  1: 2,
  2: 4,
  3: 5,
};

const GRADUATION_THRESHOLD_DAYS = 180;

export type Sm2Input = {
  easinessFactor: number;
  interval: number;
  repetitions: number;
  rating: number;
};

export type Sm2Output = {
  easinessFactor: number;
  interval: number;
  repetitions: number;
  graduated: boolean;
};

export function calculateSm2(input: Sm2Input): Sm2Output {
  const quality = RATING_TO_QUALITY[input.rating] ?? 0;
  let { easinessFactor, interval, repetitions } = input;

  if (quality < 3) {
    repetitions = 0;
    interval = 1;
  } else {
    if (repetitions === 0) {
      interval = 1;
    } else if (repetitions === 1) {
      interval = 6;
    } else {
      interval = Math.round(interval * easinessFactor);
    }
    repetitions += 1;
  }

  easinessFactor =
    easinessFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  if (easinessFactor < 1.3) easinessFactor = 1.3;

  const graduated = interval > GRADUATION_THRESHOLD_DAYS;

  return { easinessFactor, interval, repetitions, graduated };
}

export function previewSm2(input: Omit<Sm2Input, "rating">): Record<number, number> {
  return {
    0: calculateSm2({ ...input, rating: 0 }).interval,
    1: calculateSm2({ ...input, rating: 1 }).interval,
    2: calculateSm2({ ...input, rating: 2 }).interval,
    3: calculateSm2({ ...input, rating: 3 }).interval,
  };
}
