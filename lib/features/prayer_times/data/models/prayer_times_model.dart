import 'package:hive_flutter/hive_flutter.dart';

part 'prayer_times_model.g.dart';

@HiveType(typeId: 10)
class PrayerTimesModel extends HiveObject {
  PrayerTimesModel({
    required this.cacheKey,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.methodId,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.fetchedAt,
  });

  @HiveField(0)
  final String cacheKey;

  @HiveField(1)
  final String date;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final int methodId;

  @HiveField(5)
  final String fajr;

  @HiveField(6)
  final String sunrise;

  @HiveField(7)
  final String dhuhr;

  @HiveField(8)
  final String asr;

  @HiveField(9)
  final String maghrib;

  @HiveField(10)
  final String isha;

  @HiveField(11)
  final String imsak;

  @HiveField(12)
  final DateTime fetchedAt;
}
