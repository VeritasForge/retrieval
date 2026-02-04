import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// 모든 카테고리 조회 유스케이스
class GetCategories {
  final CategoryRepository repository;

  GetCategories({required this.repository});

  Future<List<Category>> call() async {
    return repository.getAll();
  }
}
