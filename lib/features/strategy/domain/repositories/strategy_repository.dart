import '../entities/strategy.dart';

/// 전략 저장소 인터페이스
abstract class StrategyRepository {
  /// 모든 전략 조회
  Future<List<Strategy>> getAll();

  /// ID로 전략 조회
  Future<Strategy?> getById(String id);

  /// 전략 생성
  Future<Strategy> create(Strategy strategy);

  /// 전략 수정
  Future<Strategy> update(Strategy strategy);

  /// 전략 삭제
  Future<void> delete(String id);
}
