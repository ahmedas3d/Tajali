# Contract: Riverpod Providers

**Feature**: Prayer Times (مواقيت الصلاة)  
**File location**: `lib/features/prayer_times/providers/prayer_times_providers.dart`

---

## locationProvider

```
Type:    FutureProvider<Position>
Package: geolocator
```

Resolves the device's current GPS position. Attempts a fresh fix with a 10-second timeout. On timeout or permission denial, throws a typed `LocationException` that consuming providers catch to fall back to `CachedLocationModel`.

**Consumed by**: `prayerTimesProvider`

---

## prayerTimesProvider

```
Type:    FutureProvider<PrayerTimesModel>
```

Calculates today's prayer times using the `adhan` package from the resolved location and selected method. First checks the Hive cache for a matching `cacheKey`; if found and date matches today, returns the cached model without recalculation. Otherwise calculates, persists to Hive, and returns.

**Depends on**: `locationProvider`, `calculationMethodProvider`  
**Consumed by**: `PrayerTimesScreen`, `nextPrayerProvider`

**Error states**:

| Condition | State emitted |
|---|---|
| Location unavailable, no cache | `AsyncError(LocationException)` |
| Location unavailable, cache exists | `AsyncData(cachedModel)` + banner flag |
| Hive read failure | `AsyncError(CacheException)` |

---

## nextPrayerProvider

```
Type:    StreamProvider<NextPrayerModel>
Stream:  Stream.periodic(Duration(minutes: 1))
```

Re-derives the next prayer every minute using `PrayerTimes.nextPrayer(DateTime.now())` from the `adhan` package. Emits a new `NextPrayerModel` on each tick. Also emits immediately on first subscription (no 1-minute wait).

**Depends on**: `prayerTimesProvider` (must be loaded)  
**Consumed by**: `PrayerTimesScreen` hero section, `PrayerCardWidget` (home screen)

---

## calculationMethodProvider

```
Type:    StateProvider<int>
Default: 0  (Egyptian General Authority)
```

Holds the currently active calculation method ID. Initialised from `SharedPreferences` (`prayer_method_id`) at app start. Writing to this provider triggers immediate recalculation via `prayerTimesProvider` invalidation (method is a dependency).

**Consumed by**: `prayerTimesProvider`, `SettingsScreen`

---

## hijriDateProvider

```
Type:    FutureProvider<HijriDateModel>
```

Fetches today's Hijri date from AlAdhan API (`/v1/gToH/{DD-MM-YYYY}`). Checks Hive cache first (key: today's Gregorian date string). Only makes an API call on the first open of each calendar day.

**Consumed by**: `PrayerTimesScreen` header

**Error states**: On API failure + no cache → emits `AsyncError`; UI shows empty Hijri date gracefully (non-blocking).

---

## manualCityProvider

```
Type:    StateProvider<ManualCityEntry?>
Default: null  (no manual city selected)
```

Holds the user's manually selected city. `null` means GPS mode is active. Persisted to SharedPreferences on change. When non-null, `prayerTimesProvider` uses this location instead of `locationProvider`.

**Consumed by**: `prayerTimesProvider`, `PrayerTimesScreen` (shows city name instead of coordinates)
