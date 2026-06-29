import 'package:adhan/adhan.dart';
import '../models/prayer_times_model.dart';
import '../../../../core/utils/helpers.dart';

class PrayerCalculationService {
  static const _methods = <int, CalculationMethod>{
    0: CalculationMethod.egyptian,
    1: CalculationMethod.muslim_world_league,
    2: CalculationMethod.umm_al_qura,
    3: CalculationMethod.north_america,
    4: CalculationMethod.karachi,
  };

  PrayerTimesModel calculate({
    required double latitude,
    required double longitude,
    required int methodId,
    required DateTime date,
    Madhab madhab = Madhab.shafi,
  }) {
    final coords = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date);
    final method = _methods[methodId] ?? CalculationMethod.egyptian;
    final params = method.getParameters();
    params.madhab = madhab;

    final times = PrayerTimes(coords, dateComponents, params);

    final fajrDt = times.fajr;
    final imsakDt = fajrDt.subtract(const Duration(minutes: 10));

    return PrayerTimesModel(
      cacheKey: buildKey(latitude, longitude, methodId, date),
      date: _dateString(date),
      latitude: latitude,
      longitude: longitude,
      methodId: methodId,
      fajr: TimeFormatter.toArabic12h(fajrDt),
      sunrise: TimeFormatter.toArabic12h(times.sunrise),
      dhuhr: TimeFormatter.toArabic12h(times.dhuhr),
      asr: TimeFormatter.toArabic12h(times.asr),
      maghrib: TimeFormatter.toArabic12h(times.maghrib),
      isha: TimeFormatter.toArabic12h(times.isha),
      imsak: TimeFormatter.toArabic12h(imsakDt),
      fetchedAt: DateTime.now(),
    );
  }

  /// Returns the raw [PrayerTimes] adhan object for next-prayer derivation.
  PrayerTimes rawTimes({
    required double latitude,
    required double longitude,
    required int methodId,
    required DateTime date,
    Madhab madhab = Madhab.shafi,
  }) {
    final coords = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date);
    final method = _methods[methodId] ?? CalculationMethod.egyptian;
    final params = method.getParameters();
    params.madhab = madhab;
    return PrayerTimes(coords, dateComponents, params);
  }

  static String buildKey(double lat, double lon, int methodId, DateTime date) {
    final latS = lat.toStringAsFixed(4);
    final lonS = lon.toStringAsFixed(4);
    return '${_dateString(date)}_${latS}_${lonS}_$methodId';
  }

  static String _dateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
