# Research: Prayer Times (مواقيت الصلاة)

**Phase**: 0 — Outline & Research  
**Date**: 2026-06-26  
**Spec**: [spec.md](spec.md)

---

## Decision 1 — Prayer Time Calculation Strategy

**Decision**: Use the `adhan` Dart package (already declared in `pubspec.yaml` at `^2.0.0+1`) for all local prayer time calculation. No external API call is required for the calculation itself.

**Rationale**: The `adhan` package is a pure-Dart port of the battle-tested Adhan library. It supports every required calculation method, runs entirely offline, produces results in microseconds, and eliminates a network round-trip for the most time-sensitive data in the app. This aligns with the offline-first requirement (FR-005) and the 3-second load-time criterion (SC-001).

**Alternatives considered**:
- **AlAdhan REST API** (`/v1/timings`): Network-dependent, adds latency, requires caching layer. Rejected as the primary source since `adhan` already delivers the same data locally.
- **Bundled lookup tables**: Unmaintainable, location-specific, impractical. Rejected.

**`adhan` package coverage** (all five required methods available):

| Spec Method | `adhan` `CalculationMethod` factory |
|---|---|
| Egyptian General Authority of Survey (default) | `CalculationMethod.egyptian()` |
| Muslim World League | `CalculationMethod.muslimWorldLeague()` |
| Umm Al-Qura | `CalculationMethod.ummAlQura()` |
| ISNA / North America | `CalculationMethod.northAmerica()` |
| Karachi / Hanafi | `CalculationMethod.karachi()` |

The Asr school (Standard vs. Hanafi) is implicit in the chosen method (e.g., `karachi()` uses Hanafi). No separate `school` parameter is needed — consistent with the spec clarification.

---

## Decision 2 — Hijri Date Source

**Decision**: Fetch the Hijri date once per day from AlAdhan API (`GET /v1/gToH/{DD-MM-YYYY}`), cache the result in Hive keyed by Gregorian date string.

**Rationale**: The `adhan` package does not expose Hijri date conversion. The AlAdhan API provides a clean, simple Hijri endpoint requiring no API key. One call per calendar day with Hive caching means the network is only hit on the first foreground open of each day.

**Alternatives considered**:
- **Local Kuwaiti Algorithm implementation**: Accurate but non-trivial to implement and test; the AlAdhan endpoint is simpler and already being tested by the Islamic dev community. Rejected to avoid scope creep.
- **A separate Dart Hijri package** (`hijri` on pub.dev): Would require adding a new dependency; the AlAdhan approach reuses the existing HTTP infrastructure. Can be revisited if offline Hijri becomes a requirement.

**AlAdhan Hijri endpoint used**:
```
GET https://api.aladhan.com/v1/gToH/{DD-MM-YYYY}
Response field: data.hijri → { day, month.ar, year, readable }
```

---

## Decision 3 — Imsak Time Calculation

**Decision**: Derive Imsak as Fajr − 10 minutes locally. No API call.

**Rationale**: Imsak is not a canonical prayer in the `adhan` package. The universal convention (and the AlAdhan API's own behaviour) is Imsak = Fajr − 10 minutes. This can be computed with a single `DateTime.subtract` call on the `adhan` Fajr result.

---

## Decision 4 — Live Countdown Update Mechanism

**Decision**: Use a `StreamProvider` backed by `Stream.periodic(Duration(minutes: 1))` to re-derive the `NextPrayerModel` every minute. The `adhan` package's `PrayerTimes.nextPrayer()` method returns the next Prayer enum given a `DateTime.now()`.

**Rationale**: A 1-minute polling interval matches the spec requirement (SC-002: accurate to within 1 minute). Riverpod `StreamProvider` integrates cleanly with the widget tree and rebuilds only the countdown widget, not the full screen.

**Alternatives considered**:
- **Timer in StatefulWidget**: Not testable, couples business logic to UI. Rejected.
- **30-second interval**: More accurate but wastes battery. Rejected — 1-minute is the spec requirement.

---

## Decision 5 — Local Caching Strategy

**Decision**: Hive box `prayerTimesBox` keyed by composite `"{YYYY-MM-DD}_{lat}_{lon}_{methodId}"`. Prayer times for the previous date are invalidated on app foreground when the device date has changed.

**Rationale**: The composite key ensures that moving to a new city or changing method correctly triggers a re-fetch rather than silently serving stale data. Hive is already initialised in the app via `hive_flutter`.

**Staleness policy**:
- Prayer times: valid for the calendar day they were fetched (date-keyed)
- Hijri date: valid for the Gregorian date it maps to (date-keyed)
- Last known location: no expiry; used only when a fresh GPS fix times out (> 10 s)

---

## Decision 6 — Settings Screen Placement

**Decision**: A new `SettingsScreen` is created under `lib/features/settings/presentation/settings_screen.dart`. It is accessible via a gear icon (`Icons.settings_outlined`) in the AppBar of the main navigation shell, not as a bottom-nav tab.

**Rationale**: The bottom nav already has 5 items (Home, Quran, Adhkar, Qibla, Prayer Times). Adding a 6th would visually overflow on smaller devices. Gear-icon → push is the dominant mobile pattern for settings and keeps nav symmetry intact. This is the Phase 1 scope; future phases may promote Settings to a bottom tab if content grows.

---

## Decision 7 — Time Formatting (12-hour Arabic AM/PM)

**Decision**: All prayer times are displayed in 12-hour format with Arabic AM/PM markers: **ص** (صباحاً, AM) for hours 0–11 and **م** (مساءً, PM) for hours 12–23.

**Format**: `h:mm ص` / `h:mm م`  (e.g., `4:12 ص`, `3:48 م`)

**Implementation**: A shared `TimeFormatter.toArabic12h(DateTime dt)` utility method in `lib/core/utils/helpers.dart` (the file already exists).

---

## Decision 8 — Manual City Fallback (US5)

**Decision**: A curated list of ~50 major cities (city name in Arabic, latitude, longitude) is bundled as a Dart constant list. The user selects from this list via a searchable modal bottom sheet triggered from the Prayer Times screen when location permission is denied.

**Rationale**: The spec assumption states "Manual city search results are provided by a built-in curated list of major cities; a live geocoding API search is not required for this phase." A Dart constant list requires no asset loading and no extra package.

**Selected cities**: Egyptian cities (Cairo, Alexandria, Giza, etc.) + major Arab capitals + major global Muslim population centres (Karachi, Jakarta, Kuala Lumpur, London, New York, etc.)

---

## Resolved Unknowns

| Unknown | Resolution |
|---|---|
| Prayer calculation engine | `adhan` package (offline, already in pubspec) |
| Hijri date source | AlAdhan API `/v1/gToH`, cached per day |
| Imsak calculation | Fajr − 10 min, local |
| Countdown mechanism | `Stream.periodic(1 minute)` via Riverpod `StreamProvider` |
| Cache key strategy | Composite date+coords+method key in Hive |
| Settings screen entry point | Gear icon in AppBar, not bottom-nav tab |
| Time format | 12-hour, ص/م markers, shared formatter utility |
| City fallback | Bundled Dart constant list, searchable modal |
