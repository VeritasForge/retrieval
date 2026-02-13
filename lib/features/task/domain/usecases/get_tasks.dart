import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// 모든 태스크 조회 유스케이스
class GetTasks {
  final TaskRepository repository;

  GetTasks({required this.repository});

  Future<List<Task>> call() async {
    return repository.getAll();
  }
}
