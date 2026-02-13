import 'package:retrieval/core/exceptions/app_exceptions.dart';
import '../repositories/task_repository.dart';

/// 태스크 삭제 유스케이스
class DeleteTask {
  final TaskRepository repository;

  DeleteTask({required this.repository});

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw const ValidationException('태스크 ID는 비어있을 수 없습니다.');
    }

    return repository.delete(id);
  }
}
