import 'package:hive_flutter/hive_flutter.dart';

part 'surah_model.g.dart';

@HiveType(typeId: 12)
class SurahModel extends HiveObject {
  SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  @HiveField(0)
  final int number;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String englishName;

  @HiveField(3)
  final String revelationType;

  @HiveField(4)
  final int numberOfAyahs;

  String get revelationTypeAr =>
      revelationType == 'Meccan' ? 'مكية' : 'مدنية';

  factory SurahModel.fromJson(Map<String, dynamic> json) => SurahModel(
        number: json['number'] as int,
        name: json['name'] as String,
        englishName: json['englishName'] as String,
        revelationType: json['revelationType'] as String,
        numberOfAyahs: json['numberOfAyahs'] as int,
      );
}
