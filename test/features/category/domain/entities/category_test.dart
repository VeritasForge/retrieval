import 'package:flutter_test/flutter_test.dart';
import 'package:retrieval/features/category/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('create should create a new category with iconName and colorHex', () {
      final category = Category.create(
        id: 'test-id',
        name: '알고리즘',
        iconName: 'code',
        colorHex: '6366F1',
      );

      expect(category.id, 'test-id');
      expect(category.name, '알고리즘');
      expect(category.iconName, 'code');
      expect(category.colorHex, '6366F1');
      expect(category.createdAt, isNotNull);
    });

    test('copyWith should create a copy with modified fields', () {
      final category = Category.create(
        id: 'cat-1',
        name: '알고리즘',
        iconName: 'code',
        colorHex: '6366F1',
      );

      final updated = category.copyWith(name: '수학');

      expect(updated.id, 'cat-1');
      expect(updated.name, '수학');
      expect(updated.iconName, 'code');
      expect(updated.colorHex, '6366F1');
    });

    test('equality should work correctly', () {
      final now = DateTime.now();
      final cat1 = Category(
        id: 'cat-1',
        name: '알고리즘',
        iconName: 'code',
        colorHex: '6366F1',
        createdAt: now,
      );
      final cat2 = Category(
        id: 'cat-1',
        name: '알고리즘',
        iconName: 'code',
        colorHex: '6366F1',
        createdAt: now,
      );

      expect(cat1, equals(cat2));
    });
  });
}
