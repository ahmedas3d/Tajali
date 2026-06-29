# Tasks: Notifications & Settings (إشعارات الأذان والإعدادات)

**Input**: Design documents from `specs/009-notifications-settings/`

**Prerequisites**: [plan.md](plan.md) · [spec.md](spec.md) · [research.md](research.md) · [data-model.md](data-model.md) · [quickstart.md](quickstart.md)

**Tests**: Not explicitly requested — no test tasks generated.

**Organization**: Tasks are grouped by user story. The notification engine (Phases 1–2) must complete before any UI work.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: User story this task belongs to (US1–US6)

---

## Phase 1: Setup (Dependency Verification)

**Purpose**: Verify all required packages are present before engine work begins.

- [X] T001 Verify `permission_handler` is in `pubspec.yaml`; add if missing (needed for `Permission.notification.status` and `openAppSettings()`)
- [X] T002 [P] Verify `url_launcher` is in `pubspec.yaml`; add if missing (needed for store links in General section)
- [X] T003 [P] Verify `share_plus` is in `pubspec.yaml`; add if missing (needed for "مشاركة التطبيق")
- [X] T004 [P] Verify `package_info_plus` is in `pubspec.yaml`; add if missing (needed for version number in Settings footer)

**Checkpoint**: Run `flutter pub get` — no resolution errors.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: New enums, providers, and service signatures that every subsequent phase depends on.

⚠️ **CRITICAL**: No user story work can begin until this phase is complete.

- [X] T005 Add `FiqhSchool` enum (`shafii`, `hanafi`) and `fiqhSchoolProvider` (`StateProvider<FiqhSchool>`, default `FiqhSchool.shafii`) to `lib/features/prayer_times/providers/prayer_times_providers.dart`
- [X] T006 Add `loadSavedFiqhSchool()` and `saveFiqhSchool()` helpers (SharedPreferences key `fiqh_school`) to `lib/features/prayer_times/providers/prayer_times_providers.dart`
- [X] T007 Add 5 per-prayer `StateProvider<bool>` instances (`prayerNotifFajrProvider`, `prayerNotifDhuhrProvider`, `prayerNotifAsrProvider`, `prayerNotifMaghribProvider`, `prayerNotifIshaProvider`) with defaults `true` to `lib/features/prayer_times/providers/prayer_times_providers.dart`
- [X] T008 Add `loadSavedPrayerNotif(String prayerKey)` and `savePrayerNotif(String prayerKey, bool value)` helpers (keys: `prayer_notif_fajr` … `prayer_notif_isha`) to `lib/features/prayer_times/providers/prayer_times_providers.dart`
- [X] T009 Add `Madhab madhab = Madhab.shafi` optional parameter to `PrayerCalculationService.calculate()` and `rawTimes()` in `lib/features/prayer_times/data/services/prayer_calculation_service.dart`; assign to `params.madhab` before constructing `PrayerTimes`
- [X] T010 Add `fiqhSchoolProvider` as a watched dependency in `prayerTimesProvider` (alongside `calculationMethodProvider`) in `lib/features/prayer_times/providers/prayer_times_providers.dart`; map `FiqhSchool → Madhab` and pass to `_calcService.calculate()`
- [X] T011 Load and inject all new saved values at startup: add `loadSavedFiqhSchool()` + 5× `loadSavedPrayerNotif()` calls to `main.dart` and include them in `ProviderScope` `overrides` list

**Checkpoint**: `flutter analyze` passes. Hot-reload app — no provider errors in console.

---

## Phase 3: User Story 1 — Enable Adhan Notifications (Priority: P1) 🎯 MVP

**Goal**: Per-prayer notification scheduling that covers today + tomorrow, using per-prayer toggle states.

**Independent Test**: Open app → all 5 prayer toggles are ON by default → use test button → notification fires with sound after 10s.

- [X] T012 [US1] Update `AdhanNotificationService._schedule()` in `lib/core/services/adhan_notification_service.dart` to accept a `dayOffset` parameter (`0` = today, `1` = tomorrow) and apply it when building the `TZDateTime` for the notification ID (use ID + 10 offset for tomorrow: e.g. Fajr today=100, Fajr tomorrow=110)
- [X] T013 [US1] Update `AdhanNotificationService.cancelAll()` in `lib/core/services/adhan_notification_service.dart` to also cancel the tomorrow-offset IDs (100–116 range)
- [X] T014 [US1] Add `AdhanNotificationService.cancelPrayer(int todayId)` in `lib/core/services/adhan_notification_service.dart` that cancels both the today ID and the tomorrow ID (todayId + 10)
- [X] T015 [US1] Update `adhanSchedulerProvider` in `lib/features/prayer_times/providers/prayer_times_providers.dart` to: (1) watch all 5 per-prayer providers, (2) calculate rawTimes for both today and tomorrow using `_calcService.rawTimes()` with `date + 1 day`, (3) call `buildEntries` for each day, (4) filter entries by their prayer's toggle state, (5) call `schedulePrayerNotifications` with the combined list

