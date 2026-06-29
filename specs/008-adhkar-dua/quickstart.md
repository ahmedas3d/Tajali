# Quickstart Validation Guide: Adhkar & Dua (الأذكار والدعاء)

**Feature**: `008-adhkar-dua` | **Date**: 2026-06-28

---

## Prerequisites

1. Flutter 3.19+ with Dart 3.3 installed.
2. Project builds and runs: `flutter run` on iOS Simulator or Android Emulator.
3. `assets/data/azkar.json` is present and listed in `pubspec.yaml`.
4. `assets/audio/tasbih_tap.mp3` and `assets/audio/tasbih_complete.mp3` are present and listed in `pubspec.yaml`.
5. Hive adapters for `TasbihSessionModel` (typeId 15) and `TasbihHistoryEntry` (typeId 16) are registered in `main.dart`.
6. Run `dart run build_runner build` to generate `.g.dart` files before first build.

---

## Scenario 1 — Category Grid Loads (SC-002, FR-001–003)

**Steps**:
1. Launch the app. Navigate to the Adhkar tab (bottom nav).

**Expected**:
- Screen title "الأذكار والدعاء" is visible.
- Quranic inscription "أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ" appears as a subtitle.
- A 2-column grid of at least 8 category cards is shown, each with an icon, name, and count badge.
- Grid appears within 1 second (no loading spinner visible after app is warm).

---

## Scenario 2 — Offline Operation (FR-023, SC-006)

**Steps**:
1. Enable Airplane Mode on the device.
2. Launch the app and navigate to Adhkar tab.

**Expected**:
- All categories load normally — no error banner, no spinner.
- Tapping a category opens its dhikr detail screen normally.

---

## Scenario 3 — Dhikr Detail Screen Renders (FR-005–006, US2)

**Steps**:
1. Open any category (e.g., أذكار الصباح).

**Expected**:
- First dhikr text is shown in large Arabic script inside a card.
- Source text (e.g., "رواه البخاري") appears below the dhikr text.
- Virtue text appears below the source (if present).
- A circular counter displays the full repetition count (e.g., 7).
- Progress indicator in app bar shows "١ / ٣٢".

---

## Scenario 4 — Counter Decrements and Completes (FR-007–009, US2)

**Steps**:
1. Open a dhikr with `repeat = 3`.
2. Tap the counter 3 times.

**Expected**:
- Each tap decrements by 1: 3 → 2 → 1 → 0.
- At 0: counter turns dimmed/gray; action button changes from "تقبل الله" to "أتممت الذكر".
- Tapping the counter again does nothing (locked at 0).

---

## Scenario 5 — Navigation Through Category (FR-010–012, US3)

**Steps**:
1. Open أذكار الصباح. Note the progress "١ / N".
2. Tap "الذكر التالي" repeatedly until the last dhikr.

**Expected**:
- Progress counter increments on each tap (١ / N → ٢ / N → ... → N / N).
- "الذكر التالي" button is disabled/hidden on the last dhikr.
- "الذكر السابق" button is disabled/hidden on the first dhikr.
- Page dots reflect current position throughout.

---

## Scenario 6 — Counter Persists on Back-Navigation (FR-013, Clarification Q4)

**Steps**:
1. Open أذكار الصباح. Tap the counter for dhikr #1 twice (e.g., leaves 5 of 7 remaining).
2. Tap "الذكر التالي" to move to dhikr #2.
3. Tap "الذكر السابق" to return to dhikr #1.

**Expected**:
- Dhikr #1 counter shows 5 (remaining), not 7 (full count).

---

## Scenario 7 — Daily Persistence Across App Restart (FR-021, US5-S1)

**Steps**:
1. Open any category. Partially count a dhikr (e.g., tap 3 of 7 times).
2. Force-quit the app.
3. Relaunch the app. Navigate to the same dhikr.

**Expected**:
- Counter shows 4 remaining (progress preserved). Counter is NOT reset to 7.

---

## Scenario 8 — Category Completion Badge (FR-027–028, US1-S6)

**Steps**:
1. Open a short category (e.g., ذكر الأكل which has 3 entries with small repeat counts).
2. Complete all dhikr counters to 0 across all 3 entries.
3. Navigate back to the category grid.

**Expected**:
- The ذكر الأكل category card shows a visual completion badge/checkmark.
- Other categories without full completion show no badge.

---

## Scenario 9 — Midnight Reset (FR-022, FR-028, US5-S2)

**Steps** (test via date-injection or device date manipulation):
1. Complete several dhikr counters today.
2. Change the device date to tomorrow.
3. Relaunch the app and navigate to Adhkar.

**Expected**:
- All counters are back to their full repetition counts.
- All category completion badges are cleared.

---

## Scenario 10 — Tasbih Counter and Round Completion (FR-015–017, US4)

**Steps**:
1. Tap "ابدأ الآن" on the Adhkar screen banner. Tasbih screen opens.
2. Confirm "سبحان الله" is selected with target 33.
3. Tap "اضغط للتسبيح" 33 times.

**Expected**:
- Counter increments: 0 → 1 → ... → 33.
- On the 33rd tap: counter resets to 0; completed rounds indicator shows "دورة واحدة مكتملة" (or equivalent).
- Page dot for round 1 appears.

---

## Scenario 11 — Tasbih Sound and Vibration (FR-019, FR-019a)

**Steps**:
1. Open tasbih screen. Verify sound and vibration toggles are ON by default.
2. Tap "اضغط للتسبيح" once.
3. Complete a full round (33 taps).

**Expected**:
- Each tap: brief device vibration + short click sound plays.
- Round completion: distinct vibration pattern + ring tone plays.
4. Toggle sound OFF. Tap once → no sound, vibration still occurs.
5. Toggle vibration OFF. Tap once → no vibration, no sound.

---

## Scenario 12 — Tasbih History (FR-024–026, US4-S10–11)

**Steps**:
1. Complete one full round on the tasbih screen.
2. Tap "إعادة" (reset).
3. Tap "سجّل" (log).

**Expected**:
- After reset: confirm a history entry was saved (screen should reflect round was logged).
- History screen shows one entry: dhikr type = "سبحان الله", total count = 33, today's date.
4. Tap "سجّل" when no sessions exist → empty-state message visible.

---

## Scenario 13 — Tasbih Session Persists Across Restart (FR-029, US4-S12)

**Steps**:
1. Tap the tasbih counter 20 times (counter shows 20 of 33). Do NOT reset.
2. Force-quit the app.
3. Relaunch. Navigate to Tasbih screen.

**Expected**:
- Counter shows 20 (session restored). Completed rounds = 0. Selected dhikr = "سبحان الله".

---

## Scenario 14 — Custom Target (FR-020)

**Steps**:
1. Open the tasbih screen. Tap "تحديد العدد".
2. Set a custom target of 100 for "سبحان الله".

**Expected**:
- Target label updates to "من ١٠٠".
- A round completes after 100 taps (not 33).
3. Close and reopen the app → custom target is preserved.

---

## Run Commands

```bash
# Build (required after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Unit tests
flutter test test/unit/adhkar_service_test.dart
flutter test test/unit/dhikr_counter_service_test.dart
flutter test test/unit/tasbih_service_test.dart

# Widget tests
flutter test test/widget/adhkar_screen_test.dart
flutter test test/widget/dhikr_detail_screen_test.dart
flutter test test/widget/tasbih_screen_test.dart

# All tests
flutter test

# Run on device
flutter run
```
