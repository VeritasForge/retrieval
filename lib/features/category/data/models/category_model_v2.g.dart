// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model_v2.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryModelV2Adapter extends TypeAdapter<CategoryModelV2> {
  @override
  final int typeId = 4;

  @override
  CategoryModelV2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModelV2(
      id: fields[0] as String,
      name: fields[1] as String,
      iconName: fields[2] as String,
      colorHex: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isDefault: fields[5] == null ? false : fields[5] as bool,
      order: fields[6] == null ? 0 : fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModelV2 obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconName)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isDefault)
      ..writeByte(6)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelV2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
