# Quickstart Validation Guide: Prayer Times (مواقيت الصلاة)

**Phase**: 1 — Design & Contracts  
**Date**: 2026-06-26

This guide describes how to validate that the Prayer Times feature works end-to-end once implementation is complete. It is a run guide, not an implementation guide.

---

## Prerequisites

1. Flutter SDK ≥ 3.3 installed and on PATH
2. Hive type adapters generated: `flutter pub run build_runner build --delete-conflicting-outputs`
3. A physical device or emulator/simulator with location services available
4. (Optional) a tool to inspect Hive boxes (e.g., `hive_inspector` or `flutter devtools`)

---

## Scenario 1 — Happy Path: Prayer Times Display (US1 + US2)

**Goal**: Verify all prayer times and countdown render correctly for a real GPS location.

**Steps**:
1. Ensure network is available and location permission is granted.
2. Launch the app: `flutter run`
3. Navigate to the Prayer Times tab (الصلاة) in the bottom navigation.

**Expected outcomes**:
- All 7 time slots (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha, Imsak) are displayed in Arabic with 12-hour ص/م format.
- Hijri date is shown in the header (e.g., `١ محرم ١٤٤٨`).
- The next upcoming prayer is visually highlighted (gold accent).
- The countdown hero shows `"بعد h:mm"` and updates every minute without requiring a screen refresh.

**Validates**: FR-001, FR-002, FR-003, FR-004, SC-001, SC-002

---

## Scenario 2 — Offline Mode (US3)

**Goal**: Verify cached prayer times are shown when network is unavailable.

**Steps**:
1. Launch app with network available, load Prayer Times tab (triggers cache write).
2. Enable airplane mode on the device.
3. Kill and restart the app.
4. Navigate to Prayer Times tab.

**Expected outcomes**:
- All 7 prayer times are shown (from Hive cache).
- A non-intrusive "آخر تحديث: [time]" banner or label is visible.
- No spinner or error state is shown — data is present.
- Re-enable network → banner disappears on next refresh.

**Validates**: FR-005, FR-006, SC-003, US3

---

## Scenario 3 — Calculation Method Switch (US4)

**Goal**: Verify changing the method in Settings updates prayer times immediately.

**Steps**:
1. Launch app, note the Dhuhr time.
2. Tap the gear icon in the AppBar → Settings screen opens.
3. Change the calculation method from "الهيئة المصرية" to "رابطة العالم الإسلامي".
4. Navigate back to the Prayer Times tab.

**Expected outcomes**:
- Dhuhr (and likely other times) have changed values reflecting the new method.
- The change is immediate (< 2 seconds).
- Kill and restart the app → Settings shows the new method is still selected, and prayer times reflect it.

**Validates**: FR-007, FR-008, SC-004, US4

---

## Scenario 4 — Location Permission Denied Fallback (US5)

**Goal**: Verify the manual city selector works when location is denied.

**Steps**:
1. Revoke location permission for the app in device settings.
2. Launch the app, navigate to Prayer Times tab.

**Expected outcomes**:
- A prompt appears explaining location is needed and offering a "تحديد المدينة يدوياً" option.
- Tapping the option opens a searchable city list.
- Selecting a city (e.g., "القاهرة") displays prayer times for that city.
- Kill and restart the app → the previously selected city is remembered; prayer times load without re-prompting.

**Validates**: FR-010, SC-005, US5

---

## Scenario 5 — Home Screen Card (FR-014)

**Goal**: Verify the `PrayerCardWidget` renders correctly on the Home screen.

**Steps**:
1. Launch the app with location available (prayer times loaded).
2. Stay on the Home tab (الرئيسية).

**Expected outcomes**:
- The prayer card shows the next prayer's Arabic name, formatted time, and live countdown.
- No other prayer time slots are shown on the card.
- No additional network calls are made (verify in DevTools Network panel — Hive is already warm).

**Validates**: FR-014, SC-007, home_card_widget contract

---

## Scenario 6 — Midnight Date Rollover (Edge Case)

**Goal**: Verify prayer times refresh automatically on a new day.

**Steps** (manual or using a date-mock in integration tests):
1. Load prayer times for date D.
2. Advance the device clock past midnight.
3. Bring the app to the foreground.

**Expected outcomes**:
- The Prayer Times screen shows updated times for date D+1.
- The Hijri date in the header updates correspondingly.
- No user action required.

**Validates**: FR-009, SC-006

---

## Unit Test Checklist

Run: `flutter test`

| Test file | What it covers |
|---|---|
| `test/unit/prayer_calculation_service_test.dart` | `adhan` integration — verifies times for known coords + method match expected values |
| `test/unit/hijri_date_service_test.dart` | AlAdhan API response parsing; cache hit/miss logic |
| `test/unit/time_formatter_test.dart` | `toArabic12h()` — boundary cases (midnight, noon, 11:59 PM) |
| `test/unit/prayer_cache_service_test.dart` | Hive read/write; stale detection; composite key construction |
| `test/unit/settings_service_test.dart` | Method ID persistence and retrieval; default fallback |
| `test/widget/prayer_times_screen_test.dart` | Renders 7 rows; highlights next prayer; loading/error states |
| `test/widget/prayer_card_widget_test.dart` | Card shows name, time, countdown; loading shimmer; error dash |
| `test/widget/settings_screen_test.dart` | Method selector renders 5 options; selection updates provider |

---

## References

- [Provider contracts](contracts/providers.md)
- [AlAdhan Hijri API contract](contracts/aladhan_hijri_api.md)
- [Home card widget contract](contracts/home_card_widget.md)
- [Data model](data-model.md)
