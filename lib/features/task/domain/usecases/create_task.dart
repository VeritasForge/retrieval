import 'package:uuid/uuid.dart';

import '../entities/subtask.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// 태스크 생성 파라미터
class CreateTaskParams {
  final String categoryId;
  final String strategyId;
  final List<String> subtaskTitles;

  const CreateTaskParams({
    required this.categoryId,
    required this.strategyId,
    this.subtaskTitles = const [],
  });
}

/// 태스크 생성 유스케이스
class CreateTask {
  final TaskRepository repository;
  final Uuid uuid;

  CreateTask({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  Future<Task> call(CreateTaskParams params) async {
    final subtasks = params.subtaskTitles
        .where((title) => title.trim().isNotEmpty)
        .map((title) => Subtask(
              id: uuid.v4(),
              title: title.trim(),
              isCompleted: false,
            ))
        .toList();

    final task = Task(
      id: uuid.v4(),
      categoryId: params.categoryId,
      strategyId: params.strategyId,
      subtasks: subtasks,
      level: 0,
      history: const [],
      studyDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    return repository.create(task);
  }
}
