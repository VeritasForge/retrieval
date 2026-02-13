import 'package:hive/hive.dart';

import '../../domain/entities/task.dart';
import 'subtask_model.dart';

part 'task_model.g.dart';

@HiveType(typeId: 7)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String strategyId;

  @HiveField(3)
  final String? title; // deprecated, kept for Hive compat

  @HiveField(4)
  final String? source; // deprecated, kept for Hive compat

  @HiveField(5)
  final List<SubtaskModel> subtasks;

  @HiveField(6)
  final int level;

  @HiveField(7)
  final List<DateTime> history;

  @HiveField(8)
  final DateTime studyDate;

  @HiveField(9)
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.categoryId,
    required this.strategyId,
    this.title,
    this.source,
    required this.subtasks,
    required this.level,
    required this.history,
    required this.studyDate,
    required this.createdAt,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      categoryId: task.categoryId,
      strategyId: task.strategyId,
      subtasks:
          task.subtasks.map((s) => SubtaskModel.fromEntity(s)).toList(),
      level: task.level,
      history: task.history,
      studyDate: task.studyDate,
      createdAt: task.createdAt,
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      categoryId: categoryId,
      strategyId: strategyId,
      subtasks: subtasks.map((s) => s.toEntity()).toList(),
      level: level,
      history: history,
      studyDate: studyDate,
      createdAt: createdAt,
    );
  }
}
