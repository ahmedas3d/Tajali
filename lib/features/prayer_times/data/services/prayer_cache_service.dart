import 'package:hive_flutter/hive_flutter.dart';
import '../models/prayer_times_model.dart';
import 'prayer_calculation_service.dart';

class PrayerCacheService {
  static const boxName = 'prayerTimesBox';

  Box<PrayerTimesModel> get _box => Hive.box<PrayerTimesModel>(boxName);

  PrayerTimesModel? get(String cacheKey) => _box.get(cacheKey);

  Future<void> save(PrayerTimesModel model) =>
      _box.put(model.cacheKey, model);

  bool isStale(String date) {
    final today = _todayString();
    return date != today;
  }

  String buildKey(double lat, double lon, int methodId, DateTime date) =>
      PrayerCalculationService.buildKey(lat, lon, methodId, date);

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
