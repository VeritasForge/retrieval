import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model_v2.dart';

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
    final model = CategoryModelV2.fromEntity(category);
    await localDataSource.save(model);
    return category;
  }

  @override
  Future<Category> update(Category category) async {
    final model = CategoryModelV2.fromEntity(category);
    await localDataSource.save(model);
    return category;
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }
}
