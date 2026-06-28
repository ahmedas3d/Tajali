// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_bookmark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AyahBookmarkAdapter extends TypeAdapter<AyahBookmark> {
  @override
  final int typeId = 14;

  @override
  AyahBookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AyahBookmark(
      surahNumber: fields[0] as int,
      ayahNumberInSurah: fields[1] as int,
      surahName: fields[2] as String,
      ayahText: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AyahBookmark obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.surahNumber)
      ..writeByte(1)
      ..write(obj.ayahNumberInSurah)
      ..writeByte(2)
      ..write(obj.surahName)
      ..writeByte(3)
      ..write(obj.ayahText)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahBookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
