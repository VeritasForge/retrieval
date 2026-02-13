// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strategy_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StrategyModelAdapter extends TypeAdapter<StrategyModel> {
  @override
  final int typeId = 5;

  @override
  StrategyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StrategyModel(
      id: fields[0] as String,
      name: fields[1] as String,
      intervals: (fields[2] as List).cast<int>(),
      isDefault: fields[3] as bool,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StrategyModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.intervals)
      ..writeByte(3)
      ..write(obj.isDefault)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrategyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
