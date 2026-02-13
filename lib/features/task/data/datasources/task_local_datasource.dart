import 'package:hive/hive.dart';

import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAll();
  Future<TaskModel?> getById(String id);
  Future<List<TaskModel>> getByCategoryId(String categoryId);
  Future<void> save(TaskModel task);
  Future<void> delete(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> box;

  TaskLocalDataSourceImpl({required this.box});

  @override
  Future<List<TaskModel>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<TaskModel?> getById(String id) async {
    return box.get(id);
  }

  @override
  Future<List<TaskModel>> getByCategoryId(String categoryId) async {
    return box.values
        .where((task) => task.categoryId == categoryId)
        .toList();
  }

  @override
  Future<void> save(TaskModel task) async {
    await box.put(task.id, task);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
