import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/sub_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Category>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<Category> create(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.save(model);
    return category;
  }

  @override
  Future<Category> update(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.save(model);
    return category;
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }

  @override
  Future<Category> addSubCategory(
      String categoryId, SubCategory subCategory) async {
    final model = await localDataSource.getById(categoryId);
    if (model == null) {
      throw CategoryException('카테고리를 찾을 수 없습니다: $categoryId');
    }

    final category = model.toEntity();
    final updated = category.addSubCategory(subCategory);
    await localDataSource.save(CategoryModel.fromEntity(updated));
    return updated;
  }

  @override
  Future<Category> updateSubCategory(
      String categoryId, SubCategory subCategory) async {
    final model = await localDataSource.getById(categoryId);
    if (model == null) {
      throw CategoryException('카테고리를 찾을 수 없습니다: $categoryId');
    }

    final category = model.toEntity();
    final updated = category.updateSubCategory(subCategory);
    await localDataSource.save(CategoryModel.fromEntity(updated));
    return updated;
  }

  @override
  Future<Category> deleteSubCategory(
      String categoryId, String subCategoryId) async {
    final model = await localDataSource.getById(categoryId);
    if (model == null) {
      throw CategoryException('카테고리를 찾을 수 없습니다: $categoryId');
    }

    final category = model.toEntity();
    final updated = category.removeSubCategory(subCategoryId);
    await localDataSource.save(CategoryModel.fromEntity(updated));
    return updated;
  }
}
