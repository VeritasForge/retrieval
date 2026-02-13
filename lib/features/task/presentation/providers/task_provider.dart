import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/task_local_datasource.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_subtask.dart';
import '../../domain/usecases/update_task.dart';

/// Hive Box Provider
final taskBoxProvider = Provider<Box<TaskModel>>((ref) {
  throw UnimplementedError('taskBoxProvider must be overridden');
});

/// DataSource Provider
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final box = ref.watch(taskBoxProvider);
  return TaskLocalDataSourceImpl(box: box);
});

/// Repository Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(localDataSource: dataSource);
});

/// UseCase Providers
final createTaskUseCaseProvider = Provider<CreateTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTask(repository: repository);
});

final getTasksUseCaseProvider = Provider<GetTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasks(repository: repository);
});

final updateTaskUseCaseProvider = Provider<UpdateTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return UpdateTask(repository: repository);
});

final deleteTaskUseCaseProvider = Provider<DeleteTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTask(repository: repository);
});

final toggleSubtaskUseCaseProvider = Provider<ToggleSubtask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return ToggleSubtask(repository: repository);
});

/// Task List State
class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final GetTasks getTasks;
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final ToggleSubtask toggleSubtask;

  TaskListNotifier({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
    required this.toggleSubtask,
  }) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Task> add(CreateTaskParams params) async {
    try {
      final task = await createTask(params);
      await load();
      return task;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> update(Task task) async {
    try {
      await updateTask(task);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String id) async {
    try {
      await deleteTask(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(String taskId, String subtaskId) async {
    try {
      await toggleSubtask(taskId, subtaskId);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskListNotifier(
    getTasks: ref.watch(getTasksUseCaseProvider),
    createTask: ref.watch(createTaskUseCaseProvider),
    updateTask: ref.watch(updateTaskUseCaseProvider),
    deleteTask: ref.watch(deleteTaskUseCaseProvider),
    toggleSubtask: ref.watch(toggleSubtaskUseCaseProvider),
  );
});
