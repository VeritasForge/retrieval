import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../repositories/task_repository.dart';

/// 서브태스크 토글 유스케이스
class ToggleSubtask {
  final TaskRepository repository;

  ToggleSubtask({required this.repository});

  Future<void> call(String taskId, String subtaskId) async {
    final task = await repository.getById(taskId);
    if (task == null) {
      throw TaskException('태스크를 찾을 수 없습니다: $taskId');
    }

    final updated = task.toggleSubtask(subtaskId);
    await repository.update(updated);
  }
}
