import 'package:equatable/equatable.dart';

import 'subtask.dart';

/// 태스크 엔티티
class Task extends Equatable {
  final String id;
  final String categoryId;
  final String strategyId;
  final List<Subtask> subtasks;
  final int level;
  final List<DateTime> history;
  final DateTime studyDate;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.categoryId,
    required this.strategyId,
    required this.subtasks,
    this.level = 0,
    required this.history,
    required this.studyDate,
    required this.createdAt,
  });

  /// 모든 서브태스크 완료 여부
  bool get allSubtasksCompleted =>
      subtasks.isNotEmpty && subtasks.every((s) => s.isCompleted);

  /// 특정 서브태스크 토글
  Task toggleSubtask(String subtaskId) {
    return copyWith(
      subtasks: subtasks.map((s) {
        return s.id == subtaskId
            ? s.copyWith(isCompleted: !s.isCompleted)
            : s;
      }).toList(),
    );
  }

  /// 모든 서브태스크 리셋
  Task resetSubtasks() {
    return copyWith(
      subtasks: subtasks.map((s) => s.copyWith(isCompleted: false)).toList(),
    );
  }

  /// 레벨 증가 및 히스토리 추가
  Task advanceLevel({DateTime? completedAt}) {
    return copyWith(
      level: level + 1,
      history: [...history, completedAt ?? DateTime.now()],
    );
  }

  /// 태스크 복사 (변경 가능)
  Task copyWith({
    String? id,
    String? categoryId,
    String? strategyId,
    List<Subtask>? subtasks,
    int? level,
    List<DateTime>? history,
    DateTime? studyDate,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      strategyId: strategyId ?? this.strategyId,
      subtasks: subtasks ?? this.subtasks,
      level: level ?? this.level,
      history: history ?? this.history,
      studyDate: studyDate ?? this.studyDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        strategyId,
        subtasks,
        level,
        history,
        studyDate,
        createdAt,
      ];
}
