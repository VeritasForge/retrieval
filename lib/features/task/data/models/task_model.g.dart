// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 7;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      strategyId: fields[2] as String,
      title: fields[3] as String?,
      source: fields[4] as String?,
      subtasks: (fields[5] as List).cast<SubtaskModel>(),
      level: fields[6] as int,
      history: (fields[7] as List).cast<DateTime>(),
      studyDate: fields[8] as DateTime,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.strategyId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.subtasks)
      ..writeByte(6)
      ..write(obj.level)
      ..writeByte(7)
      ..write(obj.history)
      ..writeByte(8)
      ..write(obj.studyDate)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
