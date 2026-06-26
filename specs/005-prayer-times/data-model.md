# Data Model: Prayer Times (مواقيت الصلاة)

**Phase**: 1 — Design & Contracts  
**Date**: 2026-06-26  
**Research**: [research.md](research.md)

---

## Entities

### PrayerTimesModel

Represents a complete set of prayer times for a single calendar day, GPS location, and calculation method. Persisted to Hive.

| Field | Type | Description |
|---|---|---|
| `cacheKey` | `String` | Composite key: `"{YYYY-MM-DD}_{lat4dp}_{lon4dp}_{methodId}"` — Hive box key |
| `date` | `String` | Gregorian date in `YYYY-MM-DD` format |
| `latitude` | `double` | GPS latitude (4 decimal places used for key) |
| `longitude` | `double` | GPS longitude (4 decimal places used for key) |
| `methodId` | `int` | Calculation method identifier (0–4, see CalculationMethodConfig) |
| `fajr` | `String` | Formatted time, e.g. `"4:12 ص"` |
| `sunrise` | `String` | Formatted time, e.g. `"5:54 ص"` |
| `dhuhr` | `String` | Formatted time, e.g. `"12:09 م"` |
| `asr` | `String` | Formatted time, e.g. `"3:26 م"` |
| `maghrib` | `String` | Formatted time, e.g. `"6:48 م"` |
| `isha` | `String` | Formatted time, e.g. `"8:18 م"` |
| `imsak` | `String` | Formatted time (Fajr − 10 min), e.g. `"4:02 ص"` |
| `fetchedAt` | `DateTime` | When this record was calculated/cached — used for "last updated" banner |

**Hive box name**: `prayerTimesBox`  
**Hive type ID**: `10` (next available after splash feature models)

**Validation rules**:
- `date` must match `YYYY-MM-DD` pattern
- `latitude` ∈ [−90, 90], `longitude` ∈ [−180, 180]
- All time fields non-empty if record is valid
- A record is considered stale when `date ≠ today's date` in device-local timezone

---

### HijriDateModel

Maps a Gregorian date to its Islamic calendar equivalent. Persisted to Hive.

| Field | Type | Description |
|---|---|---|
| `gregorianDate` | `String` | Gregorian date in `YYYY-MM-DD` format — Hive box key |
| `day` | `int` | Hijri day number (1–30) |
| `monthAr` | `String` | Hijri month name in Arabic, e.g. `"ذُو الحِجَّة"` |
| `year` | `int` | Hijri year, e.g. `1446` |
| `readable` | `String` | Full formatted string, e.g. `"١٥ ذو الحجة ١٤٤٦"` |

**Hive box name**: `hijriDateBox`  
**Hive type ID**: `11`

**Validation rules**:
- `gregorianDate` must match `YYYY-MM-DD`
- `day` ∈ [1, 30], `year` > 1400
- Cache is valid for the lifetime of the matching `gregorianDate`; a new Gregorian day triggers a new fetch

---

### NextPrayerModel

Derived view of the nearest upcoming prayer. Computed in-memory from `PrayerTimesModel` and `DateTime.now()`. Not persisted.

| Field | Type | Description |
|---|---|---|
| `name` | `String` | Internal English name, e.g. `"Asr"` (matches `adhan` Prayer enum) |
| `nameAr` | `String` | Arabic display name, e.g. `"العصر"` |
| `scheduledTime` | `String` | Formatted 12-hour time, e.g. `"3:26 م"` |
| `remaining` | `Duration` | Time until the prayer fires; always positive |

**Prayer Arabic Names Map**:
```
fajr    → الفجر
sunrise → الشروق
dhuhr   → الظهر
asr     → العصر
maghrib → المغرب
isha    → العشاء
```

---

### CalculationMethodConfig

Value object representing a single calculation method option. Not persisted as a Hive entity; the user's selection is stored as a plain `int` in SharedPreferences under key `prayer_method_id`.

| Field | Type | Description |
|---|---|---|
| `id` | `int` | Integer identifier (0=Egyptian, 1=MWL, 2=UmmAlQura, 3=ISNA, 4=Karachi) |
| `nameAr` | `String` | Arabic display name shown in Settings |
| `nameEn` | `String` | English label for debugging/logging |

**All available methods (Phase 1)**:

| `id` | `nameAr` | `nameEn` | `adhan` factory |
|---|---|---|---|
| `0` | الهيئة المصرية العامة للمساحة | Egyptian General Authority | `CalculationMethod.egyptian()` |
| `1` | رابطة العالم الإسلامي | Muslim World League | `CalculationMethod.muslimWorldLeague()` |
| `2` | أم القرى | Umm Al-Qura (Makkah) | `CalculationMethod.ummAlQura()` |
| `3` | الجمعية الإسلامية بأمريكا الشمالية | ISNA | `CalculationMethod.northAmerica()` |
| `4` | جامعة العلوم الإسلامية — كراتشي | Karachi / Hanafi | `CalculationMethod.karachi()` |

**Default**: `id = 0` (Egyptian)  
**SharedPreferences key**: `prayer_method_id`

---

### CachedLocationModel

Stores the last successfully resolved GPS coordinate for fallback use. Persisted in SharedPreferences (not Hive, since it's a single scalar record).

| Field | Storage Key | Type | Description |
|---|---|---|---|
| `latitude` | `cached_location_lat` | `double` (stored as `String`) | Last known latitude |
| `longitude` | `cached_location_lon` | `double` (stored as `String`) | Last known longitude |
| `resolvedAt` | `cached_location_ts` | `int` (epoch ms) | When this location was captured |

**Fallback trigger**: GPS fix not obtained within 10 seconds of requesting location.

---

### ManualCityEntry

Value object from the bundled city list. Not persisted — selection is stored in SharedPreferences as `selected_city_name` (display name) + `selected_city_lat` / `selected_city_lon`.

| Field | Type | Description |
|---|---|---|
| `nameAr` | `String` | City name in Arabic, e.g. `"القاهرة"` |
| `latitude` | `double` | City-centre latitude |
| `longitude` | `double` | City-centre longitude |

---

## State Transitions

### Prayer Times Load Flow

```
App opens / foreground resume
        │
        ▼
Date changed since last cache?
        │
  Yes ──┼── Request GPS fix (10 s timeout)
        │         │
        │   GPS ok─┼─── Calculate times via adhan package
        │         │           │
        │   Timeout──── Use CachedLocation ──► Calculate times
        │                                            │
  No ──►└──────────────── Serve from Hive cache ◄───┘
                                    │
                               Render screen
```

### Settings Method Change

```
User selects new method in SettingsScreen
        │
        ▼
Persist new methodId to SharedPreferences
        │
        ▼
calculationMethodProvider state updated
        │
        ▼
prayerTimesProvider invalidated (depends on method)
        │
        ▼
Recalculate prayer times locally (adhan, instant)
        │
        ▼
New PrayerTimesModel saved to Hive (new cacheKey)
        │
        ▼
UI rebuilds with updated times
```

---

## Hive Adapter Notes

Both `PrayerTimesModel` and `HijriDateModel` require Hive type adapters generated via `build_runner`. The project already declares `hive_generator` and `build_runner` in `dev_dependencies`.

Run after model annotation: `flutter pub run build_runner build --delete-conflicting-outputs`
