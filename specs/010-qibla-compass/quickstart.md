# Quickstart Validation Guide: Qibla Compass (القبلة)

## Prerequisites

1. Flutter 3.19+ installed and `flutter doctor` passes
2. Physical device with GPS + magnetometer (emulators cannot simulate compass heading)
3. `geocoding ^3.0.0` added to `pubspec.yaml` and `flutter pub get` run
4. Network connectivity available for first run (AlAdhan API + Overpass API)
5. Location permission NOT yet granted (for permission flow validation)

---

## Scenario 1 — Permission Denied → Grant → Compass Loads (US-5 P1)

**Setup**: Revoke location permission for the app in device settings before starting.

**Steps**:
1. Launch app → navigate to Qibla tab
2. Observe permission request card with "منح الإذن" (or similar) button
3. Tap the button → device permission dialog appears
4. Grant permission

**Expected**:
- Step 2: Compass area shows permission card, not a blank screen or broken UI
- Step 4: Without restarting the app, the compass rose and stats cards load automatically
- City chip appears below app bar within ~5 seconds (SC-001)

---

## Scenario 2 — Live Compass Needle Points Toward Mecca (US-1 P1)

**Setup**: Location permission granted. Network available.

**Steps**:
1. Open Qibla screen
2. Wait for compass to load (skeleton disappears)
3. Note the degree value shown in the direction badge (e.g., "SE ١٣٦°")
4. Physically rotate the device slowly 360°

**Expected**:
- Compass rose rotates smoothly as device turns; needle does NOT spin wildly (FR-017)
- Direction badge degree value remains constant throughout rotation (it shows Qibla bearing, not device heading)
- When device top is pointed toward Mecca, needle points straight up (US-1 scenario 5)
- Needle updates within ~100 ms of device movement (SC-002)

---

## Scenario 3 — Stats Cards Show Correct Values (US-2 P1)

**Setup**: Location permission granted. GPS acquired in Cairo, Egypt.

**Steps**:
1. Open Qibla screen and let it fully load
2. Check the two stats cards: distance (المسافة) and angle (زاوية الاتجاه)
3. Check the city chip below the app bar

**Expected**:
- Distance card shows approximately `١٬٢٤٠ كم` (±10 km tolerance, SC-004)
- Angle card shows approximately `١٣٦°` (±1° tolerance, SC-003)
- City chip shows `"القاهرة، مصر"` (or similar Arabic locale rendering)
- While loading: skeleton placeholders visible in place of card values (FR-016)

---

## Scenario 4 — Accuracy Badge Always Visible (US-3 P2)

**Setup**: Compass active on a physical device.

**Steps**:
1. Open Qibla screen with compass working
2. Observe the compass area for the accuracy badge
3. Move device near a metal surface or magnetic field source (if available)

**Expected**:
- An accuracy badge is always visible in the compass area (not just when low) — one of: "دقة منخفضة", "دقة متوسطة", "دقة عالية" (FR-009a)
- When accuracy is low, the calibration hint row below the stats cards becomes visually prominent (highlighted, warning icon) (US-3 scenario 3)
- Calibration hint text reads: "حرك هاتفك على شكل رقم (8) لزيادة دقة البوصلة" (FR-009)

---

## Scenario 5 — Nearest Mosque Card (US-4 P3)

**Setup**: Network available. Location in a populated area with mosques within 2 km.

**Steps**:
1. Open Qibla screen and wait for full load
2. Observe the bottom of the screen for the mosque card
3. Tap the "انتقل" button

**Expected**:
- Mosque card appears with mosque name in Arabic and distance (e.g., "على بعد ١٥٠ م" or "على بعد ٢٫٣ كم")
- Tapping "انتقل" opens the device's native maps app with the mosque as destination (SC-007)
- While mosque data is loading: skeleton placeholder visible (FR-016)

**Offline variation**:
1. Enable airplane mode
2. Open Qibla screen

**Expected**:
- Mosque card is NOT visible at all — no empty state, no error card, just absent (FR-010, clarification 2026-06-29)

---

## Scenario 6 — Offline with Cached Qibla Direction (FR-018)

**Setup**: Open Qibla screen once with network to prime the cache. Then enable airplane mode.

**Steps**:
1. Confirm Qibla direction loaded successfully (note the bearing angle)
2. Enable airplane mode
3. Close and reopen the Qibla screen

**Expected**:
- Compass loads within 3 seconds using cached direction (SC-005)
- A "آخر تحديث: [date]" badge is subtly visible (FR-015)
- Mosque card is NOT shown (offline, live-only)
- City chip still shows last known city name (from cache)
- Stats cards still show last known bearing + distance

---

## Scenario 7 — No Compass Sensor (FR-013)

**Setup**: Run on an emulator or a device where compass is unavailable. (On emulator, `FlutterCompass.events` emits null headings.)

**Steps**:
1. Open Qibla screen with GPS available

**Expected**:
- Compass widget renders the Qibla direction as a static fixed angle (no rotation)
- Message "لا يوجد بوصلة على هذا الجهاز" is visible
- Stats cards still show direction angle and distance
- Accuracy badge shows "دقة منخفضة" or is hidden (sensor absent)

---

## Unit Test Validation

Run `flutter test test/unit/qibla_service_test.dart`:

| Test | Validates |
|------|-----------|
| `haversineKm(Cairo, Mecca)` returns ~1240 | SC-004 Haversine accuracy |
| `haversineKm(Cairo, Alexandria)` < 50 → cache hit | Cache invalidation: no re-fetch for nearby move |
| `haversineKm(Cairo, London)` ≥ 50 → cache miss | Cache invalidation: re-fetch for >50 km move |
| `cardinalFromDegrees(136.0)` → `"SE"` | Direction badge abbreviation logic |
| `cardinalFromDegrees(0.0)` → `"N"` | Edge case: true North |
| `cardinalFromDegrees(359.9)` → `"N"` | Edge case: wrap-around |

Run `flutter test test/widget/compass_widget_test.dart`:

| Test | Validates |
|------|-----------|
| Widget renders with rotation=0.5 turn → `AnimatedRotation` turns=0.5 | Rotation value applied (SC-002 proxy) |
| Accuracy badge shows "دقة عالية" when `AccuracyLevel.high` | FR-009a |
| Accuracy badge shows "دقة منخفضة" when `AccuracyLevel.low` | FR-009a |
| Calibration hint row has `elevated` prominence when `AccuracyLevel.low` | US-3 scenario 3 |
