import '../entities/category.dart';

/// 카테고리 저장소 인터페이스
abstract class CategoryRepository {
  /// 모든 카테고리 조회
  Future<List<Category>> getAll();

  /// ID로 카테고리 조회
  Future<Category?> getById(String id);

  /// 카테고리 생성
  Future<Category> create(Category category);

  /// 카테고리 수정
  Future<Category> update(Category category);

  /// 카테고리 삭제
  Future<void> delete(String id);
}
