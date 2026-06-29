# Tasks: Qibla Compass (القبلة)

**Input**: Design documents from `specs/010-qibla-compass/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/qibla_api.md ✅ | quickstart.md ✅

**Tests**: Unit + widget tests included (referenced in spec testing requirements and quickstart.md).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: Maps to user story label from spec.md (US1–US5)
- Exact file paths are included in every task description

---

## Phase 1: Setup

**Purpose**: Add the only new dependency not yet in pubspec.yaml before any code is written.

- [x] T001 Add `geocoding: ^3.0.0` to `pubspec.yaml` under `# Location & Compass` section and run `flutter pub get` to verify resolution

**Checkpoint**: `flutter pub get` completes with no errors. `geocoding` package appears in `pubspec.lock`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Data models, services, and Riverpod providers that every user story depends on. No user story task can begin until this phase is complete.

**⚠️ CRITICAL**: All US phases (3–6) are blocked until T002–T008 are complete.

- [x] T002 [P] Create `QiblaModel` class and `AccuracyLevel` enum (low/medium/high) with platform-specific mapping from `CompassEvent.accuracy` (iOS degrees vs Android status int) in `lib/features/qibla/data/models/qibla_model.dart`
- [x] T003 [P] Create `MosqueModel` class (nameAr, lat, lon, distanceMeters) with `formattedDistance` getter (< 1000 m → "١٥٠ م", ≥ 1000 → "٢٫٣ كم") and `mapsUrl` getter (`geo:{lat},{lon}?q=...`) in `lib/features/qibla/data/models/mosque_model.dart`
- [x] T004 Implement `QiblaService` including: Haversine formula (`haversineKm`), `cardinalFromDegrees` helper (8-direction mapping per research.md §8), AlAdhan API call (`GET https://api.aladhan.com/v1/qibla/{lat}/{lon}` via `dio`), SharedPreferences cache read/write (5 keys: `qibla_direction`, `qibla_city`, `qibla_distance_km`, `qibla_ref_lat`, `qibla_ref_lon`), and 50 km cache invalidation check in `lib/features/qibla/data/services/qibla_service.dart`
- [x] T005 Implement `MosqueService` with `findNearest(double lat, double lon)` returning `Future<MosqueModel?>` — POST query to `https://overpass-api.de/api/interpreter` (query template from contracts/qibla_api.md), parse first element, compute Haversine distance, return `null` on timeout/empty/error in `lib/features/qibla/data/services/mosque_service.dart`
- [x] T006 Create all Riverpod providers: `qiblaLocationProvider` (FutureProvider<Position> using `LocationService.getCurrentPosition()`, separate from prayer times location), `qiblaModelProvider` (FutureProvider<QiblaModel> using cache-or-fetch logic), `compassHeadingProvider` (StreamProvider<double> from `FlutterCompass.events` with low-pass smoothing α=0.15 + wrap-around fix), `compassAccuracyProvider` (StreamProvider<AccuracyLevel> mapping raw accuracy), `qiblaRotationProvider` (Provider<double> derived as `(direction - heading + 360) % 360`), `nearestMosqueProvider` (FutureProvider<MosqueModel?> via MosqueService), `cityNameProvider` (FutureProvider<String> via `placemarkFromCoordinates`, fallback to coordinate string) in `lib/features/qibla/providers/qibla_providers.dart`
- [x] T007 [P] Write unit tests covering: `haversineKm(Cairo, Mecca)` ≈ 1240 km (±10), `haversineKm(Cairo, Alexandria)` < 50 km → cache-hit branch, `haversineKm(Cairo, London)` > 50 km → cache-miss branch, `cardinalFromDegrees(136.0)` → `"SE"`, `cardinalFromDegrees(0.0)` → `"N"`, `cardinalFromDegrees(359.9)` → `"N"` in `test/unit/qibla_service_test.dart`
- [x] T008 [P] Write unit tests for `AccuracyLevel` mapping: iOS accuracy `-1` → low, `3.0` → high, `12.0` → medium; Android accuracy `0` → low, `2` → medium, `3` → high; `null` → low in `test/unit/qibla_service_test.dart` (append to same file as T007)

**Checkpoint**: All foundational tests pass (`flutter test test/unit/qibla_service_test.dart`). Models, services, and providers compile with no errors.

