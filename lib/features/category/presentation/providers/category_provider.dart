import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/category_local_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/add_sub_category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';

/// Hive Box Provider
final categoryBoxProvider = Provider<Box<CategoryModel>>((ref) {
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

final addSubCategoryUseCaseProvider = Provider<AddSubCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return AddSubCategory(repository: repository);
});

/// Category List State
class CategoryListNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GetCategories getCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final AddSubCategory addSubCategory;

  CategoryListNotifier({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.addSubCategory,
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

  Future<void> add(String name) async {
    try {
      await createCategory(name);
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

  Future<void> addSubCategoryToCategory(
      String categoryId, String subCategoryName) async {
    try {
      await addSubCategory(categoryId, subCategoryName);
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
    addSubCategory: ref.watch(addSubCategoryUseCaseProvider),
  );
});
