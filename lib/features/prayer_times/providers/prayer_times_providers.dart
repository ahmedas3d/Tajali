import 'dart:async';
import 'package:adhan/adhan.dart' show Prayer, Madhab;
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
const _notifModeKey = 'adhan_notification_mode';
const _adhanSoundKey = 'adhan_sound_source';
const _fiqhSchoolKey = 'fiqh_school';
const _prayerNotifPrefix = 'prayer_notif_';

/// Fiqh school for Asr time calculation.
enum FiqhSchool { shafii, hanafi }

/// Persisted calculation method (0 = Egyptian default).
final calculationMethodProvider = StateProvider<int>((ref) => 0);

/// Notification mode: fullSound / silent / disabled.
final notificationModeProvider = StateProvider<AdhanNotificationMode>(
  (ref) => AdhanNotificationMode.fullSound,
);

/// Adhan sound source: makkah / egypt.
final adhanSoundProvider = StateProvider<AdhanSoundSource>(
  (ref) => AdhanSoundSource.egypt,
);

/// Fiqh school affects Asr time (shafii = shadow 1×, hanafi = shadow 2×).
final fiqhSchoolProvider = StateProvider<FiqhSchool>((ref) => FiqhSchool.shafii);

/// Per-prayer notification toggles — all ON by default.
final prayerNotifFajrProvider    = StateProvider<bool>((ref) => true);
final prayerNotifDhuhrProvider   = StateProvider<bool>((ref) => true);
final prayerNotifAsrProvider     = StateProvider<bool>((ref) => true);
final prayerNotifMaghribProvider = StateProvider<bool>((ref) => true);
final prayerNotifIshaProvider    = StateProvider<bool>((ref) => true);

/// Selected city — defaults to Cairo; the user can change it from the prayer
/// times screen. GPS is never used.
const _defaultCity = ManualCityEntry(
  nameAr: 'القاهرة',
  latitude: 30.0444,
  longitude: 31.2357,
);

final manualCityProvider =
    StateProvider<ManualCityEntry?>((ref) => _defaultCity);

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
  final school = ref.watch(fiqhSchoolProvider);
  final position = await ref.watch(locationProvider.future);

  final now = DateTime.now();
  final key = PrayerCalculationService.buildKey(
      position.latitude, position.longitude, method, now);

  final madhab = school == FiqhSchool.hanafi ? Madhab.hanafi : Madhab.shafi;

  final cached = _cacheService.get(key);
  if (cached != null && !_cacheService.isStale(cached.date)) {
    // Still recalculate if madhab changed (cache key doesn't include madhab).
    final recalc = _calcService.calculate(
      latitude: position.latitude,
      longitude: position.longitude,
      methodId: method,
      date: now,
      madhab: madhab,
    );
    return recalc;
  }

  final model = _calcService.calculate(
    latitude: position.latitude,
    longitude: position.longitude,
    methodId: method,
    date: now,
    madhab: madhab,
  );
  await _cacheService.save(model);
  return model;
});

/// Today's Hijri date — fetched from AlAdhan API, cached in Hive.
final hijriDateProvider = FutureProvider<HijriDateModel>((ref) async {
  return _hijriService.getHijriDate(DateTime.now());
});

