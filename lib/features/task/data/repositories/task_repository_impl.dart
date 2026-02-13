import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Task>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task?> getById(String id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Task>> getByCategoryId(String categoryId) async {
    final models = await localDataSource.getByCategoryId(categoryId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task> create(Task task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.save(model);
    return task;
  }

  @override
  Future<Task> update(Task task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.save(model);
    return task;
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }
}