---

## Phase 3: US-1 + US-5 (Priority: P1) 🎯 MVP

**Goal**: User opens the Qibla tab and sees either (a) a real-time animated compass rose with the Qibla needle always pointing toward Mecca, or (b) a clear, actionable error state — never a blank screen. Covers US-1 (live compass) and US-5 (permission denied / no compass sensor / API error / offline + no cache).

**Independent Test**: Open Qibla tab with permission granted, rotate device 360° — needle consistently points in the same real-world direction. Revoke location permission — permission request card appears immediately without app restart. Run on sensor-less emulator — static direction + "لا يوجد بوصلة" message shown.

### Implementation for US-1 + US-5

- [x] T009 [P] [US1] Create `CompassWidget` (StatelessWidget): takes `double rotationTurns` and `AccuracyLevel accuracy`; renders circular compass rose with cardinal labels, golden Ka'ba icon center, Qibla needle via `AnimatedRotation(turns: rotationTurns, duration: Duration(milliseconds: 150))`; size ~280 px diameter using `AppColors.primaryGreen` background + `AppColors.gold` accent in `lib/features/qibla/presentation/widgets/compass_widget.dart`
- [x] T010 [P] [US1] Create `QiblaDirectionBadge` (StatelessWidget): takes `double degrees`; renders cardinal abbreviation + Arabic-Indic degree string (e.g., "SE ١٣٥°") in a gold-bordered pill widget in `lib/features/qibla/presentation/widgets/qibla_direction_badge.dart`
- [x] T011 [US1] [US5] Replace the `QiblaScreen` stub in `lib/features/qibla/presentation/qibla_screen.dart` with a full `ConsumerWidget` that: (1) watches `qiblaLocationProvider` — if `LocationException('permission_denied')` emitted, show permission request card with re-check button; (2) watches `compassHeadingProvider` — if `null` heading for > 3 s, treats as no-sensor and shows static fallback with "لا يوجد بوصلة على هذا الجهاز" message; (3) watches `qiblaModelProvider` — if error + no cache, shows error banner with compass hidden; if error + cached, shows compass with "آخر تحديث" badge; (4) on all-data success, renders `CompassWidget` (using `qiblaRotationProvider`) + `QiblaDirectionBadge`; (5) all loading states show skeleton/shimmer placeholders (FR-016)
- [x] T012 [P] [US1] [US5] Write widget tests for `CompassWidget`: rotation `0.5` turns renders `AnimatedRotation` with `turns: 0.5`; `AccuracyLevel.low` shows "دقة منخفضة" badge; `AccuracyLevel.high` shows "دقة عالية" badge; no-sensor mode shows static indicator in `test/widget/compass_widget_test.dart`

**Checkpoint**: Open app on physical device → Qibla tab → compass needle visible and rotates with device. Revoke permission → permission card appears. Run on emulator → "لا يوجد بوصلة" message shown. `flutter test test/widget/compass_widget_test.dart` passes.

---

## Phase 4: US-2 (Priority: P1)

**Goal**: Below the app bar, the user sees their city name and country. Below the compass, two stats cards show the exact Qibla bearing angle and distance to Mecca. Both load with skeleton placeholders while data is fetching.

**Independent Test**: Open Qibla screen from Cairo — city chip reads "القاهرة، مصر", distance card ≈ ١٬٢٤٠ كم (within ±10 km), angle card matches the fetched Qibla bearing (±1°). Offline with cache: city chip shows last cached city; stats show last cached values.

### Implementation for US-2

- [x] T013 [P] [US2] Create `QiblaStatsRow` (StatelessWidget): takes `double? distanceKm` and `double? angleDegrees`; renders two side-by-side cards ("المسافة التلقائية" with location icon; "زاوية الاتجاه" with compass icon); values formatted as Arabic-Indic numerals; shows shimmer placeholders when `null` in `lib/features/qibla/presentation/widgets/qibla_stats_row.dart`
- [x] T014 [US2] Update `QiblaScreen` in `lib/features/qibla/presentation/qibla_screen.dart` to: (1) add location chip row below app bar watching `cityNameProvider` (shimmer if loading); (2) add `QiblaStatsRow` below `QiblaDirectionBadge`, passing `qiblaModelProvider.value?.distanceKm` and `qiblaModelProvider.value?.direction`

