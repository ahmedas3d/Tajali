# Implementation Plan: Prayer Times (مواقيت الصلاة)

**Branch**: `005-prayer-times` | **Date**: 2026-06-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/005-prayer-times/spec.md`

---

## Summary

Implement the Prayer Times feature for Tajali: display all 7 prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha, Imsak) calculated locally via the `adhan` package from the device's GPS coordinates, with a live countdown to the next prayer updating every minute. Show the Hijri date fetched from AlAdhan API (cached in Hive). Support 5 calculation methods selectable from a new Settings screen accessible via AppBar gear icon. Expose a reusable `PrayerCardWidget` (next prayer + countdown only) for the home screen. Full offline support via Hive caching with a "last updated" indicator when serving stale data.

---

## Technical Context

**Language/Version**: Dart 3.3 / Flutter 3.x (SDK `>=3.3.0 <4.0.0`)

**Primary Dependencies**:
- `adhan ^2.0.0+1` — offline prayer time calculation (already declared)
- `geolocator ^11.0.0` — GPS position (already declared)
- `hive_flutter ^1.1.0` — Hive local cache for `PrayerTimesModel` and `HijriDateModel` (already declared)
- `hive_generator ^2.0.1` + `build_runner ^2.4.9` — Hive adapter codegen (already declared in dev_dependencies)
- `flutter_riverpod ^2.5.1` — state management (already declared)
- `shared_preferences ^2.2.3` — method ID + manual city + cached location (already declared)
- `permission_handler ^11.3.1` — location permission check (already declared)
- `http` / `dio` — HTTP for AlAdhan Hijri API — **NEW dependency needed** (not yet in pubspec)

**Note on HTTP**: The project has no HTTP client declared yet. Add `dio: ^5.4.3` (or `http: ^1.2.1`) to `pubspec.yaml`. `dio` is preferred for its interceptors and timeout support.

**Storage**:
- Hive boxes: `prayerTimesBox` (type 10), `hijriDateBox` (type 11)
- SharedPreferences keys: `prayer_method_id`, `cached_location_lat`, `cached_location_lon`, `cached_location_ts`, `selected_city_name`, `selected_city_lat`, `selected_city_lon`

**Testing**: `flutter_test` (built-in) — unit + widget tests

**Target Platform**: Android + iOS (portrait-only, RTL Arabic)

**Performance Goals**:
- Prayer times displayed within 3 seconds on first launch (SC-001) — met easily by local `adhan` calculation (< 10 ms)
- Method switch time < 2 seconds (SC-004) — local recalculation, effectively instant
- Countdown accurate to ±1 minute (SC-002) — guaranteed by 1-minute `Stream.periodic`

**Constraints**:
- Portrait-only (enforced in `main.dart`)
- RTL Directionality (enforced in `MainNavigation`)
- All displayed times in 12-hour Arabic AM/PM format (ص / م) — clarified in session 2026-06-26
- Asr school is implicit in calculation method; no separate toggle — clarified in session 2026-06-26
- No Azan audio in this phase (Phase 7)

**Scale/Scope**: 3 new screens (PrayerTimesScreen full, SettingsScreen, city-search modal), 1 reusable card widget (PrayerCardWidget for home), 3 new Hive-backed models, 5 providers, 3 services

---

## Constitution Check

Constitution file is a blank template — no project-specific gates defined. No violations to evaluate.

---

## Project Structure

### Documentation (this feature)

```text
specs/005-prayer-times/
├── plan.md                      ← this file
├── research.md                  ← Phase 0 output
├── data-model.md                ← Phase 1 output
├── quickstart.md                ← Phase 1 output
├── contracts/
│   ├── providers.md             ← Phase 1 output
│   ├── home_card_widget.md      ← Phase 1 output
│   └── aladhan_hijri_api.md     ← Phase 1 output
└── tasks.md                     ← Phase 2 output (/speckit-tasks — not yet created)
```

### Source Code

```text
lib/
├── app/
│   └── routes.dart                                     ← MODIFY: add Settings gear icon to AppBar in MainNavigation
├── features/
│   ├── prayer_times/                                   ← EXPAND existing stub
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── prayer_times_model.dart             ← NEW (Hive @HiveType(10))
│   │   │   │   └── hijri_date_model.dart               ← NEW (Hive @HiveType(11))
│   │   │   └── services/
│   │   │       ├── prayer_calculation_service.dart     ← NEW (adhan wrapper)
│   │   │       ├── hijri_date_service.dart             ← NEW (AlAdhan API + Hive cache)
│   │   │       └── prayer_cache_service.dart           ← NEW (Hive read/write + staleness)
│   │   ├── providers/
│   │   │   └── prayer_times_providers.dart             ← NEW
│   │   └── presentation/
│   │       ├── prayer_times_screen.dart                ← REPLACE stub
│   │       └── widgets/
│   │           ├── next_prayer_hero.dart               ← NEW
│   │           ├── prayer_time_row.dart                ← NEW
│   │           └── prayer_card_widget.dart             ← NEW (home screen card)
│   └── settings/                                       ← NEW feature module
│       ├── data/
│       │   └── services/
│       │       └── settings_service.dart               ← NEW (SharedPreferences wrapper)
│       └── presentation/
│           ├── settings_screen.dart                    ← NEW
│           └── widgets/
│               └── calculation_method_tile.dart        ← NEW
├── core/
│   ├── services/
│   │   └── location_service.dart                       ← REPLACE stub with geolocator impl
│   └── utils/
│       └── helpers.dart                                ← MODIFY: add toArabic12h() formatter
└── shared/
    └── local_storage/
        └── storage_service.dart                        ← MODIFY: add readDouble(), writeDouble(), readInt(), writeInt()

