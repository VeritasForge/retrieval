/// 날짜 관련 유틸리티 함수
class AppDateUtils {
  AppDateUtils._();

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 날짜의 시작 시간 (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 날짜의 끝 시간 (23:59:59.999)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// 오늘 날짜 (시간 제외)
  static DateTime today() {
    return startOfDay(DateTime.now());
  }

  /// 특정 일수 후의 날짜
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// 두 날짜 사이의 일수 차이
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = startOfDay(from);
    final toDate = startOfDay(to);
    return toDate.difference(fromDate).inDays;
  }

  /// 날짜가 오늘인지 확인
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// 날짜가 과거인지 확인 (오늘 제외)
  static bool isPast(DateTime date) {
    return startOfDay(date).isBefore(today());
  }

  /// 날짜가 미래인지 확인 (오늘 제외)
  static bool isFuture(DateTime date) {
    return startOfDay(date).isAfter(today());
  }

  /// 날짜가 오늘 또는 과거인지 확인
  static bool isTodayOrPast(DateTime date) {
    return !isFuture(date);
  }
}
