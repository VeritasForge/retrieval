import 'package:flutter_test/flutter_test.dart';
import 'package:retrieval/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    test('isSameDay should return true for same day', () {
      final date1 = DateTime(2024, 1, 15, 10, 30);
      final date2 = DateTime(2024, 1, 15, 22, 45);

      expect(AppDateUtils.isSameDay(date1, date2), isTrue);
    });

    test('isSameDay should return false for different days', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);

      expect(AppDateUtils.isSameDay(date1, date2), isFalse);
    });

    test('startOfDay should return midnight', () {
      final date = DateTime(2024, 1, 15, 14, 30, 45);
      final result = AppDateUtils.startOfDay(date);

      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('endOfDay should return last moment of day', () {
      final date = DateTime(2024, 1, 15, 10);
      final result = AppDateUtils.endOfDay(date);

      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
      expect(result.hour, 23);
      expect(result.minute, 59);
      expect(result.second, 59);
    });

    test('addDays should add correct number of days', () {
      final date = DateTime(2024, 1, 15);
      final result = AppDateUtils.addDays(date, 7);

      expect(result, DateTime(2024, 1, 22));
    });

    test('daysBetween should calculate correct difference', () {
      final from = DateTime(2024, 1, 15);
      final to = DateTime(2024, 1, 22);

      expect(AppDateUtils.daysBetween(from, to), 7);
    });

    test('daysBetween should return negative for past dates', () {
      final from = DateTime(2024, 1, 22);
      final to = DateTime(2024, 1, 15);

      expect(AppDateUtils.daysBetween(from, to), -7);
    });
  });
}