**Checkpoint**: Quickstart Scenario 2 passes — toggle OFF a prayer, restart app, toggle stays OFF. Test notification fires.

---

## Phase 4: User Story 2 — Choose Adhan Sound (Priority: P1)

**Goal**: Sound source selection persists and drives both in-app playback and notification sound.

**Independent Test**: Select Egyptian Radio → tap test button → hear Egyptian adhan immediately + notification uses Egyptian sound after 10s.

- [X] T016 [US2] Confirm `adhanSoundProvider` and `saveAdhanSound()` already exist in `lib/features/prayer_times/providers/prayer_times_providers.dart` and that `adhanSchedulerProvider` passes `source:` to `schedulePrayerNotifications`; if any wiring is missing, complete it now
- [X] T017 [US2] Confirm `PrayerTimesScreen` foreground adhan playback in `lib/features/prayer_times/presentation/prayer_times_screen.dart` reads `adhanSoundProvider` and passes correct `AdhanSound` to `AdhanAudioService.instance.play()`; fix any gap found

**Checkpoint**: Quickstart Scenario 4 passes — switching sound source changes both in-app audio and scheduled notification sound.

---

## Phase 5: User Story 3 — Redesigned Settings Screen (Priority: P2)

**Goal**: Settings screen renders with welcome card, three grouped sections, trailing value chips, and bottom sheet pickers for all option rows.

**Independent Test**: Open Settings → welcome card visible, all 3 section headers visible, each row shows its current value as a trailing chip.

- [X] T018 [P] [US3] Create `SettingsSectionHeader` widget (gold label + full-width divider below) in `lib/features/settings/presentation/widgets/settings_section_header.dart`
- [X] T019 [P] [US3] Create `SettingsWelcomeCard` widget (dark-green `#1B4332` background, moon icon, "أهلاً وسهلاً" heading in ivory Amiri, subtitle in ivory 75%) in `lib/features/settings/presentation/widgets/settings_welcome_card.dart`
- [X] T020 [P] [US3] Create `SettingsValueRow` widget (label text + trailing `Text` chip in muted grey + chevron icon + `onTap` callback) in `lib/features/settings/presentation/widgets/settings_value_row.dart`
- [X] T021 [P] [US3] Create `SettingsToggleRow` widget (label text + Flutter `Switch` widget with `AppColors.primaryGreen` active color + `onChanged` callback) in `lib/features/settings/presentation/widgets/settings_toggle_row.dart`
- [X] T022 [P] [US3] Create `SettingsLinkRow` widget (leading `IconData`, label text, trailing chevron, `onTap` callback) in `lib/features/settings/presentation/widgets/settings_link_row.dart`
- [X] T023 [US3] Rewrite `SettingsScreen` in `lib/features/settings/presentation/settings_screen.dart` using new widgets: (1) `SettingsWelcomeCard` at top, (2) "الصلاة والمواقيت" section with `SettingsValueRow` rows for calculation method, fiqh school, and sound source — each opens a `showModalBottomSheet` with radio-list options, (3) placeholder "تنبيهات الأذان" sub-section header (toggles wired in US4), (4) "القرآن الكريم" section with reciter row placeholder (wired in US5), (5) "عام" section with `SettingsLinkRow` rows
- [X] T024 [US3] Implement calculation method bottom sheet inside `SettingsScreen`: list all `CalculationMethodConfig.all` entries, show checkmark on selected, call `_selectMethod()` on tap, dismiss sheet in `lib/features/settings/presentation/settings_screen.dart`
- [X] T025 [US3] Implement fiqh school bottom sheet inside `SettingsScreen`: two options (الشافعي / الحنفي), persist via `saveFiqhSchool()`, update `fiqhSchoolProvider`, dismiss sheet in `lib/features/settings/presentation/settings_screen.dart`
- [X] T026 [US3] Implement sound source bottom sheet inside `SettingsScreen`: two options (المسجد الحرام / إذاعة القرآن), persist via `saveAdhanSound()`, update `adhanSoundProvider`, dismiss sheet in `lib/features/settings/presentation/settings_screen.dart`
- [X] T027 [US3] Implement "عام" section rows in `SettingsScreen`: language (display-only "العربية ›"), تقييم التطبيق (show "قريباً" snackbar), مشاركة التطبيق (show "قريباً" snackbar), سياسة الخصوصية (show "قريباً" snackbar), من نحن (navigate to `AboutScreen`) in `lib/features/settings/presentation/settings_screen.dart`
- [X] T028 [US3] Create `AboutScreen` in `lib/features/settings/presentation/about_screen.dart`: show app logo, app name "تجلّي", version number from `PackageInfo`, developer credit in Amiri font on parchment background with a back button
- [X] T029 [US3] Add `AboutScreen` route and `SettingsScreen` navigation call in `lib/app/routes.dart` (or inline `Navigator.push` from `SettingsScreen`)
- [X] T030 [US3] Add Settings footer to `SettingsScreen`: centered "تجلّي v[version]" text in muted gold using `PackageInfo.fromPlatform()` in `lib/features/settings/presentation/settings_screen.dart`

