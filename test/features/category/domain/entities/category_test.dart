import 'package:flutter_test/flutter_test.dart';
import 'package:retrieval/features/category/domain/entities/category.dart';
import 'package:retrieval/features/category/domain/entities/sub_category.dart';

void main() {
  group('Category', () {
    test('create should create a new category with empty subCategories', () {
      final category = Category.create(
        id: 'test-id',
        name: '알고리즘',
      );

      expect(category.id, 'test-id');
      expect(category.name, '알고리즘');
      expect(category.subCategories, isEmpty);
      expect(category.createdAt, isNotNull);
    });

    test('addSubCategory should add a sub category', () {
      final category = Category.create(
        id: 'cat-1',
        name: '알고리즘',
      );

      final subCategory = SubCategory.create(
        id: 'sub-1',
        categoryId: 'cat-1',
        name: 'leetcode',
      );

      final updated = category.addSubCategory(subCategory);

      expect(updated.subCategories.length, 1);
      expect(updated.subCategories.first.name, 'leetcode');
    });

    test('removeSubCategory should remove a sub category', () {
      final subCategory = SubCategory.create(
        id: 'sub-1',
        categoryId: 'cat-1',
        name: 'leetcode',
      );

      final category = Category(
        id: 'cat-1',
        name: '알고리즘',
        subCategories: [subCategory],
        createdAt: DateTime.now(),
      );

      final updated = category.removeSubCategory('sub-1');

      expect(updated.subCategories, isEmpty);
    });

    test('updateSubCategory should update a sub category', () {
      final subCategory = SubCategory.create(
        id: 'sub-1',
        categoryId: 'cat-1',
        name: 'leetcode',
      );

      final category = Category(
        id: 'cat-1',
        name: '알고리즘',
        subCategories: [subCategory],
        createdAt: DateTime.now(),
      );

      final updatedSub = subCategory.copyWith(name: 'codewars');
      final updated = category.updateSubCategory(updatedSub);

      expect(updated.subCategories.first.name, 'codewars');
    });

    test('copyWith should create a copy with modified fields', () {
      final category = Category.create(
        id: 'cat-1',
        name: '알고리즘',
      );

      final updated = category.copyWith(name: '수학');

      expect(updated.id, 'cat-1');
      expect(updated.name, '수학');
    });

    test('equality should work correctly', () {
      final now = DateTime.now();
      final cat1 = Category(
        id: 'cat-1',
        name: '알고리즘',
        subCategories: const [],
        createdAt: now,
      );
      final cat2 = Category(
        id: 'cat-1',
        name: '알고리즘',
        subCategories: const [],
        createdAt: now,
      );

      expect(cat1, equals(cat2));
    });
  });
}