assets/
└── data/
    └── cities.dart                                     ← NEW (bundled city list as Dart const — not an asset file)
    (actually: lib/core/constants/cities_data.dart)

test/
├── unit/
│   ├── prayer_calculation_service_test.dart            ← NEW
│   ├── hijri_date_service_test.dart                    ← NEW
│   ├── time_formatter_test.dart                        ← NEW
│   ├── prayer_cache_service_test.dart                  ← NEW
│   └── settings_service_test.dart                      ← NEW
└── widget/
    ├── prayer_times_screen_test.dart                   ← NEW
    ├── prayer_card_widget_test.dart                    ← NEW
    └── settings_screen_test.dart                       ← NEW
```

**Structure Decision**: Feature-first layout matching the existing pattern (`lib/features/[name]/data|providers|presentation`). The `settings` feature is introduced as its own module so future phases (Quran reciter preference, theme toggle, notification toggles) can add to `SettingsScreen` without touching the `prayer_times` module. The `adhan` package eliminates the need for a prayer-times network service — network is used only for the Hijri date (one request per day).

---

## Key Design Decisions

### 1. Offline-First via `adhan` Package

Prayer times are calculated locally — no network call, no latency, no API key. The `adhan` package handles all five required calculation methods. Network access is limited to the Hijri date endpoint (one call per day, cached in Hive).

### 2. Settings Screen Entry Point

Accessed via a `settings_outlined` icon in the AppBar of `MainNavigation`. This avoids redesigning the 5-item bottom nav while keeping Settings discoverable. The `SettingsScreen` is a `ConsumerWidget` pushed via `Navigator.push`.

### 3. Countdown via StreamProvider

`Stream.periodic(Duration(minutes: 1))` drives `nextPrayerProvider`. It emits immediately on first listen (so users don't wait up to 60 seconds for the first countdown). The `adhan` package's `PrayerTimes.nextPrayer(DateTime.now())` method returns the Prayer enum for the next prayer.

### 4. Time Formatting Utility

`TimeFormatter.toArabic12h(DateTime dt)` in `helpers.dart` converts any `DateTime` to `h:mm ص` / `h:mm م`. All prayer time display calls go through this utility; no inline formatting in widgets.

### 5. Hive Cache Key

Composite key `"{YYYY-MM-DD}_{lat4dp}_{lon4dp}_{methodId}"` ensures that a location change or method change never silently serves old data. Latitude and longitude are rounded to 4 decimal places (~11 m precision) for key stability during minor GPS jitter.

### 6. Home Screen Card

`PrayerCardWidget` is zero-parameter — it wires directly to `nextPrayerProvider`. The `HomeScreen` simply includes `const PrayerCardWidget()` in its body. No prop drilling.

### 7. StorageService Extension

`StorageService` currently supports only `String` read/write. Add `readDouble`, `writeDouble`, `readInt`, `writeInt` methods using `SharedPreferences.setDouble`/`setInt`/`getDouble`/`getInt`. The `OnboardingService` pattern (direct SharedPreferences usage) is not replicated — all new storage goes through `StorageService` for consistency.

---

## Complexity Tracking

No constitution violations. No complexity justification required.
