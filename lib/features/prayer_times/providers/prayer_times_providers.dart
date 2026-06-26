import 'dart:async';
import 'package:adhan/adhan.dart' show Prayer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/hijri_date_model.dart';
import '../data/models/prayer_times_model.dart';
import '../data/services/hijri_date_service.dart';
import '../data/services/prayer_cache_service.dart';
import '../data/services/prayer_calculation_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/adhan_notification_service.dart';

// ── Manual city entry ────────────────────────────────────────────────────────

class ManualCityEntry {
  const ManualCityEntry({
    required this.nameAr,
    required this.latitude,
    required this.longitude,
  });
  final String nameAr;
  final double latitude;
  final double longitude;
}

// ── Calculation method config ────────────────────────────────────────────────

class CalculationMethodConfig {
  const CalculationMethodConfig({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });
  final int id;
  final String nameAr;
  final String nameEn;

  static const all = <CalculationMethodConfig>[
    CalculationMethodConfig(
        id: 0, nameAr: 'الهيئة المصرية العامة للمساحة', nameEn: 'Egyptian'),
    CalculationMethodConfig(
        id: 1, nameAr: 'رابطة العالم الإسلامي', nameEn: 'Muslim World League'),
    CalculationMethodConfig(
        id: 2, nameAr: 'أم القرى', nameEn: 'Umm Al-Qura'),
    CalculationMethodConfig(
        id: 3,
        nameAr: 'الجمعية الإسلامية بأمريكا الشمالية',
        nameEn: 'ISNA'),
    CalculationMethodConfig(
        id: 4,
        nameAr: 'جامعة العلوم الإسلامية — كراتشي',
        nameEn: 'Karachi'),
  ];
}

// ── Next prayer model ────────────────────────────────────────────────────────

class NextPrayerModel {
  const NextPrayerModel({
    required this.name,
    required this.nameAr,
    required this.scheduledTime,
    required this.remaining,
    this.elapsed,
  });
  final String name;
  final String nameAr;
  final String scheduledTime;
  final Duration remaining;
  // Non-null = we're in "elapsed since adhan" mode (prayer just passed).
  final Duration? elapsed;
}

// ── Singletons ───────────────────────────────────────────────────────────────

final _locationService = LocationService();
final _calcService = PrayerCalculationService();
final _cacheService = PrayerCacheService();
final _hijriService = HijriDateService();

// ── Providers ────────────────────────────────────────────────────────────────

const _methodKey = 'prayer_method_id';
const _cityNameKey = 'selected_city_name';
const _cityLatKey = 'selected_city_lat';
const _cityLonKey = 'selected_city_lon';

/// Persisted calculation method (0 = Egyptian default).
final calculationMethodProvider = StateProvider<int>((ref) => 0);

/// Manually selected city; null means GPS mode.
final manualCityProvider = StateProvider<ManualCityEntry?>((ref) => null);

