import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrieval/core/exceptions/app_exceptions.dart';
import 'package:retrieval/features/category/domain/entities/category.dart';
import 'package:retrieval/features/category/domain/repositories/category_repository.dart';
import 'package:retrieval/features/category/domain/usecases/create_category.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late CreateCategory useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = CreateCategory(repository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(Category.create(
      id: 'fallback',
      name: 'fallback',
      iconName: 'code',
      colorHex: '000000',
    ));
  });

  group('CreateCategory', () {
    test('should create a category with trimmed name', () async {
      when(() => mockRepository.create(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Category,
      );

      final result = await useCase('  알고리즘  ', 'code', '6366F1');

      expect(result.name, '알고리즘');
      expect(result.iconName, 'code');
      expect(result.colorHex, '6366F1');
      verify(() => mockRepository.create(any())).called(1);
    });

    test('should throw ValidationException for empty name', () async {
      expect(
        () => useCase('', 'code', '6366F1'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ValidationException for whitespace-only name',
        () async {
      expect(
        () => useCase('   ', 'code', '6366F1'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should generate a unique id for the category', () async {
      when(() => mockRepository.create(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Category,
      );

      final result1 = await useCase('알고리즘', 'code', '6366F1');
      final result2 = await useCase('수학', 'school', 'F59E0B');

      expect(result1.id, isNotEmpty);
      expect(result2.id, isNotEmpty);
      expect(result1.id, isNot(equals(result2.id)));
    });
  });
}
