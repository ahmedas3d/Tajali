// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasbih_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TasbihSessionModelAdapter extends TypeAdapter<TasbihSessionModel> {
  @override
  final int typeId = 15;

  @override
  TasbihSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TasbihSessionModel(
      dhikrType: fields[0] as String,
      currentCount: fields[1] as int,
      completedRounds: fields[2] as int,
      target: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TasbihSessionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dhikrType)
      ..writeByte(1)
      ..write(obj.currentCount)
      ..writeByte(2)
      ..write(obj.completedRounds)
      ..writeByte(3)
      ..write(obj.target);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbihSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
