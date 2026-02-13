import 'package:hive/hive.dart';

import '../../domain/entities/subtask.dart';

part 'subtask_model.g.dart';

@HiveType(typeId: 6)
class SubtaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  SubtaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory SubtaskModel.fromEntity(Subtask subtask) {
    return SubtaskModel(
      id: subtask.id,
      title: subtask.title,
      isCompleted: subtask.isCompleted,
    );
  }

  Subtask toEntity() {
    return Subtask(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }
}
