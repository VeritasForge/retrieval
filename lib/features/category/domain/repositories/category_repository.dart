import '../entities/category.dart';
import '../entities/sub_category.dart';

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

  /// 소분류 추가
  Future<Category> addSubCategory(String categoryId, SubCategory subCategory);

  /// 소분류 수정
  Future<Category> updateSubCategory(
      String categoryId, SubCategory subCategory);

  /// 소분류 삭제
  Future<Category> deleteSubCategory(String categoryId, String subCategoryId);
}
