// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimesModelAdapter extends TypeAdapter<PrayerTimesModel> {
  @override
  final int typeId = 10;

  @override
  PrayerTimesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimesModel(
      cacheKey: fields[0] as String,
      date: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      methodId: fields[4] as int,
      fajr: fields[5] as String,
      sunrise: fields[6] as String,
      dhuhr: fields[7] as String,
      asr: fields[8] as String,
      maghrib: fields[9] as String,
      isha: fields[10] as String,
      imsak: fields[11] as String,
      fetchedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimesModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.cacheKey)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.methodId)
      ..writeByte(5)
      ..write(obj.fajr)
      ..writeByte(6)
      ..write(obj.sunrise)
      ..writeByte(7)
      ..write(obj.dhuhr)
      ..writeByte(8)
      ..write(obj.asr)
      ..writeByte(9)
      ..write(obj.maghrib)
      ..writeByte(10)
      ..write(obj.isha)
      ..writeByte(11)
      ..write(obj.imsak)
      ..writeByte(12)
      ..write(obj.fetchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
