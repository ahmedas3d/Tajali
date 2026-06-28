# Data Model: Quran Reading & Audio

**Feature**: 007-quran-reader-audio  
**Date**: 2026-06-27

---

## Existing Models (Phase 2 — no changes)

### SurahModel (`lib/features/quran/data/models/surah_model.dart`)
Hive typeId: 12 — already built, no modifications needed.

| Field | Type | Notes |
|---|---|---|
| number | int | 1–114 |
| name | String | Arabic name (Uthmanic) |
| englishName | String | Transliteration |
| revelationType | String | "Meccan" or "Medinan" |
| numberOfAyahs | int | Total ayah count |

---

## New Models (Phase 3)

### AyahModel (`lib/features/quran/data/models/ayah_model.dart`)
Hive typeId: **13** — new, must register adapter in `main.dart`.

| Field | HiveField | Type | Notes |
|---|---|---|---|
| number | 0 | int | Global ayah number (1–6236) |
| numberInSurah | 1 | int | Position within the surah (1-based) |
| surahNumber | 2 | int | Parent surah (1–114) |
| text | 3 | String | Uthmanic Arabic text |
| juz | 4 | int | Juz number (1–30) |
| page | 5 | int | Mushaf page number |
| audioUrl | 6 | String? | CDN audio URL (null if not loaded with audio edition) |

**Caching key**: stored in Hive box `ayahTextBox` under key `surah_text_{surahNumber}` as a `List<AyahModel>`.

**Validation rules**:
- `number` must be in range 1–6236
- `numberInSurah` must be ≥ 1
- `surahNumber` must be in range 1–114
- `text` must not be empty

**Factory**: `AyahModel.fromJson(Map<String, dynamic> json)` — parses AlQuran Cloud response.

---

### AyahBookmark (`lib/features/quran/data/models/ayah_bookmark.dart`)
Hive typeId: **14** — new, must register adapter in `main.dart`.

| Field | HiveField | Type | Notes |
|---|---|---|---|
| surahNumber | 0 | int | Surah the ayah belongs to |
| ayahNumberInSurah | 1 | int | Ayah position within surah (1-based) |
| surahName | 2 | String | Cached surah name for display |
| ayahText | 3 | String | Cached ayah text for preview |
| createdAt | 4 | DateTime | Insertion timestamp |

**Storage**: Hive box `ayahBookmarksBox` — separate from existing `bookmarksBox` (surah-level).

**Uniqueness key**: composite `(surahNumber, ayahNumberInSurah)` — no duplicate bookmarks for the same ayah.

**Equality**: two `AyahBookmark` objects are equal if both `surahNumber` and `ayahNumberInSurah` match.

---

### ReciterModel (`lib/features/quran/data/models/reciter_model.dart`)
Pure Dart — no Hive (static lookup table, not persisted as a model).

| Field | Type | Notes |
|---|---|---|
| identifier | String | API edition code, e.g. `ar.alafasy` |
| nameAr | String | Arabic display name |
| nameEn | String | English display name |

**Static list** (hardcoded, matches PLAN2.md):

| identifier | nameAr | nameEn |
|---|---|---|
| ar.alafasy | مشاري العفاسي | Mishary Alafasy |
| ar.abdulsamad | عبد الصمد | Abdul Samad |
| ar.abdullahbasfar | عبدالله بصفر | Abdullah Basfar |
| ar.hudhaify | علي الحذيفي | Ali Hudhaify |

---

## Preferences (SharedPreferences keys)

| Key | Type | Default | Purpose |
|---|---|---|---|
| `quran_selected_reciter` | String | `ar.alafasy` | Persisted reciter choice |
| `quran_font_size` | double | `28.0` | Ayah text font size |
| `reader_pos_{surahNumber}` | int | 0 | Per-surah last visible ayah index |

Note: `quran_last_read_surah` and `quran_last_read_ayah` (Phase 2 keys) are also written by Phase 3 when the user reads an ayah.

---

## Hive Box Registry

| Box name | Type | Purpose | Opened in |
|---|---|---|---|
| `surahListBox` | `Box<SurahModel>` | Surah metadata cache (Phase 2) | `main.dart` |
| `bookmarksBox` | `Box` | Surah-level bookmarks (Phase 2) | `main.dart` |
| `ayahTextBox` | `Box` | Ayah text cache per surah (Phase 3 NEW) | `main.dart` |
| `ayahBookmarksBox` | `Box<AyahBookmark>` | Ayah-level bookmarks (Phase 3 NEW) | `main.dart` |

---

## State Transitions: Audio Player

```
IDLE ──[play]──▶ LOADING ──[buffered]──▶ PLAYING
                                │
                         [pause] ▼
                             PAUSED ──[play]──▶ PLAYING
                                │
                         [stop/nav away]
                                ▼
                              IDLE

PLAYING ──[repeat on]──▶ PLAYING (loops current ayah)
PLAYING ──[reach end]──▶ IDLE (highlights cleared)
PLAYING ──[phone call]──▶ PAUSED (OS audio focus lost)
PAUSED  ──[call ends]──▶ PAUSED (user must manually resume)
```
