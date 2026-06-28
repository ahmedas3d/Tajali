import 'package:hive_flutter/hive_flutter.dart';

part 'ayah_bookmark.g.dart';

@HiveType(typeId: 14)
class AyahBookmark {
  AyahBookmark({
    required this.surahNumber,
    required this.ayahNumberInSurah,
    required this.surahName,
    required this.ayahText,
    required this.createdAt,
  });

  @HiveField(0)
  final int surahNumber;

  @HiveField(1)
  final int ayahNumberInSurah;

  @HiveField(2)
  final String surahName;

  @HiveField(3)
  final String ayahText;

  @HiveField(4)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahBookmark &&
          surahNumber == other.surahNumber &&
          ayahNumberInSurah == other.ayahNumberInSurah;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumberInSurah);
}
