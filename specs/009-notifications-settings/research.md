# Research: Notifications & Settings

**Date**: 2026-06-29 | **Plan**: [plan.md](plan.md)

---

## Decision 1 — Per-Prayer Notification Architecture

**Decision**: 5 independent `StateProvider<bool>` instances, each backed by a separate SharedPreferences key (`prayer_notif_fajr`, etc.).

**Rationale**: Riverpod's `StateProvider` is the lightest option for a single boolean that needs to be watched by the scheduler. Storing each prayer independently means toggling Dhuhr only cancels/reschedules Dhuhr's notification ID — no need to rebuild the full 10-notification batch. `AdhanNotificationService.cancelAll()` already iterates over known IDs; a new `cancelPrayer(int id)` method is added alongside it.

**Alternatives considered**:
- Single `Map<Prayer, bool>` provider — requires custom serialization and a `StateNotifier`; overkill for 5 booleans.
- `NotificationMode` enum (fullSound/silent/disabled) — too coarse; rejected by clarification Q1.

---

## Decision 2 — 2-Day-Ahead Scheduling

**Decision**: On every app open, `adhanSchedulerProvider` cancels all existing prayer notifications and reschedules for today + tomorrow for every enabled prayer.

**Rationale**: `flutter_local_notifications` `zonedSchedule` fires once at the given `TZDateTime`. To cover tomorrow without background execution, schedule both days upfront. `buildEntries()` already skips past times, so today's already-passed prayers are filtered automatically. A user who opens the app at least once every 48 hours is fully covered.

**Implementation**:
```
adhanSchedulerProvider:
  1. get today's rawTimes (already done)
  2. get tomorrow's rawTimes (date + 1 day)
  3. buildEntries for today (skips past) + buildEntries for tomorrow
  4. concatenate, call schedulePrayerNotifications(combined, source)
```

**Alternatives considered**:
- Background Fetch / AlarmManager — rejected (Q2); requires extra permissions, unreliable on iOS.
- Schedule 7 days ahead — unnecessary complexity; 2 days is sufficient if user opens app regularly (standard for Islamic apps like Muslim Pro).

---

## Decision 3 — Madhab / Fiqh School Wiring

**Decision**: Extend `PrayerCalculationService.calculate()` and `rawTimes()` with an optional `Madhab madhab = Madhab.shafi` parameter. Assign it to `CalculationParameters.madhab` before constructing `PrayerTimes`.

**Rationale**: The `adhan` package (v2.0.0+1) already exports `Madhab` enum with `.shafi` and `.hanafi` values, and `CalculationParameters` exposes a `.madhab` field. The change is 2 lines in the calculation service. `fiqhSchoolProvider` maps `FiqhSchool.shafii → Madhab.shafi` and `FiqhSchool.hanafi → Madhab.hanafi`. `prayerTimesProvider` watches both `calculationMethodProvider` and `fiqhSchoolProvider`, so changing either invalidates and recalculates.

**FiqhSchool enum** (new, in `prayer_times_providers.dart`):
```dart
enum FiqhSchool { shafii, hanafi }
final fiqhSchoolProvider = StateProvider<FiqhSchool>((ref) => FiqhSchool.shafii);
```

**Alternatives considered**:
- Pass `school` as `int` (0/1) — less type-safe; enum matches the adhan package style.

---

## Decision 4 — Settings Screen Widget Architecture

**Decision**: Decompose `settings_screen.dart` into 6 small stateless widgets. `SettingsScreen` only assembles them.

| Widget | Purpose |
|--------|---------|
| `SettingsWelcomeCard` | Dark-green header with greeting + moon icon |
| `SettingsSectionHeader` | Gold label + divider separator |
| `SettingsValueRow` | Tappable row with label + trailing chip; opens bottom sheet via `onTap` callback |
| `SettingsToggleRow` | Row with label + `Switch`; calls `onChanged` callback |
| `SettingsLinkRow` | Row with icon + label + chevron; calls `onTap` callback |
| `SettingsPermissionBanner` | Amber warning card with "افتح الإعدادات" button |

**Rationale**: Each widget is independently testable with `flutter_test`. `SettingsScreen` stays under ~120 lines. Bottom sheets are opened inline via `showModalBottomSheet` — no separate routes needed.

**Alternatives considered**:
- Single monolithic `SettingsScreen` — was the previous approach; hard to test individual rows.
- Push routes for each picker — rejected (Q3); modal bottom sheet is the correct pattern for 2–5 item lists.

---

## Decision 5 — Permission Banner + AppLifecycleListener

**Decision**: `SettingsPermissionBanner` uses `AppLifecycleListener` (Flutter 3.13+) to re-check `Permission.notification.status` when the app resumes. The banner auto-hides when status is `PermissionStatus.granted`.

**Rationale**: iOS and Android require the user to leave the app to grant notification permission in system settings. `AppLifecycleListener.onResume` is the right hook to detect the return. The `permission_handler` package is already used in the app (onboarding permission request).

**Implementation sketch**:
```dart
class _SettingsPermissionBannerState extends State<SettingsPermissionBanner> {
  late AppLifecycleListener _listener;
  bool _denied = false;

  @override void initState() {
    super.initState();
    _checkPermission();
    _listener = AppLifecycleListener(onResume: _checkPermission);
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    setState(() => _denied = !status.isGranted);
  }

  @override void dispose() { _listener.dispose(); super.dispose(); }
}
```

**Alternatives considered**:
- Dialog on toggle tap — rejected (Q5); intrusive and blocks the UI.
- Snackbar — rejected (Q5); too easy to miss.

---

## Decision 6 — Reciter Preference Bridge

**Decision**: `SettingsScreen` imports `selectedReciterProvider` and `saveReciter()` directly from `lib/features/quran/providers/reader_providers.dart`. No new provider or persistence key.

**Rationale**: The reciter provider already persists to SharedPreferences key `quran_selected_reciter` and pre-populates the Quran reader. The Settings screen is just a new access point to the same state. Cross-feature provider access is acceptable in Riverpod with a clear import path.

**Alternatives considered**:
- Duplicate the reciter provider in `settings/` — rejected; creates two sources of truth.
- Move reciter provider to a shared `core/` location — valid refactor but out of scope for this phase.

---

## Decision 7 — `url_launcher` for System Settings Deep-Link

**Decision**: Use `url_launcher`'s `openAppSettings()` (from `permission_handler`) for "افتح الإعدادات". Use `launchUrl(Uri.parse('market://details?id=...'))` for "تقييم التطبيق" (Android) and `launchUrl(Uri.parse('https://apps.apple.com/...'))` for iOS. Use `Share.share()` (from `share_plus`) for "مشاركة التطبيق".

**Rationale**: `permission_handler` already provides `openAppSettings()`. `url_launcher` and `share_plus` are standard Flutter packages for store links and sharing. Check pubspec for both; add if missing.

**Fallback**: If store URLs are not yet available, tapping "تقييم التطبيق" and "مشاركة التطبيق" shows a `SnackBar` with "قريباً".
