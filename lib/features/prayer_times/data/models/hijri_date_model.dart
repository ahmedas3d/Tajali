import 'package:hive_flutter/hive_flutter.dart';

part 'hijri_date_model.g.dart';

@HiveType(typeId: 11)
class HijriDateModel extends HiveObject {
  HijriDateModel({
    required this.gregorianDate,
    required this.day,
    required this.monthAr,
    required this.year,
    required this.readable,
  });

  @HiveField(0)
  final String gregorianDate;

  @HiveField(1)
  final int day;

  @HiveField(2)
  final String monthAr;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final String readable;
}
