import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/category_local_datasource.dart';
import '../../data/models/category_model_v2.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';

/// Hive Box Provider
final categoryBoxProvider = Provider<Box<CategoryModelV2>>((ref) {
  throw UnimplementedError('categoryBoxProvider must be overridden');
});

/// DataSource Provider
final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  final box = ref.watch(categoryBoxProvider);
  return CategoryLocalDataSourceImpl(box: box);
});

/// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(localDataSource: dataSource);
});

/// UseCase Providers
final createCategoryUseCaseProvider = Provider<CreateCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CreateCategory(repository: repository);
});

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategories(repository: repository);
});

final updateCategoryUseCaseProvider = Provider<UpdateCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return UpdateCategory(repository: repository);
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return DeleteCategory(repository: repository);
});

/// Category List State
class CategoryListNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GetCategories getCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  CategoryListNotifier({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final categories = await getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(String name, String iconName, String colorHex) async {
    try {
      await createCategory(name, iconName, colorHex);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Category category) async {
    try {
      await updateCategory(category);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String id) async {
    try {
      await deleteCategory(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) return;

    final sorted = List<Category>.from(current)
      ..sort((a, b) => a.order.compareTo(b.order));

    if (newIndex > oldIndex) newIndex--;
    final item = sorted.removeAt(oldIndex);
    sorted.insert(newIndex, item);

    try {
      for (var i = 0; i < sorted.length; i++) {
        if (sorted[i].order != i) {
          await updateCategory(sorted[i].copyWith(order: i));
        }
      }
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, AsyncValue<List<Category>>>(
        (ref) {
  return CategoryListNotifier(
    getCategories: ref.watch(getCategoriesUseCaseProvider),
    createCategory: ref.watch(createCategoryUseCaseProvider),
    updateCategory: ref.watch(updateCategoryUseCaseProvider),
    deleteCategory: ref.watch(deleteCategoryUseCaseProvider),
  );
});
