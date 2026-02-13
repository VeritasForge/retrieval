import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// 태스크 수정 유스케이스
class UpdateTask {
  final TaskRepository repository;

  UpdateTask({required this.repository});

  Future<Task> call(Task task) async {
    return repository.update(task);
  }
}