/// Qiyam al-Layl time = last third of the night between Isha and next Fajr.
/// Calculated locally: Isha + (Fajr_nextDay − Isha) × 2/3.
final qiyamTimeProvider = FutureProvider<DateTime?>((ref) async {
  final model = await ref.watch(prayerTimesProvider.future);
  final now = DateTime.now();

  final todayRaw = _calcService.rawTimes(
    latitude: model.latitude,
    longitude: model.longitude,
    methodId: model.methodId,
    date: now,
  );

  final tomorrowRaw = _calcService.rawTimes(
    latitude: model.latitude,
    longitude: model.longitude,
    methodId: model.methodId,
    date: now.add(const Duration(days: 1)),
  );

  final isha = todayRaw.isha;
  final fajrNext = tomorrowRaw.fajr;

  final nightDuration = fajrNext.difference(isha);
  return isha.add(Duration(
    seconds: (nightDuration.inSeconds * 2 / 3).round(),
  ));
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

  void scheduleRefresh() => Future.microtask(() {
        ref.invalidate(prayerTimesProvider);
        ref.invalidate(currentPrayerNameProvider);
        ref.invalidate(hijriDateProvider);
      });

  // Pure synchronous stream — no await, no gaps.
  yield* Stream.periodic(const Duration(seconds: 1)).map((_) {
    final now = DateTime.now();

    // ── 10-minute elapsed window ────────────────────────────────────────
    // After a prayer time passes, show "مضى على الأذان" for up to 10 minutes
    // before switching to the next prayer countdown.
    final current = rawTimes.currentPrayer();
    if (current != Prayer.none) {
      final currentDt = rawTimes.timeForPrayer(current);
      if (currentDt != null) {
        final elapsed = now.difference(currentDt);
        if (elapsed.inMinutes < 10) {
          return NextPrayerModel(
            name: current.name,
            nameAr: _prayerNameAr(current),
            scheduledTime: _formatTime(model, current),
            remaining: Duration.zero,
            elapsed: elapsed,
          );
        }
      }
    }

    // ── Normal countdown to next prayer ────────────────────────────────
    final next = rawTimes.nextPrayer();
    final dt = rawTimes.timeForPrayer(next);

    if (dt == null) {
      // After Isha and past the 10-minute window — load tomorrow's times.
      scheduleRefresh();
      return null;
    }

    final remaining = dt.difference(now);
    if (remaining.isNegative) {
      // Transient gap at transition — should be subsumed by the elapsed
      // window above, but guard here just in case.
      scheduleRefresh();
      return null;
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

/// Watches prayer times, per-prayer toggles, fiqh school, and sound source,
/// then reschedules adhan notifications for today + tomorrow on every change.
final adhanSchedulerProvider = Provider<void>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  final qiyamAsync = ref.watch(qiyamTimeProvider);
  final mode      = ref.watch(notificationModeProvider);
  final sound     = ref.watch(adhanSoundProvider);
  final school    = ref.watch(fiqhSchoolProvider);
  final fajrOn    = ref.watch(prayerNotifFajrProvider);
  final dhuhrOn   = ref.watch(prayerNotifDhuhrProvider);
  final asrOn     = ref.watch(prayerNotifAsrProvider);
  final maghribOn = ref.watch(prayerNotifMaghribProvider);
  final ishaOn    = ref.watch(prayerNotifIshaProvider);

  timesAsync.whenData((model) {
    final madhab = school == FiqhSchool.hanafi ? Madhab.hanafi : Madhab.shafi;
    final now = DateTime.now();

    final rawToday = _calcService.rawTimes(
      latitude: model.latitude,
      longitude: model.longitude,
      methodId: model.methodId,
      date: now,
      madhab: madhab,
    );
    final entriesToday = AdhanNotificationService.buildEntries(
      fajr:    fajrOn    ? rawToday.fajr    : null,
      sunrise: rawToday.sunrise,
      dhuhr:   dhuhrOn   ? rawToday.dhuhr   : null,
      asr:     asrOn     ? rawToday.asr     : null,
      maghrib: maghribOn ? rawToday.maghrib : null,
      isha:    ishaOn    ? rawToday.isha    : null,
      qiyam:   qiyamAsync.valueOrNull,
      dayOffset: 0,
    );

    final rawTomorrow = _calcService.rawTimes(
      latitude: model.latitude,
      longitude: model.longitude,
      methodId: model.methodId,
      date: now.add(const Duration(days: 1)),
      madhab: madhab,
    );
    final entriesTomorrow = AdhanNotificationService.buildEntries(
      fajr:    fajrOn    ? rawTomorrow.fajr    : null,
      sunrise: rawTomorrow.sunrise,
      dhuhr:   dhuhrOn   ? rawTomorrow.dhuhr   : null,
      asr:     asrOn     ? rawTomorrow.asr     : null,
      maghrib: maghribOn ? rawTomorrow.maghrib : null,
      isha:    ishaOn    ? rawTomorrow.isha    : null,
      qiyam:   null,
      dayOffset: 1,
    );

    AdhanNotificationService.schedulePrayerNotifications(
      [...entriesToday, ...entriesTomorrow],
      mode,
      source: sound,
    );
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

Future<ManualCityEntry> loadSavedCity() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_cityNameKey);
  final lat = prefs.getDouble(_cityLatKey);
  final lon = prefs.getDouble(_cityLonKey);
  if (name == null || lat == null || lon == null) return _defaultCity;
  return ManualCityEntry(nameAr: name, latitude: lat, longitude: lon);
}

Future<void> saveCity(ManualCityEntry city) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_cityNameKey, city.nameAr);
  await prefs.setDouble(_cityLatKey, city.latitude);
  await prefs.setDouble(_cityLonKey, city.longitude);
}

Future<AdhanNotificationMode> loadSavedNotificationMode() async {
  final prefs = await SharedPreferences.getInstance();
  final idx = prefs.getInt(_notifModeKey) ?? 0;
  return AdhanNotificationMode.values[idx.clamp(0, 2)];
}

Future<void> saveNotificationMode(AdhanNotificationMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_notifModeKey, mode.index);
}

Future<AdhanSoundSource> loadSavedAdhanSound() async {
  final prefs = await SharedPreferences.getInstance();
  final idx = prefs.getInt(_adhanSoundKey) ?? AdhanSoundSource.egypt.index;
  return AdhanSoundSource.values[idx.clamp(0, AdhanSoundSource.values.length - 1)];
}

Future<void> saveAdhanSound(AdhanSoundSource source) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_adhanSoundKey, source.index);
}

Future<FiqhSchool> loadSavedFiqhSchool() async {
  final prefs = await SharedPreferences.getInstance();
  final idx = prefs.getInt(_fiqhSchoolKey) ?? 0;
  return FiqhSchool.values[idx.clamp(0, FiqhSchool.values.length - 1)];
}

Future<void> saveFiqhSchool(FiqhSchool school) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_fiqhSchoolKey, school.index);
}

Future<bool> loadSavedPrayerNotif(String prayerKey) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('$_prayerNotifPrefix$prayerKey') ?? true;
}

Future<void> savePrayerNotif(String prayerKey, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('$_prayerNotifPrefix$prayerKey', value);
}