/// Resolves GPS position (or throws [LocationException]).
final locationProvider = FutureProvider<Position>((ref) async {
  final manual = ref.watch(manualCityProvider);
  if (manual != null) {
    // Return a synthetic Position when a manual city is selected.
    return Future.value(
      Position(
        latitude: manual.latitude,
        longitude: manual.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
    );
  }
  return _locationService.getCurrentPosition();
});

/// Today's prayer times — checks cache first, then calculates locally.
final prayerTimesProvider = FutureProvider<PrayerTimesModel>((ref) async {
  final method = ref.watch(calculationMethodProvider);
  final position = await ref.watch(locationProvider.future);

  final now = DateTime.now();
  final key = PrayerCalculationService.buildKey(
      position.latitude, position.longitude, method, now);

  final cached = _cacheService.get(key);
  if (cached != null && !_cacheService.isStale(cached.date)) {
    return cached;
  }

  final model = _calcService.calculate(
    latitude: position.latitude,
    longitude: position.longitude,
    methodId: method,
    date: now,
  );
  await _cacheService.save(model);
  return model;
});

/// Today's Hijri date — fetched from AlAdhan API, cached in Hive.
final hijriDateProvider = FutureProvider<HijriDateModel>((ref) async {
  return _hijriService.getHijriDate(DateTime.now());
});

/// Name key of the currently active prayer (e.g. 'asr'), or null if none.
final currentPrayerNameProvider = FutureProvider<String?>((ref) async {
  final model = await ref.watch(prayerTimesProvider.future);
  final now = DateTime.now();
  final raw = _calcService.rawTimes(
    latitude: model.latitude,
    longitude: model.longitude,
    methodId: model.methodId,
    date: now,
  );
  final current = raw.currentPrayer();
  if (current == Prayer.none) return null;
  return current.name.toLowerCase();
});

/// Progress (0.0–1.0) between the previous prayer and the next prayer.
final prayerProgressProvider = FutureProvider<double>((ref) async {
  final model = await ref.watch(prayerTimesProvider.future);
  final now = DateTime.now();
  final raw = _calcService.rawTimes(
    latitude: model.latitude,
    longitude: model.longitude,
    methodId: model.methodId,
    date: now,
  );
  final current = raw.currentPrayer();
  final next = raw.nextPrayer();
  final currentDt = raw.timeForPrayer(current);
  final nextDt = raw.timeForPrayer(next);
  if (currentDt == null || nextDt == null) return 0.0;
  final total = nextDt.difference(currentDt).inSeconds;
  final elapsed = now.difference(currentDt).inSeconds;
  if (total <= 0) return 0.0;
  return (elapsed / total).clamp(0.0, 1.0);
});

/// Live next-prayer model, ticking every second.
///
/// Uses a synchronous [Stream.periodic] so nothing can block or pause
/// the countdown. Prayer-times refresh happens only when a prayer passes
/// (via a microtask) rather than on a fixed interval, so the stream never
/// has an async gap that would freeze or reset the display.
final nextPrayerProvider = StreamProvider<NextPrayerModel>((ref) async* {
  // Rebuild this stream when prayer times load or change (method / city).
  final timesAsync = ref.watch(prayerTimesProvider);

  // Propagate hard errors so callers show "—" instead of a stuck skeleton.
  if (timesAsync.hasError && !timesAsync.hasValue) throw timesAsync.error!;

  final model = timesAsync.valueOrNull;
  if (model == null) return; // Initial load not yet complete.

  // Build rawTimes once for this model — reused every tick (cheap arithmetic).
  final rawTimes = _calcService.rawTimes(
    latitude: model.latitude,
    longitude: model.longitude,
    methodId: model.methodId,
    date: DateTime.now(),
  );

  // Pure synchronous stream — no await, no gaps.
  yield* Stream.periodic(const Duration(seconds: 1)).map((_) {
    final now = DateTime.now();
    final next = rawTimes.nextPrayer();
    final dt = rawTimes.timeForPrayer(next);

    // Helper: build an elapsed model using the current (just-completed) prayer.
    NextPrayerModel? buildElapsedModel() {
      final current = rawTimes.currentPrayer();
      if (current == Prayer.none) return null;
      final currentDt = rawTimes.timeForPrayer(current);
      if (currentDt == null) return null;
      return NextPrayerModel(
        name: current.name,
        nameAr: _prayerNameAr(current),
        scheduledTime: _formatTime(model, current),
        remaining: Duration.zero,
        elapsed: now.difference(currentDt),
      );
    }

    void scheduleRefresh() => Future.microtask(() {
          ref.invalidate(prayerTimesProvider);
          ref.invalidate(currentPrayerNameProvider);
          ref.invalidate(hijriDateProvider);
        });

    // No upcoming prayer today (after Isha) — must schedule invalidation
    // or the stream will silently emit null forever.
    if (dt == null) {
      scheduleRefresh();
      return buildElapsedModel();
    }

    final remaining = dt.difference(now);
    if (remaining.isNegative) {
      // Prayer just passed — refresh times in a microtask so the stream
      // tick completes synchronously first (no gap on the current frame).
      scheduleRefresh();
      return buildElapsedModel();
    }

    return NextPrayerModel(
      name: next.name,
      nameAr: _prayerNameAr(next),
      scheduledTime: _formatTime(model, next),
      remaining: remaining,
    );
  }).where((m) => m != null).cast<NextPrayerModel>();
});

// ── Helpers ──────────────────────────────────────────────────────────────────

String _prayerNameAr(Prayer prayer) {
  switch (prayer) {
    case Prayer.fajr:
      return 'الفجر';
    case Prayer.sunrise:
      return 'الشروق';
    case Prayer.dhuhr:
      return 'الظهر';
    case Prayer.asr:
      return 'العصر';
    case Prayer.maghrib:
      return 'المغرب';
    case Prayer.isha:
      return 'العشاء';
    case Prayer.none:
      return '';
  }
}

String _formatTime(PrayerTimesModel m, Prayer prayer) {
  switch (prayer) {
    case Prayer.fajr:
      return m.fajr;
    case Prayer.sunrise:
      return m.sunrise;
    case Prayer.dhuhr:
      return m.dhuhr;
    case Prayer.asr:
      return m.asr;
    case Prayer.maghrib:
      return m.maghrib;
    case Prayer.isha:
      return m.isha;
    case Prayer.none:
      return '';
  }
}

// ── Adhan notification scheduler ────────────────────────────────────────────

/// Watches [prayerTimesProvider] and reschedules adhan notifications
/// whenever prayer times load or change (city / method switch).
final adhanSchedulerProvider = Provider<void>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  timesAsync.whenData((model) {
    final raw = _calcService.rawTimes(
      latitude: model.latitude,
      longitude: model.longitude,
      methodId: model.methodId,
      date: DateTime.now(),
    );
    final entries = AdhanNotificationService.buildEntries(
      fajr:    raw.fajr,
      sunrise: raw.sunrise,
      dhuhr:   raw.dhuhr,
      asr:     raw.asr,
      maghrib: raw.maghrib,
      isha:    raw.isha,
    );
    AdhanNotificationService.schedulePrayerNotifications(entries);
  });
});

// ── Init helpers (called from app.dart) ─────────────────────────────────────

Future<int> loadSavedMethodId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_methodKey) ?? 0;
}

Future<void> saveMethodId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_methodKey, id);
}

Future<ManualCityEntry?> loadSavedCity() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_cityNameKey);
  final lat = prefs.getDouble(_cityLatKey);
  final lon = prefs.getDouble(_cityLonKey);
  if (name == null || lat == null || lon == null) return null;
  return ManualCityEntry(nameAr: name, latitude: lat, longitude: lon);
}

Future<void> saveCity(ManualCityEntry city) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_cityNameKey, city.nameAr);
  await prefs.setDouble(_cityLatKey, city.latitude);
  await prefs.setDouble(_cityLonKey, city.longitude);
}
