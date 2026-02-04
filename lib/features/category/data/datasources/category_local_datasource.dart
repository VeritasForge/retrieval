import 'package:hive/hive.dart';

import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAll();
  Future<CategoryModel?> getById(String id);
  Future<void> save(CategoryModel category);
  Future<void> delete(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box<CategoryModel> box;

  CategoryLocalDataSourceImpl({required this.box});

  @override
  Future<List<CategoryModel>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    return box.get(id);
  }

  @override
  Future<void> save(CategoryModel category) async {
    await box.put(category.id, category);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
