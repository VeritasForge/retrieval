import '../entities/task.dart';

/// 태스크 저장소 인터페이스
abstract class TaskRepository {
  /// 모든 태스크 조회
  Future<List<Task>> getAll();

  /// ID로 태스크 조회
  Future<Task?> getById(String id);

  /// 카테고리별 태스크 조회
  Future<List<Task>> getByCategoryId(String categoryId);

  /// 태스크 생성
  Future<Task> create(Task task);

  /// 태스크 수정
  Future<Task> update(Task task);

  /// 태스크 삭제
  Future<void> delete(String id);
}
