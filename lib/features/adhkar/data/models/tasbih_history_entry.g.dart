// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasbih_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TasbihHistoryEntryAdapter extends TypeAdapter<TasbihHistoryEntry> {
  @override
  final int typeId = 16;

  @override
  TasbihHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TasbihHistoryEntry(
      dhikrType: fields[0] as String,
      totalCount: fields[1] as int,
      dateISO: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TasbihHistoryEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dhikrType)
      ..writeByte(1)
      ..write(obj.totalCount)
      ..writeByte(2)
      ..write(obj.dateISO);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbihHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
