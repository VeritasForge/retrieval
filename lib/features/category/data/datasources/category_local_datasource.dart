import 'package:hive/hive.dart';

import '../models/category_model_v2.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModelV2>> getAll();
  Future<CategoryModelV2?> getById(String id);
  Future<void> save(CategoryModelV2 category);
  Future<void> delete(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box<CategoryModelV2> box;

  CategoryLocalDataSourceImpl({required this.box});

  @override
  Future<List<CategoryModelV2>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<CategoryModelV2?> getById(String id) async {
    return box.get(id);
  }

  @override
  Future<void> save(CategoryModelV2 category) async {
    await box.put(category.id, category);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
