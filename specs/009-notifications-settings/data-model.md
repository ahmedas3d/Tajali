# Data Model: Notifications & Settings

**Date**: 2026-06-29 | **Plan**: [plan.md](plan.md)

---

## New Entities

### FiqhSchool (new enum)

**Location**: `lib/features/prayer_times/providers/prayer_times_providers.dart`

```
FiqhSchool
  shafii   → Madhab.shafi  (shadow 1×, earlier Asr)  [default]
  hanafi   → Madhab.hanafi (shadow 2×, later Asr ~30–60 min)
```

**Persistence**: SharedPreferences key `fiqh_school` (int = `FiqhSchool.index`)

**Relationships**:
- Mapped to `Madhab` enum from `adhan` package in `PrayerCalculationService`
- Watched by `prayerTimesProvider` → triggers recalculation when changed
- Asr notification rescheduled automatically via `adhanSchedulerProvider`

---

### PrayerNotificationSettings (conceptual record — stored as 5 separate keys)

**Location**: `lib/features/prayer_times/providers/prayer_times_providers.dart`

| Provider | SharedPreferences Key | Default |
|----------|----------------------|---------|
| `prayerNotifFajrProvider` | `prayer_notif_fajr` | `true` |
| `prayerNotifDhuhrProvider` | `prayer_notif_dhuhr` | `true` |
| `prayerNotifAsrProvider` | `prayer_notif_asr` | `true` |
| `prayerNotifMaghribProvider` | `prayer_notif_maghrib` | `true` |
| `prayerNotifIshaProvider` | `prayer_notif_isha` | `true` |

Each is a `StateProvider<bool>`. Loaded at startup via `overrideWith` in `main.dart`.

**State transition**:
```
toggle ON  → save to prefs → schedule that prayer's notification for today+tomorrow
toggle OFF → save to prefs → cancel that prayer's notification ID immediately
```

**Validation**: No validation needed — booleans cannot be invalid.

---

## Modified Entities

### AdhanSoundSource (existing enum — unchanged)

**Location**: `lib/core/services/adhan_notification_service.dart`

```
AdhanSoundSource
  makkah  → 'adhan_fajr' / 'adhan_regular'         [default, index 0]
  egypt   → 'adhan_egypt_fajr' / 'adhan_egypt_regular'
```

**Persistence**: SharedPreferences key `adhan_sound_source` (int, existing key `_adhanSoundKey`)

---

### AdhanSound (existing enum in adhan_audio_service.dart — unchanged)

```
AdhanSound
  makkah  → assets/audio/adhan_fajr.mp3 / adhan_regular.mp3
  egypt   → assets/audio/adhan_egypt_fajr.mp3 / adhan_egypt_regular.mp3
```

---

### ScheduledNotification (conceptual — not a persisted model)

Each scheduled local notification uses a fixed integer ID:

| Prayer | Notification ID (today) | Notification ID (tomorrow) |
|--------|------------------------|---------------------------|
| Fajr | 100 | 110 |
| Sunrise | 101 | 111 |
| Dhuhr | 102 | 112 |
| Asr | 103 | 113 |
| Maghrib | 104 | 114 |
| Isha | 105 | 115 |
| Qiyam | 106 | 116 |
| Test | 999 | — |

**Rationale**: Fixed IDs allow targeted cancellation without storing a registry. The +10 offset for tomorrow separates the two days' notifications cleanly. `cancelAll()` iterates both sets.

---

## Unchanged Entities (referenced, not modified)

### PreferredReciter (existing)

**Location**: `lib/features/quran/providers/reader_providers.dart`

```
selectedReciterProvider: StateProvider<String>
  default: 'ar.alafasy'
  prefs key: 'quran_selected_reciter'
```

Available values (from `ReciterModel.reciters`):
- `ar.alafasy` — مشاري العفاسي
- `ar.abdulsamad` — عبد الصمد
- `ar.abdullahbasfar` — عبدالله بصفر
- `ar.hudhaify` — علي الحذيفي

---

### CalculationMethodConfig (existing)

**Location**: `lib/features/prayer_times/providers/prayer_times_providers.dart`

5 methods (id 0–4): Egyptian, Muslim World League, Umm Al-Qura, ISNA, Karachi. No changes.

---

## State Flow Diagram

```
App launch
  └─ main.dart loads from SharedPreferences:
       savedMethodId, savedCity, savedNotifMode(*removed*),
       savedAdhanSound, savedFiqhSchool,
       savedNotifFajr … savedNotifIsha,
       savedReciter (via initReciterProvider)
       └─ ProviderScope.overrides inject all saved values

User changes Fiqh School
  └─ fiqhSchoolProvider updates
       └─ prayerTimesProvider invalidates (watches fiqhSchool)
            └─ adhanSchedulerProvider fires
                 └─ reschedules Asr notification (and all others for today+tomorrow)

User toggles Fajr OFF
  └─ prayerNotifFajrProvider = false
       └─ adhanSchedulerProvider fires
            └─ plugin.cancel(_kFajrId) + plugin.cancel(_kFajrId + 10)

User changes sound to Egypt
  └─ adhanSoundProvider updates
       └─ adhanSchedulerProvider fires
            └─ cancel all → reschedule all enabled with egypt sound files
```

> *Note*: `savedNotifMode` (old `AdhanNotificationMode` enum) is superseded by the 5 individual prayer toggles. The `notificationModeProvider` is removed or kept as a no-op to avoid breaking existing builds.
