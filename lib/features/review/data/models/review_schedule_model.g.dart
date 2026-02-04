// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewScheduleModelAdapter extends TypeAdapter<ReviewScheduleModel> {
  @override
  final int typeId = 3;

  @override
  ReviewScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewScheduleModel(
      id: fields[0] as String,
      studyItemId: fields[1] as String,
      scheduledDate: fields[2] as DateTime,
      reviewOrder: fields[3] as int,
      isCompleted: fields[4] as bool,
      completedAt: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewScheduleModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studyItemId)
      ..writeByte(2)
      ..write(obj.scheduledDate)
      ..writeByte(3)
      ..write(obj.reviewOrder)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
