import 'package:equatable/equatable.dart';

/// 서브태스크 엔티티
class Subtask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  /// 서브태스크 복사 (변경 가능)
  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}
