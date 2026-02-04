// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyItemModelAdapter extends TypeAdapter<StudyItemModel> {
  @override
  final int typeId = 2;

  @override
  StudyItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyItemModel(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      subCategoryId: fields[2] as String?,
      content: fields[3] as String,
      isCheckbox: fields[4] as bool,
      studyDate: fields[5] as DateTime,
      reviewCycleName: fields[6] as String,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudyItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.subCategoryId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.isCheckbox)
      ..writeByte(5)
      ..write(obj.studyDate)
      ..writeByte(6)
      ..write(obj.reviewCycleName)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