**Checkpoint**: Quickstart Scenario 1 passes — full settings screen renders; all 3 sections visible; tapping a value row opens a bottom sheet; selecting an option updates the trailing chip.

---

## Phase 6: User Story 4 — Disable Individual Prayer Notifications (Priority: P2)

**Goal**: Each of the 5 prayers has its own toggle in the "تنبيهات الأذان" sub-section. Toggling a prayer cancels or reschedules only that prayer.

**Independent Test**: Turn OFF الظهر toggle → force-quit → reopen → الظهر toggle is still OFF → other prayers still receive notifications.

- [X] T031 [US4] Create `SettingsPermissionBanner` widget in `lib/features/settings/presentation/widgets/settings_permission_banner.dart`: amber/orange background card, "الإشعارات معطّلة" text, "افتح الإعدادات" `TextButton` that calls `openAppSettings()` from `permission_handler`; uses `AppLifecycleListener` (Flutter 3.13+) in its `State` to re-check `Permission.notification.status` on `onResume` and hide itself when permission is granted
- [X] T032 [US4] Add the "تنبيهات الأذان" sub-section to `SettingsScreen` in `lib/features/settings/presentation/settings_screen.dart`: insert `SettingsPermissionBanner` (conditionally shown), then 5 `SettingsToggleRow` rows (الفجر, الظهر, العصر, المغرب, العشاء) each watching its respective `prayerNotif*Provider` and calling `savePrayerNotif()` + updating the provider on change
- [X] T033 [US4] Wire per-prayer toggle changes to immediate notification update in `SettingsScreen._setNotifToggle()` in `lib/features/settings/presentation/settings_screen.dart`: when a prayer is turned OFF, call `AdhanNotificationService.cancelPrayer(prayerId)`; when turned ON, trigger `ref.invalidate(prayerTimesProvider)` to force `adhanSchedulerProvider` to reschedule

**Checkpoint**: Quickstart Scenario 2 (persistence test) and Scenario 6 (permission banner) pass.

---

## Phase 7: User Story 6 — Adhan Test Buttons (Priority: P2)

**Goal**: Test buttons in the redesigned settings screen play sound immediately and schedule a notification using the current sound source.

**Independent Test**: Tap "اختبر أذان الفجر" → Fajr adhan plays immediately → notification arrives with Fajr sound in 10 seconds.

- [X] T034 [US6] Add two test buttons ("اختبر أذان الصلاة" and "اختبر أذان الفجر") to the bottom of the "الصلاة والمواقيت" section in the redesigned `SettingsScreen` in `lib/features/settings/presentation/settings_screen.dart`; `_testAdhan()` method must read `adhanSoundProvider` and pass correct `AdhanSound` enum value to `AdhanAudioService.instance.play()` and correct `AdhanSoundSource` to `AdhanNotificationService.testNow()`

**Checkpoint**: Quickstart Scenario 2 quick test passes — tap test button → in-app adhan plays within 1s → notification arrives at ~10s.

---

## Phase 8: User Story 5 — Preferred Quran Reciter (Priority: P3)

**Goal**: Reciter set in Settings pre-populates the Quran reader screen.

**Independent Test**: Set reciter to الحصري in Settings → open any surah → الحصري is pre-selected.

- [X] T035 [US5] Add "القارئ المفضل" `SettingsValueRow` to the "القرآن الكريم" section of `SettingsScreen` in `lib/features/settings/presentation/settings_screen.dart`; trailing chip shows `ReciterModel.byIdentifier(selectedReciter).nameAr`
- [X] T036 [US5] Implement reciter picker bottom sheet in `SettingsScreen`: list all `ReciterModel.reciters`, show checkmark on current selection, on tap call `saveReciter()` from `lib/features/quran/providers/reader_providers.dart` and `ref.read(selectedReciterProvider.notifier).state = id` in `lib/features/settings/presentation/settings_screen.dart`

