# Research: Adhkar & Dua (الأذكار والدعاء)

**Feature**: `008-adhkar-dua` | **Date**: 2026-06-28

---

## 1. Adhkar JSON Dataset

**Decision**: Bundle the nawajalqari/azkar-api dataset as `assets/data/azkar.json`.

**Rationale**: The dataset is small (~200KB), stable, and freely available. Bundling avoids any runtime network dependency, satisfying the fully-offline constraint (FR-023). The format already supports all required fields: category, dhikr text, repetition count, source (reference), and virtue (description).

**Source**: `https://raw.githubusercontent.com/nawajalqari/azkar-api/main/azkar.json`

**JSON Structure**:
```json
[
  {
    "category": "أذكار الصباح",
    "id": "morning",
    "count": 32,
    "adhkar": [
      {
        "id": 1,
        "count": 7,
        "text": "اللهم أنت ربي لا إله إلا أنت...",
        "description": "من قالها حين يصبح...",
        "reference": "رواه البخاري"
      }
    ]
  }
]
```

**Parsing**: Loaded once per app session via `rootBundle.loadString('assets/data/azkar.json')` in `AdhkarService`. Result cached in memory after first parse.

**Alternatives considered**:
- Network fetch at runtime — rejected because FR-023 requires 100% offline operation.
- SQLite — rejected; the dataset is small enough for JSON in-memory parsing; SQL adds unnecessary complexity.

---

## 2. Daily Counter Keying Strategy

**Decision**: Use `Hive.openBox<int>('dhikrCounterBox')` with composite string keys: `$isoDate_$categoryId_$dhikrIndex`.

**Rationale**:
- No custom Hive type needed (int is natively supported), avoiding code generation for this concern.
- Composite key encodes all three dimensions (date, category, position) needed to uniquely identify a dhikr's daily counter.
- `dhikrIndex` (0-based position in the category array) is stable since the bundled JSON is immutable.
- Example key: `2026-06-28_morning_3` → value `4` (4 repetitions remaining of original 7).

**Midnight Reset Strategy**:
- On each app start (and whenever Adhkar screen is first rendered), compare stored key dates against `DateTime.now().toLocal()` formatted as `yyyy-MM-dd`.
- Keys from prior dates are automatically ignored (stale). A separate daily cleanup job deletes stale keys to prevent unbounded growth: run on app start if more than 7 days of old entries exist.
- No cron or background task needed — reset is implicit by date mismatch.

**Alternatives considered**:
- SharedPreferences with JSON map — rejected; box<int> is cleaner and avoids JSON encode/decode overhead for high-frequency writes.
- Separate Hive model with `@HiveType` — rejected; primitive box is sufficient and avoids code generation for counter state.

---

## 3. Tasbih Session Persistence

**Decision**: Store live tasbih session in `Box<TasbihSessionModel>` (Hive typeId: 15) under a fixed key `current`.

**Rationale**: Hive provides fast synchronous reads on startup. The session must survive process kill (not just app backgrounding), so SharedPreferences (write-through) would also work but Hive is already the project-standard for structured persistence.

**Session fields**:
| Field | Type | Purpose |
|---|---|---|
| dhikrType | String | Selected dhikr (e.g., "سبحان الله") |
| currentCount | int | Count within the current round |
| completedRounds | int | Completed full rounds |
| target | int | Current round target |

**Write strategy**: Write session to Hive on every tap (after state update). Frequency is acceptable given Hive's in-process speed.

**Alternatives considered**:
- SharedPreferences only — rejected; requires JSON encode/decode for structured data on every tap.
- Keep in memory only — rejected; session lost on process kill (contradicts FR-029).

---

## 4. Tasbih History Logging

**Decision**: Store each session entry in `Box<TasbihHistoryEntry>` (Hive typeId: 16), keyed by ISO timestamp string.

**Rationale**: Natural sort by key gives chronological ordering. History is append-only (no updates), so a simple key-value box is sufficient.

**History entry fields**:
| Field | Type | Purpose |
|---|---|---|
| dhikrType | String | e.g., "سبحان الله" |
| totalCount | int | completedRounds × target + currentCount at time of log |
| dateISO | String | e.g., "2026-06-28T14:35:00" |

**Trigger**: History entry is written when user taps إعادة (reset) and completedRounds > 0 (FR-026).

---

## 5. Tasbih Sound

**Decision**: Use `just_audio` (already in pubspec) to play two bundled MP3 files: `assets/audio/tasbih_tap.mp3` (short click, ~50ms) and `assets/audio/tasbih_complete.mp3` (ring tone, ~500ms).

**Rationale**: `just_audio` is already initialized for the Quran audio feature. Creating a lightweight `TasbihAudioService` wrapping two `AudioPlayer` instances (one per sound) re-uses existing infrastructure with zero new dependencies.

**Implementation notes**:
- Use separate `AudioPlayer` per sound (tap + complete) to allow overlap without interruption.
- Preload both assets on `TasbihScreen` mount; dispose on unmount.
- Sound toggle (`tasbih_sound_enabled` SharedPreferences bool) checked before every play call.

**Alternatives considered**:
- `audioplayers` package — rejected; `just_audio` already present.
- `soundpool` — rejected; adds a dependency not already in the project.

---

## 6. Vibration

**Decision**: Use `vibration ^2.0.0` (already in pubspec) — `Vibration.vibrate(duration: 30)` on each tap; `Vibration.vibrate(pattern: [0, 100, 50, 100])` on round completion.

**Rationale**: Package already declared in pubspec. Pattern vibration distinguishes round completion from individual taps.

**Fallback**: `Vibration.hasVibrator()` checked on screen mount; if false, vibration toggle is hidden (edge case per spec).

---

## 7. Category Completion Badge

**Decision**: Derive category completion status as a computed Riverpod `Provider.family<bool, String>` that watches all `dhikrCounterProvider` instances for the given category.

**Rationale**: Avoids storing a separate "category completed" flag — it is always derived from the individual dhikr counters. When all counters for a category are 0, the category is complete for the day.

**Visual**: Category card shows a gold checkmark overlay badge when complete. Resets at midnight alongside counters (implicit — all counters reset to full, so derived completion = false).

---

## 8. azkar.json Asset Registration

The file must be listed in `pubspec.yaml` under `flutter.assets`. The existing `assets/data/.gitkeep` confirms the directory is already declared; add the specific file entry:

```yaml
assets:
  - assets/data/azkar.json
  - assets/audio/tasbih_tap.mp3
  - assets/audio/tasbih_complete.mp3
```
