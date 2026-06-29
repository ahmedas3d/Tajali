# Data Model: Adhkar & Dua (الأذكار والدعاء)

**Feature**: `008-adhkar-dua` | **Date**: 2026-06-28

---

## In-Memory Models (parsed from azkar.json, no Hive)

### AdhkarCategoryModel

Represents one category from the bundled JSON dataset.

```dart
class AdhkarCategoryModel {
  final String id;          // e.g., "morning", "evening"
  final String nameAr;      // e.g., "أذكار الصباح"
  final int count;          // total number of adhkar in this category
  final String iconName;    // matches SVG asset name, e.g., "icon_adhkar"
}
```

**Source**: Top-level array objects in `azkar.json`.
**Icon mapping**: Each category id maps to an SVG from `assets/svg/`; unmapped categories fall back to `icon_adhkar.svg`.

---

### DhikrModel

Represents a single dhikr entry within a category.

```dart
class DhikrModel {
  final int index;          // 0-based position within the category (used as counter key)
  final String categoryId;  // parent category id
  final String text;        // Arabic dhikr text
  final int repeat;         // required repetition count
  final String? source;     // hadith reference, e.g., "رواه مسلم" (nullable)
  final String? virtue;     // spiritual benefit text (nullable)
}
```

**Source**: `adhkar` array within each category object in `azkar.json`.
**Validation**: `repeat` must be > 0. Missing `reference`/`description` fields are treated as `null`.

---

## Persisted Models (Hive)

### TasbihSessionModel — typeId: 15

Stores the live in-progress tasbih session. Persisted on every tap.

```dart
@HiveType(typeId: 15)
class TasbihSessionModel extends HiveObject {
  @HiveField(0) String dhikrType;       // e.g., "سبحان الله"
  @HiveField(1) int currentCount;       // count within current round
  @HiveField(2) int completedRounds;    // number of completed full rounds
  @HiveField(3) int target;             // current round target (33 default, or custom)
}
```

**Box name**: `tasbihSessionBox`
**Key**: `'current'` (single entry; overwritten on every tap)
**Lifecycle**: Created on first app open; never deleted; reset to zeros on user-initiated إعادة (after history is saved).

---

### TasbihHistoryEntry — typeId: 16

One entry per logged session (saved when user resets after completing ≥ 1 round).

```dart
@HiveType(typeId: 16)
class TasbihHistoryEntry extends HiveObject {
  @HiveField(0) String dhikrType;   // e.g., "سبحان الله"
  @HiveField(1) int totalCount;     // completedRounds × target + currentCount
  @HiveField(2) String dateISO;     // ISO-8601 timestamp, e.g., "2026-06-28T14:35:00"
}
```

**Box name**: `tasbihHistoryBox`
**Key**: `dateISO` string (chronological ordering, no duplicates within same second)
**Lifecycle**: Append-only. No entries are deleted by the app in this phase.

---

## Primitive Hive Box (no custom type)

### dhikrCounterBox — `Box<int>`

Stores the remaining repetition count for each dhikr per day.

**Box name**: `dhikrCounterBox`
**Key format**: `$isoDate_$categoryId_$dhikrIndex`
**Example**: `2026-06-28_morning_3` → `4` (4 repetitions remaining)
**Value**: Remaining count. Absent key means dhikr has not been touched today; treat as full `repeat` count.

**Daily reset**: Stale keys (date prefix ≠ today) are ignored on read; a cleanup pass on app start removes entries older than 7 days.

---

## SharedPreferences Keys

| Key | Type | Default | Purpose |
|---|---|---|---|
| `tasbih_sound_enabled` | bool | `true` | Sound toggle for tasbih tap/complete sounds |
| `tasbih_vibration_enabled` | bool | `true` | Vibration toggle for tasbih taps |
| `tasbih_custom_targets` | String (JSON) | `'{}'` | Map of dhikrType → custom int target; overrides defaults |

---

## Hive Initialization (additions to main.dart)

```dart
// New Hive registrations to add in main():
Hive.registerAdapter(TasbihSessionModelAdapter());   // typeId: 15
Hive.registerAdapter(TasbihHistoryEntryAdapter());   // typeId: 16
await Hive.openBox<int>('dhikrCounterBox');
await Hive.openBox<TasbihSessionModel>('tasbihSessionBox');
await Hive.openBox<TasbihHistoryEntry>('tasbihHistoryBox');
```

---

## Riverpod Providers

```dart
// ── Adhkar ───────────────────────────────────────────────────────────────────

// Loads and parses azkar.json once; result cached in memory
final adhkarCategoriesProvider =
    FutureProvider<List<AdhkarCategoryModel>>((ref) => AdhkarService().getCategories());

// Dhikr list for a given categoryId
final dhikrListProvider =
    FutureProvider.family<List<DhikrModel>, String>((ref, categoryId) =>
        AdhkarService().getDhikrByCategory(categoryId));

// Remaining count for one dhikr (read from dhikrCounterBox, or full repeat if absent)
final dhikrCounterProvider =
    StateNotifierProvider.family<DhikrCounterNotifier, int, DhikrCounterKey>(
        (ref, key) => DhikrCounterNotifier(key));

// true when all dhikr in a category have count == 0 today
final categoryCompletionProvider =
    Provider.family<bool, String>((ref, categoryId) {
  // watches all DhikrCounterNotifier instances for this category
  // derived — no separate storage
});

// ── Tasbih ───────────────────────────────────────────────────────────────────

final tasbihSessionProvider =
    StateNotifierProvider<TasbihNotifier, TasbihSessionModel>((ref) =>
        TasbihNotifier());

final tasbihHistoryProvider =
    FutureProvider<List<TasbihHistoryEntry>>((ref) =>
        TasbihService().getHistory());

final tasbihSoundEnabledProvider = StateProvider<bool>((ref) => true);
final tasbihVibrationEnabledProvider = StateProvider<bool>((ref) => true);
```

---

## Default Tasbih Targets

| Dhikr | Default Target |
|---|---|
| سبحان الله | 33 |
| الحمد لله | 33 |
| الله أكبر | 33 |
| لا إله إلا الله | 100 |
| الاستغفار | 100 |
| الصلاة على النبي | 100 |

Custom targets from `tasbih_custom_targets` SharedPreferences override these.

---

## State Transitions: DhikrCounter

```
UNTOUCHED (no key in box)
    │ first tap
    ▼
IN_PROGRESS (key exists, value > 0)
    │ tap until value = 0
    ▼
COMPLETED (key exists, value = 0)
    │ midnight / new day
    ▼
UNTOUCHED (key ignored / deleted)
```

## State Transitions: TasbihSession

```
IDLE (currentCount = 0, completedRounds = 0)
    │ tap
    ▼
COUNTING (currentCount 1..target-1)
    │ tap when currentCount = target
    ▼
ROUND_COMPLETE (completedRounds++, currentCount resets to 0)
    │ إعادة (with completedRounds > 0)
    ▼
LOGGED + RESET (history entry saved, session reset to IDLE)
```