**Checkpoint**: Quickstart Scenario 7 passes — changing reciter in Settings changes the pre-selected reciter in Quran reader.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final integration verification and cleanup.

- [X] T037 Remove `_NotifTile` widget and old three-mode notification section from `lib/features/settings/presentation/settings_screen.dart` if any remnants remain after the rewrite
- [ ] T038 [P] Remove `notificationModeProvider` usages from `lib/features/prayer_times/providers/prayer_times_providers.dart` and `lib/features/prayer_times/presentation/prayer_times_screen.dart` if superseded by per-prayer toggles; or retain as deprecated no-op if referenced elsewhere
- [X] T039 [P] Remove `calculation_method_tile.dart` standalone widget from `lib/features/settings/presentation/widgets/calculation_method_tile.dart` if fully replaced by the inline bottom sheet in `SettingsScreen`; update any imports
- [ ] T040 Run all quickstart.md validation scenarios (Scenarios 1–9) and confirm each passes
- [X] T041 Run `flutter analyze` — confirm zero errors and no new warnings introduced by this feature

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately; all tasks run in parallel
- **Phase 2 (Foundational)**: Depends on Phase 1 — **blocks all user story phases**
- **Phase 3 (US1)**: Depends on Phase 2
- **Phase 4 (US2)**: Depends on Phase 2; can run in parallel with Phase 3
- **Phase 5 (US3)**: Depends on Phase 2; can run in parallel with Phases 3–4
- **Phase 6 (US4)**: Depends on Phase 5 (needs redesigned screen widgets)
- **Phase 7 (US6)**: Depends on Phase 5 (needs redesigned screen)
- **Phase 8 (US5)**: Depends on Phase 5 (needs redesigned screen)
- **Phase 9 (Polish)**: Depends on all preceding phases

### User Story Dependencies

| Story | Depends On | Can Parallelize With |
|-------|-----------|---------------------|
| US1 (P1) | Phase 2 | US2, US3 |
| US2 (P1) | Phase 2 | US1, US3 |
| US3 (P2) | Phase 2 | US1, US2 |
| US4 (P2) | US3 (screen widgets) | US6, US5 |
| US6 (P2) | US3 (screen widgets) | US4, US5 |
| US5 (P3) | US3 (screen widgets) | US4, US6 |

### Within Each Phase

- Models / providers before services
- Services before UI
- Widget library before screen rewrite (T018–T022 before T023)
- Screen rewrite before per-prayer toggle integration

---

## Parallel Execution Examples

### Phase 2 (Foundational) — run together

```
T005: Add FiqhSchool enum + fiqhSchoolProvider
T007: Add 5 prayerNotif*Provider instances
T009: Add madhab param to PrayerCalculationService
```
Then sequentially: T006, T008, T010, T011

### Phase 5 (US3 Widget Library) — run all together

```
T018: SettingsSectionHeader
T019: SettingsWelcomeCard
T020: SettingsValueRow
T021: SettingsToggleRow
T022: SettingsLinkRow
```
Then sequentially: T023 → T024 → T025 → T026 → T027 → T028 → T029 → T030

### Phase 3 + 4 + 5 — all can start simultaneously after Phase 2

```
Developer A: Phase 3 (US1) — notification engine
Developer B: Phase 4 (US2) — sound verification
Developer C: Phase 5 (US3) — settings screen widgets
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 (Setup) — 4 tasks
2. Complete Phase 2 (Foundational) — 7 tasks
3. Complete Phase 3 (US1) — 4 tasks
4. **STOP and VALIDATE**: Quickstart Scenario 2 — notifications fire per-prayer
5. Notifications work end-to-end without UI redesign

### Incremental Delivery

1. Phases 1–2 → engine ready
2. Phase 3 (US1) → per-prayer notifications work ✓
3. Phase 4 (US2) → sound selection confirmed end-to-end ✓
4. Phase 5 (US3) → new settings screen with pickers ✓
5. Phase 6 (US4) → prayer toggles visible in new screen ✓
6. Phase 7 (US6) → test buttons work in new screen ✓
7. Phase 8 (US5) → reciter preference wired ✓
8. Phase 9 → polish and analysis clean ✓

---

## Notes

- `[P]` tasks touch different files — safe to implement concurrently
- `[Story]` label maps each task to its user story for traceability
- `adhanSoundProvider`, `saveAdhanSound()`, and basic notification scheduling are already partially implemented from a prior session — T016 and T017 are verification-first tasks
- `notificationModeProvider` (old 3-mode enum) should be retired carefully — check for usages before removing (T038)
- `AppLifecycleListener` requires Flutter 3.13+; confirm SDK constraint in `pubspec.yaml` is `>=3.13.0` before T031
