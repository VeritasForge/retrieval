/// 앱 전역 예외 클래스
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// 카테고리 관련 예외
class CategoryException extends AppException {
  const CategoryException(super.message, {super.code});
}

/// 학습 항목 관련 예외
class StudyItemException extends AppException {
  const StudyItemException(super.message, {super.code});
}

/// 복습 일정 관련 예외
class ReviewScheduleException extends AppException {
  const ReviewScheduleException(super.message, {super.code});
}

/// 데이터 저장소 관련 예외
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// 유효성 검증 예외
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}
