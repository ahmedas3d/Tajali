import 'package:hive_flutter/hive_flutter.dart';

part 'ayah_model.g.dart';

@HiveType(typeId: 13)
class AyahModel {
  AyahModel({
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.text,
    required this.juz,
    required this.page,
    this.audioUrl,
  });

  @HiveField(0)
  final int number;

  @HiveField(1)
  final int numberInSurah;

  @HiveField(2)
  final int surahNumber;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final int juz;

  @HiveField(5)
  final int page;

  @HiveField(6)
  String? audioUrl;

  factory AyahModel.fromTextJson(Map<String, dynamic> json, int surahNumber) {
    return AyahModel(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      surahNumber: surahNumber,
      text: json['text'] as String,
      juz: json['juz'] as int,
      page: json['page'] as int,
    );
  }
}