**Checkpoint**: Open Qibla screen — city chip, distance card, and angle card all render with correct values. Skeleton placeholders visible during initial load.

---

## Phase 5: US-3 (Priority: P2)

**Goal**: A persistent accuracy badge (Low / Medium / High) is always visible in the compass area. A calibration hint row is always visible below the stats cards; it becomes visually more prominent when accuracy is low.

**Independent Test**: Open Qibla screen — accuracy badge is always present in the compass area regardless of accuracy level. Calibration hint row visible below stats. When `AccuracyLevel.low` is active, hint row has a highlighted/warning style.

### Implementation for US-3

- [x] T015 [P] [US3] Create `CalibrationHint` (StatelessWidget): takes `AccuracyLevel accuracy`; always renders a row with a shake icon and text "حرك هاتفك على شكل رقم (8) لزيادة دقة البوصلة"; when `accuracy == AccuracyLevel.low`, renders with a gold warning border and warning icon for visual prominence (FR-009) in `lib/features/qibla/presentation/widgets/calibration_hint.dart`
- [x] T016 [US3] Update `CompassWidget` in `lib/features/qibla/presentation/widgets/compass_widget.dart` to display the persistent accuracy badge (`AccuracyLevel` → Arabic label + color tint) inside the compass area — overlaid at the bottom of the circular widget (FR-009a)
- [x] T017 [US3] Update `QiblaScreen` in `lib/features/qibla/presentation/qibla_screen.dart` to add `CalibrationHint` widget below `QiblaStatsRow`, passing `compassAccuracyProvider` value

**Checkpoint**: Open Qibla screen — accuracy badge visible inside compass; calibration hint row visible below stats. Accuracy badge correctly reflects sensor state (Low/Medium/High).

---

## Phase 6: US-4 (Priority: P3)

**Goal**: When the device is online and a mosque is found within 2 km, a "أقرب مسجد إليك" card appears at the bottom with the mosque name, formatted distance, and an "انتقل" button that opens the native maps app. The card is absent when offline or when the query fails.

**Independent Test**: Open Qibla screen with network in a populated area — mosque card appears with name + distance. Tap "انتقل" — native maps app opens with mosque location. Enable airplane mode and reopen — mosque card is absent entirely.

### Implementation for US-4

- [x] T018 [P] [US4] Create `NearestMosqueCard` (StatelessWidget): takes `MosqueModel mosque`; renders card with title "أقرب مسجد إليك", mosque `nameAr`, formatted distance, and "انتقل" `OutlinedButton`; button calls `launchUrl(Uri.parse(mosque.mapsUrl), mode: LaunchMode.externalApplication)` with `canLaunchUrl` check; if `canLaunchUrl` returns false, falls back to `https://maps.google.com/maps?q={lat},{lon}`; on failure shows `SnackBar` "لا يوجد تطبيق خرائط متاح" in `lib/features/qibla/presentation/widgets/nearest_mosque_card.dart`
- [x] T019 [US4] Update `QiblaScreen` in `lib/features/qibla/presentation/qibla_screen.dart` to: watch `nearestMosqueProvider`; show `NearestMosqueCard` when value is non-null; show shimmer skeleton while loading; show nothing (card entirely absent) when value is null or error — satisfying FR-010 (hidden when offline/failed)

**Checkpoint**: Open Qibla screen online → mosque card appears. Tap "انتقل" → maps opens. Enable airplane mode → card absent. Query with 0 results (remote area) → card absent.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Platform config verification, edge cases, and full test suite pass.

