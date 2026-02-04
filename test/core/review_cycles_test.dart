import 'package:flutter_test/flutter_test.dart';
import 'package:retrieval/core/constants/review_cycles.dart';

void main() {
  group('ReviewCycle', () {
    test('days_1_3_7 should have correct intervals', () {
      expect(ReviewCycle.days_1_3_7.intervals, [1, 3, 7]);
      expect(ReviewCycle.days_1_3_7.label, '1-3-7');
      expect(ReviewCycle.days_1_3_7.totalReviews, 3);
    });

    test('days_1_3_7_14 should have correct intervals', () {
      expect(ReviewCycle.days_1_3_7_14.intervals, [1, 3, 7, 14]);
      expect(ReviewCycle.days_1_3_7_14.label, '1-3-7-14');
      expect(ReviewCycle.days_1_3_7_14.totalReviews, 4);
    });

    test('days_1_4_7_14 should have correct intervals', () {
      expect(ReviewCycle.days_1_4_7_14.intervals, [1, 4, 7, 14]);
      expect(ReviewCycle.days_1_4_7_14.label, '1-4-7-14');
      expect(ReviewCycle.days_1_4_7_14.totalReviews, 4);
    });

    test('days_2_3_5_7 should have correct intervals', () {
      expect(ReviewCycle.days_2_3_5_7.intervals, [2, 3, 5, 7]);
      expect(ReviewCycle.days_2_3_5_7.label, '2-3-5-7');
      expect(ReviewCycle.days_2_3_5_7.totalReviews, 4);
    });

    test('getCumulativeDays should return correct cumulative days', () {
      final cycle = ReviewCycle.days_1_3_7;
      expect(cycle.getCumulativeDays(0), 1); // 1일 후
      expect(cycle.getCumulativeDays(1), 4); // 1+3 = 4일 후
      expect(cycle.getCumulativeDays(2), 11); // 1+3+7 = 11일 후
    });

    test('getIntervalDays should return correct interval days', () {
      final cycle = ReviewCycle.days_1_3_7_14;
      expect(cycle.getIntervalDays(0), 1);
      expect(cycle.getIntervalDays(1), 3);
      expect(cycle.getIntervalDays(2), 7);
      expect(cycle.getIntervalDays(3), 14);
    });

    test('getCumulativeDays should throw RangeError for invalid index', () {
      final cycle = ReviewCycle.days_1_3_7;
      expect(() => cycle.getCumulativeDays(-1), throwsRangeError);
      expect(() => cycle.getCumulativeDays(3), throwsRangeError);
    });

    test('getIntervalDays should throw RangeError for invalid index', () {
      final cycle = ReviewCycle.days_1_3_7;
      expect(() => cycle.getIntervalDays(-1), throwsRangeError);
      expect(() => cycle.getIntervalDays(5), throwsRangeError);
    });
  });
}
