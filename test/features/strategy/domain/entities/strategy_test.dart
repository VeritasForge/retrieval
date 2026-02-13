import 'package:flutter_test/flutter_test.dart';
import 'package:retrieval/features/strategy/domain/entities/strategy.dart';

void main() {
  group('Strategy', () {
    test('should create a strategy with correct fields', () {
      final now = DateTime(2024, 1, 15);
      final strategy = Strategy(
        id: 'strat-1',
        name: '에빙하우스 (표준)',
        intervals: const [1, 3, 7, 14, 30],
        isDefault: true,
        createdAt: now,
      );

      expect(strategy.id, 'strat-1');
      expect(strategy.name, '에빙하우스 (표준)');
      expect(strategy.intervals, [1, 3, 7, 14, 30]);
      expect(strategy.isDefault, isTrue);
      expect(strategy.createdAt, now);
    });

    test('equality should work correctly', () {
      final now = DateTime(2024, 1, 15);
      final strategy1 = Strategy(
        id: 'strat-1',
        name: '에빙하우스 (표준)',
        intervals: const [1, 3, 7, 14, 30],
        isDefault: true,
        createdAt: now,
      );
      final strategy2 = Strategy(
        id: 'strat-1',
        name: '에빙하우스 (표준)',
        intervals: const [1, 3, 7, 14, 30],
        isDefault: true,
        createdAt: now,
      );

      expect(strategy1, equals(strategy2));
    });

    test('copyWith should create a copy with modified fields', () {
      final now = DateTime(2024, 1, 15);
      final strategy = Strategy(
        id: 'strat-1',
        name: '에빙하우스 (표준)',
        intervals: const [1, 3, 7, 14, 30],
        isDefault: true,
        createdAt: now,
      );

      final updated = strategy.copyWith(name: '커스텀 전략', isDefault: false);

      expect(updated.id, 'strat-1');
      expect(updated.name, '커스텀 전략');
      expect(updated.isDefault, isFalse);
      expect(updated.intervals, [1, 3, 7, 14, 30]);
    });

    test('different strategies should not be equal', () {
      final now = DateTime(2024, 1, 15);
      final strategy1 = Strategy(
        id: 'strat-1',
        name: '에빙하우스 (표준)',
        intervals: const [1, 3, 7, 14, 30],
        isDefault: true,
        createdAt: now,
      );
      final strategy2 = Strategy(
        id: 'strat-2',
        name: '피보나치 (자연)',
        intervals: const [1, 2, 3, 5, 8, 13],
        isDefault: true,
        createdAt: now,
      );

      expect(strategy1, isNot(equals(strategy2)));
    });
  });
}
