# Quickstart Validation Guide: Quran Surah List (قائمة السور)

**Phase**: 1 — Design & Contracts  
**Date**: 2026-06-26

This guide describes how to validate that the Quran Surah List feature works end-to-end once implementation is complete. It is a run guide, not an implementation guide.

---

## Prerequisites

1. Flutter SDK ≥ 3.3 installed and on PATH
2. Hive type adapters generated: `flutter pub run build_runner build --delete-conflicting-outputs`
3. A physical device or emulator with internet access for first-launch scenarios
4. A device or simulator that supports Arabic locale (or set locale manually in app)

---

## Scenario 1 — Happy Path: Surah List Display (US1)

**Goal**: Verify all 114 surahs render with correct data on first launch.

**Steps**:
1. Clear app data / use a clean install (no Hive cache).
2. Launch the app: `flutter run`
3. Tap the القرآن tab in the bottom navigation.
4. Wait for the list to load (skeleton cards → real cards).

**Expected outcomes**:
- Skeleton placeholder cards are shown briefly while data loads.
- All 114 surah cards are visible in canonical order (Al-Faatiha #1 at top, An-Nas #114 at bottom).
- Each card shows: surah number in a gold circle, Arabic name in gold Amiri Bold, English transliteration in ivory, a revelation badge (مكية or مدنية), and a verse count.
- A 🔖 bookmark icon appears on the right of each card (outlined, not filled).
- No "Continue Reading" banner is shown (Phase 3 has not written a last-read position).

**Validates**: FR-001, FR-002, FR-014, SC-001, SC-007, US1

---

## Scenario 2 — Search (US2)

**Goal**: Verify real-time diacritic-normalised search on the Surahs tab.

**Steps**:
1. Open the Quran screen (surah list loaded).
2. Tap the search bar (visible on Surahs tab).
3. Type `"البقرة"` (Arabic, without tashkeel).
4. Observe the list filter.
5. Clear the search field.

**Expected outcomes**:
- After typing `"البقرة"`, only Al-Baqara (and any other name containing that string) appears.
- Typing `"Al-Baqara"` (English) also matches and shows the same surah.
- Results update with each keystroke — no submit button required.
- Clearing the field restores all 114 surahs immediately.
- Typing a nonsense query (e.g., `"zzz"`) shows the empty-state message: `"لا توجد نتائج لـ «zzz»"`.

**Switch to Juz tab while search is active**:
- Search bar disappears; Juz view is shown regardless of the previous query.
- Returning to Surahs tab: search state is cleared; full list is shown.

**Validates**: FR-004, FR-005, FR-006, SC-003, SC-004, US2

---

## Scenario 3 — Bookmark Toggle (US5)

**Goal**: Verify bookmarking and unbookmarking persists across app restarts.

**Steps**:
1. Open the Quran screen.
2. Tap the 🔖 icon on Al-Kahf (surah 18).
3. Tap the 🔖 icon on Al-Faatiha (surah 1).
4. Switch to the "المفضلة" tab.
5. Kill and restart the app; return to the Quran screen.

**Expected outcomes**:
- After step 2: Al-Kahf's bookmark icon fills gold.
- After step 3: Al-Faatiha's bookmark icon fills gold.
- After step 4 (Bookmarks tab): Both Al-Faatiha (#1) and Al-Kahf (#18) appear, in canonical order (Al-Faatiha first).
- After restart: Same two surahs still appear in Bookmarks tab.
- Tap Al-Kahf's filled bookmark icon again → it is removed from Bookmarks tab immediately.

**Empty Bookmarks test**: Remove all bookmarks → Bookmarks tab shows `"لا توجد سور محفوظة بعد — احفظ سورة لتجدها هنا"` with guidance message.

**Validates**: FR-011, FR-012, FR-013, SC-006, US5

---

## Scenario 4 — Juz View (US4)

**Goal**: Verify sticky Juz headers and flat surah list on the Juz tab.

**Steps**:
1. Open the Quran screen.
2. Tap the "الأجزاء" tab.
3. Scroll slowly through the list.

**Expected outcomes**:
- 30 Juz section headers are present in order.
- All surahs are visible without any expand/collapse action.
- Each surah card shows all standard data (number, Arabic name, transliteration, badge, verse count, bookmark icon).
- As you scroll, the current Juz header sticks to the top of the screen until the next Juz header scrolls up and replaces it.
- Tapping a surah card navigates to `SurahStubScreen` for that surah.

**Validates**: FR-010, US4

---

## Scenario 5 — Surah Tap → Stub Screen (Clarification Q1)

**Goal**: Verify that tapping any surah navigates to a wired stub screen.

**Steps**:
1. Open the Quran screen (Surahs tab).
2. Tap any surah card (e.g., Al-Ikhlas, surah 112).

**Expected outcomes**:
- A new screen pushes onto the navigation stack.
- The screen displays the surah's Arabic name (e.g., `"الإخلاص"`) prominently.
- A "قريباً — الإصدار القادم" message is displayed.
- The back button/gesture returns to the Quran surah list.
- The stub screen does NOT crash or show a blank screen.

**Validates**: Spec clarification Q1, FR-008 (stub behaviour)

---

## Scenario 6 — Offline Mode (US1 + SC-005)

**Goal**: Verify surah list is available offline after first load.

**Steps**:
1. Launch with internet — load the Quran screen (triggers cache write).
2. Enable airplane mode.
3. Kill and restart the app.
4. Open the Quran screen.

**Expected outcomes**:
- All 114 surahs load from Hive cache — no network error, no spinner beyond the brief skeleton animation.
- No "retry" or error state is shown.
- Bookmarks and tab state work normally.

**Validates**: FR-009, SC-005, US1

---

## Scenario 7 — Error State (No Cache, No Network)

**Goal**: Verify graceful error state on first launch without connectivity.

**Steps**:
1. Ensure app data is cleared (no Hive cache).
2. Enable airplane mode.
3. Launch the app and open the Quran screen.

**Expected outcomes**:
- Skeleton cards appear briefly, then give way to an error state.
- An Arabic error message is displayed with a "إعادة المحاولة" (retry) button.
- Tapping retry re-attempts the API call and shows the same error while still offline.
- Re-enable network, tap retry → list loads and renders correctly.

**Validates**: FR-015, US1 edge case

---

## Unit Test Checklist

Run: `flutter test`

| Test file | What it covers |
|---|---|
| `test/unit/quran_service_test.dart` | API response parsing; Hive cache hit/miss; partial cache recovery; error handling |
| `test/unit/bookmark_service_test.dart` | Toggle add/remove; Hive persistence; empty initial state; serialisation |
| `test/unit/diacritic_normalisation_test.dart` | Arabic diacritic stripping; English case-folding; mixed queries; empty string |
| `test/widget/quran_screen_test.dart` | Tab switching; search bar visibility; loading/error states; skeleton cards |
| `test/widget/surah_card_test.dart` | All data fields render; bookmark icon state; tap navigates to stub |
| `test/widget/juz_list_view_test.dart` | 30 headers present; surah count per Juz correct; tap navigates |

---

## References

- [Provider contracts](contracts/providers.md)
- [AlQuran Cloud API contract](contracts/alquran_api.md)
- [Data model](data-model.md)
- [Feature spec](spec.md)
