/// 복습 주기 상수
/// 에빙하우스 망각곡선 기반 간격 반복 학습 주기
enum ReviewCycle {
  /// 1일 후, 3일 후, 7일 후
  days_1_3_7([1, 3, 7], '1-3-7'),

  /// 1일 후, 3일 후, 7일 후, 14일 후
  days_1_3_7_14([1, 3, 7, 14], '1-3-7-14'),

  /// 1일 후, 4일 후, 7일 후, 14일 후
  days_1_4_7_14([1, 4, 7, 14], '1-4-7-14'),

  /// 2일 후, 3일 후, 5일 후, 7일 후
  days_2_3_5_7([2, 3, 5, 7], '2-3-5-7');

  /// 복습 간격 (일 단위)
  final List<int> intervals;

  /// 표시 라벨
  final String label;

  const ReviewCycle(this.intervals, this.label);

  /// 총 복습 횟수
  int get totalReviews => intervals.length;

  /// 특정 순서의 복습까지 걸리는 일 수 (누적)
  int getCumulativeDays(int reviewIndex) {
    if (reviewIndex < 0 || reviewIndex >= intervals.length) {
      throw RangeError.range(reviewIndex, 0, intervals.length - 1);
    }
    return intervals.sublist(0, reviewIndex + 1).reduce((a, b) => a + b);
  }

  /// 특정 순서의 복습까지 걸리는 일 수 (개별)
  int getIntervalDays(int reviewIndex) {
    if (reviewIndex < 0 || reviewIndex >= intervals.length) {
      throw RangeError.range(reviewIndex, 0, intervals.length - 1);
    }
    return intervals[reviewIndex];
  }
}