- [x] T020 [P] Verify `ios/Runner/Info.plist` already contains `NSLocationWhenInUseUsageDescription` (from geolocator); add `NSLocationAlwaysAndWhenInUseUsageDescription` key if not present for mid-session revocation detection; verify `geocoding` needs no additional `Info.plist` entries (it reuses the location permission already declared)
- [x] T021 [P] Verify `android/app/src/main/AndroidManifest.xml` has `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions already declared (from geolocator); no new permissions are needed for `geocoding` on Android
- [x] T022 Update `lib/features/qibla/providers/qibla_providers.dart`: ensure `qiblaLocationProvider` catches `Geolocator.getServiceStatusStream()` service-disabled events and maps them to a `LocationException('permission_denied')` so that mid-session revocation causes `QiblaScreen` to switch to the permission request card (spec clarification 2026-06-29 US-5 scenario 3)
- [x] T023 [P] Run full test suite `flutter test` and confirm `test/unit/qibla_service_test.dart` + `test/widget/compass_widget_test.dart` all pass; fix any failures
- [x] T024 [P] Run quickstart.md Scenarios 1–7 manually on a physical device to validate all acceptance scenarios from spec.md; note any deviations

**Checkpoint**: All 7 quickstart scenarios pass on a physical device. `flutter test` exits with 0 failures.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user story phases
- **US-1+US-5 (Phase 3)**: Depends on Phase 2 completion — MVP deliverable
- **US-2 (Phase 4)**: Depends on Phase 2 completion — can overlap with Phase 3 on different files
- **US-3 (Phase 5)**: Depends on Phase 3 completion (needs `CompassWidget` from T009)
- **US-4 (Phase 6)**: Depends on Phase 2 completion — independent of Phases 3–5
- **Polish (Phase 7)**: Depends on all user story phases

### User Story Dependencies

| Story | Depends On | Can Parallelize With |
|-------|-----------|---------------------|
| US-1 + US-5 (Phase 3) | Phase 2 | US-2 (Phase 4), US-4 (Phase 6) |
| US-2 (Phase 4) | Phase 2 | US-1+US-5 (Phase 3), US-4 (Phase 6) |
| US-3 (Phase 5) | Phase 3 (needs CompassWidget) | US-4 (Phase 6) |
| US-4 (Phase 6) | Phase 2 | US-1+US-5 (Phase 3), US-2 (Phase 4), US-3 (Phase 5) |

### Within Each Phase

- Models before services (T002/T003 before T004/T005)
- Services before providers (T004/T005 before T006)
- Providers before screen (T006 before T011)
- Tests marked [P] can run alongside their implementation tasks (write tests, then implement)

---

## Parallel Opportunities

### Phase 2 Parallel Launch

```
Parallel group A (same time):
  T002 — QiblaModel + AccuracyLevel (qibla_model.dart)
  T003 — MosqueModel (mosque_model.dart)

Then T004 → T005 → T006 (sequential: each depends on models above)

Parallel group B (same time, alongside T004–T006):
  T007 — Unit tests Haversine + cardinal direction
  T008 — Unit tests AccuracyLevel mapping
```

### Phase 3 Parallel Launch

```
Parallel group (same time):
  T009 — CompassWidget (compass_widget.dart)
  T010 — QiblaDirectionBadge (qibla_direction_badge.dart)

Then T011 (QiblaScreen — depends on T009+T010)
Then T012 (widget tests — depends on T009)
```

### Phases 4 + 6 Parallel Launch (after Phase 2)

```
Parallel:
  Phase 4 stream: T013 → T014
  Phase 6 stream: T018 → T019
```

---

## Implementation Strategy

### MVP First (US-1 + US-5 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002–T008)
3. Complete Phase 3: US-1 + US-5 (T009–T012)
4. **STOP and VALIDATE**: Rotate device → needle tracks Mecca. Permission denied → permission card. No sensor → fallback message.
5. Deliverable: Working real-time Qibla compass

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. + US-1/US-5 → Working compass with error handling (MVP!)
3. + US-2 → City name + stats cards
4. + US-3 → Accuracy badge + calibration hint
5. + US-4 → Nearest mosque navigation
6. + Polish → All quickstart scenarios pass

---

## Notes

- `[P]` tasks touch different files — safe to run simultaneously
- `[Story]` label traces each task back to its user story for spec validation
- `qibla_screen.dart` replaces the existing stub — do not delete other files in the presentation directory (`tasbih_screen.dart` belongs to the adhkar feature and must not be modified)
- No `main.dart` changes needed — SharedPreferences initializes lazily; no new Hive adapters or boxes required
- `qibla_ref_lat`/`qibla_ref_lon` in SharedPreferences are API input coordinates for cache invalidation — they are not a GPS history and comply with FR-019 (no raw GPS in persistent storage interpreted as: no user location history)
- All Arabic text must use Arabic-Indic numerals (٠١٢٣...) via the project's `TimeFormatter.toIndicDigits()` helper or equivalent
