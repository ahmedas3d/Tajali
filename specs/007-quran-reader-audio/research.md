# Research: Quran Reading & Audio

**Feature**: 007-quran-reader-audio  
**Date**: 2026-06-27

---

## Decision 1: Audio Package

**Decision**: Use `just_audio ^0.9.38` (already in `pubspec.yaml`) with `ConcatenatingAudioSource`.

**Rationale**: `just_audio` supports a `ConcatenatingAudioSource` that accepts a list of `AudioSource` items (one per ayah). When the player advances through the list, `currentIndexStream` emits the new index — this directly maps to the ayah being recited, giving us per-ayah highlighting with zero extra sync logic. No separate timer or duration math needed.

**Alternatives considered**:
- `audioplayers`: simpler API but no built-in playlist or index stream; would require manual tracking of playback completion per ayah.
- Manual sequential playback (play file, await done, play next): works but is fragile under pause/seek; rejected in favour of `just_audio` playlist.

---

## Decision 2: Quran Font

**Decision**: Use the already-bundled `AmiriQuran` font family (asset: `assets/fonts/AmiriQuran.ttf`).

**Rationale**: `AmiriQuran` is purpose-built for Uthmanic Quran script with correct ligatures and glyph shaping. It is already declared in `pubspec.yaml` under the `AmiriQuran` font family name, so no new asset or dependency is needed.

**Alternatives considered**:
- `google_fonts` (Amiri): already used for UI text but not Quran-specific — does not have Uthmanic variant glyphs.
- KFGQ Uthman Hafs fonts: superior Uthmanic accuracy but requires a separate license and asset. Out of scope until needed.

---

## Decision 3: Ayah Text & Audio API Strategy

**Decision**: Fetch combined text + audio in a single API call using the multi-edition endpoint:
`GET /v1/surah/{number}/editions/quran-uthmani,{reciter_edition}`

**Rationale**: One round-trip delivers both the Uthmanic text for every ayah and the audio URLs for the selected reciter. This is significantly more efficient than two separate calls.

**Reciter-switching strategy**: When the user changes reciter, re-fetch only the audio edition for the new reciter (text is already cached). The ayah text cache key (`ayah_text_{surahNumber}`) is independent of reciter, so text is never re-fetched unnecessarily.

**Alternatives considered**:
- Two separate requests (text + audio): works but doubles round-trips on first load.
- Pre-fetching all 114 surahs: far too expensive on first launch; lazy load per-surah is correct.

---

## Decision 4: Ayah Text Caching

**Decision**: Cache fetched ayah lists in Hive using a dedicated box (`ayahTextBox`), keyed by surah number (`surah_text_{surahNumber}`). Store the full `List<AyahModel>` per surah.

**Rationale**: Hive is already used project-wide for structured local persistence. Per-surah caching means the user only downloads a surah once; subsequent opens are instant (< 300ms target per SC-004).

**Note on Hive typeIds**: AyahModel uses `typeId: 13`; AyahBookmark uses `typeId: 14`. Existing IDs 10–12 are taken by PrayerTimesModel, HijriDateModel, and SurahModel respectively.

---

## Decision 5: Ayah Bookmark Storage

**Decision**: Create a new `AyahBookmarkService` backed by a separate Hive box (`ayahBookmarksBox`) using the `AyahBookmark` model (typeId: 14). This is **separate** from the existing `BookmarkService` (`bookmarksBox`) which stores surah-level bookmarks as `Set<int>`.

**Rationale**: Surah-level bookmarks (Phase 2) and ayah-level bookmarks (Phase 3) are different entities with different keys and purposes. Sharing the same box would require a schema change that risks breaking Phase 2's existing data.

**Storage format**: A list of `AyahBookmark` objects, sorted by insertion time. Uniqueness enforced by `(surahNumber, ayahNumberInSurah)` composite key.

---

## Decision 6: Reading Position Persistence

**Decision**: Use `SharedPreferences` with keys `reader_pos_{surahNumber}` (integer: last visible ayah index) for per-surah reading position. The existing `quran_last_read_surah` / `quran_last_read_ayah` keys in Phase 2 track the globally most-recent surah across all surahs; Phase 3 extends this by also writing the per-surah position on scroll.

**Rationale**: Reading position is a small integer per surah; Hive is overkill. SharedPreferences is appropriate for up to ~114 keys (one per surah). The Phase 2 providers already use SharedPreferences for the global last-read, so patterns are consistent.

---

## Decision 7: Audio Scoping

**Decision**: Audio is tied to `QuranReaderScreen` lifecycle. Playback stops when the screen is popped. No background audio service in this phase.

**Rationale**: Clarified in `/speckit-clarify` session (Q1). Avoids `AudioSession`/foreground-service complexity. The `just_audio` player is disposed in the screen's `dispose()` call.

---

## Decision 8: Single-Ayah Repeat

**Decision**: Add a repeat toggle button to the audio player bar. When active, the `ConcatenatingAudioSource` playlist is replaced with a looping single-item source for the selected ayah. Turning repeat off restores the full playlist from the current ayah.

**Rationale**: Clarified in `/speckit-clarify` session (Q2). Single-ayah repeat is the primary memorisation tool; full-surah loop is deferred.

---

## Decision 9: Bookmark-to-Reader Deep Link

**Decision**: Tapping an `AyahBookmark` in the Bookmarks tab calls `Navigator.push()` with `QuranReaderScreen(surah: ..., initialAyahIndex: ...)`. The screen accepts an optional `initialAyahIndex` parameter that overrides the last-read position for this navigation only.

**Rationale**: Clarified in `/speckit-clarify` session (Q3). Deep-link navigation is a first-class flow; the reader screen must accept an `initialAyahIndex` to support it without relying on saved reading position.
