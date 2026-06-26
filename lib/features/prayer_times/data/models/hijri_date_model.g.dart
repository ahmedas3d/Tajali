// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hijri_date_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HijriDateModelAdapter extends TypeAdapter<HijriDateModel> {
  @override
  final int typeId = 11;

  @override
  HijriDateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HijriDateModel(
      gregorianDate: fields[0] as String,
      day: fields[1] as int,
      monthAr: fields[2] as String,
      year: fields[3] as int,
      readable: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HijriDateModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.gregorianDate)
      ..writeByte(1)
      ..write(obj.day)
      ..writeByte(2)
      ..write(obj.monthAr)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.readable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HijriDateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
