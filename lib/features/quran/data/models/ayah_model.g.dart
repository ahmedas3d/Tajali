// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AyahModelAdapter extends TypeAdapter<AyahModel> {
  @override
  final int typeId = 13;

  @override
  AyahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AyahModel(
      number: fields[0] as int,
      numberInSurah: fields[1] as int,
      surahNumber: fields[2] as int,
      text: fields[3] as String,
      juz: fields[4] as int,
      page: fields[5] as int,
      audioUrl: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AyahModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.numberInSurah)
      ..writeByte(2)
      ..write(obj.surahNumber)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.juz)
      ..writeByte(5)
      ..write(obj.page)
      ..writeByte(6)
      ..write(obj.audioUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
