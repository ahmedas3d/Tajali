# Quickstart & Validation Guide: App Entry Point & Navigation

**Date**: 2026-06-25 | **Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

---

## Prerequisites

- Flutter 3.44 stable installed (`flutter --version`)
- A physical device or simulator/emulator connected (`flutter devices`)
- Phase 1 scaffold complete (all directories and `pubspec.yaml` in place)
- Phase 2 theme files implemented (`app_colors.dart`, `app_fonts.dart`, `app_text_styles.dart`, `app_theme.dart`, `theme_provider.dart`)
- Dependencies fetched: `flutter pub get`
- No analysis errors: `flutter analyze`

---

## Running the App

```bash
flutter run
```

For a specific device:

```bash
flutter run -d <device-id>
```

To run in release mode (closer to production performance targets):

```bash
flutter run --release
```

---

## Validation Scenarios

Run each scenario in order. All must pass before Phase 3 is considered complete.

### SC-V1: Cold Launch — Home Tab Visible

**Scenario**: App launches and shows the home placeholder with bottom navigation.

**Steps**:
1. Kill any running instance of the app
2. Launch from device home screen (or `flutter run`)
3. Observe the first frame

**Expected**:
- Bottom navigation bar visible with 5 tabs
- الرئيسية tab is highlighted (gold icon + gold label)
- App bar shows `تَجَلِّي`
- Body shows `الشاشة الرئيسية` centred
- Status bar is transparent (no coloured bar visible above app bar)

**Success Criterion**: SC-001 (launches within 3 s), FR-001, FR-009

---

### SC-V2: Portrait Lock

**Scenario**: Device rotation has no effect.

**Steps**:
1. App is running on home screen
2. Rotate device to landscape

**Expected**:
- UI remains portrait; no reflow or landscape layout appears
- Rotation animation may start and snap back

**Success Criterion**: SC-005, FR-002

---

### SC-V3: Tab Navigation

**Scenario**: Each tab switches to the correct screen.

**Steps** (tap in order):
1. Tap القرآن tab → expect `القرآن الكريم` centred, app bar `تَجَلِّي`
2. Tap الأذكار tab → expect `الأذكار` centred, app bar `تَجَلِّي`
3. Tap القبلة tab → expect `القبلة` centred, app bar `تَجَلِّي`
4. Tap الصلاة tab → expect `مواقيت الصلاة` centred, app bar `تَجَلِّي`
5. Tap الرئيسية tab → back to home

**For each transition, verify**:
- Active tab icon is filled variant
- Active tab label colour is gold
- Other tabs show outlined icons and muted labels

**Success Criterion**: SC-002 (visible within 100 ms), FR-005, FR-006, FR-007, FR-009

---

### SC-V4: State Preservation

**Scenario**: Returning to a tab does not reset its state.

**Steps**:
1. Navigate to الرئيسية tab
2. (For a richer test once real content exists) — with placeholder screens, verify via Flutter DevTools that the `HomeScreen` widget is not rebuilt on return
3. Switch to القرآن tab
4. Switch back to الرئيسية

**Expected**:
- DevTools widget rebuild count for `HomeScreen` does not increment on step 4
- No visual flash or rebuild animation

**Success Criterion**: SC-003, FR-008

---

### SC-V5: RTL Layout

**Scenario**: Navigation bar renders right-to-left.

**Steps**:
1. Look at the bottom navigation bar

**Expected**:
- الرئيسية appears on the **right** end of the bar
- الصلاة appears on the **left** end of the bar
- All text is right-aligned

**Success Criterion**: SC-004, FR-004, FR-005 (RTL order)

---

### SC-V6: Status Bar Transparency

**Scenario**: Status bar blends with the app bar.

**Steps**:
1. Open the app on a device with a coloured status bar
2. Observe the area above the app bar

**Expected**:
- No separate coloured status bar band visible
- System clock and icons appear white (light brightness) directly over the green app bar

**Success Criterion**: SC-006, FR-003

---

### SC-V7: Dark Mode Rejection

**Scenario**: System dark mode does not change app theme.

**Steps**:
1. Enable dark mode in device settings
2. Open (or switch back to) the app

**Expected**:
- App still shows parchment/gold light theme
- (Phase 2 note: the `ThemeNotifier` defaults to `ThemeMode.light` from `shared_preferences` — if the user has not toggled it, the light theme shows regardless of system setting)

**Success Criterion**: FR-010

---

## Static Analysis

```bash
flutter analyze
```

**Expected**: Zero errors, zero warnings. Info-level hints are acceptable.

---

## Widget Tests (once implemented)

```bash
flutter test test/app/routes_test.dart
flutter test test/features/
```

Key assertions to cover:
- `MainNavigation` renders 5 `BottomNavigationBarItem` widgets
- Tapping item at index N updates `selectedTabProvider` to N
- `IndexedStack` displays child at `selectedIndex`
- Each placeholder screen renders its body label text
