# Quickstart Validation Guide: تَجَلِّي Project Scaffold

**Feature**: 001-tajali-project-scaffold
**Date**: 2026-06-25

## Prerequisites

| Requirement | How to verify |
|---|---|
| Flutter ≥ 3.19 on `stable` channel | `flutter --version` |
| Connected device or simulator | `flutter devices` |
| Font files in `assets/fonts/` | `ls assets/fonts/` — must show Amiri-Regular.ttf, Amiri-Bold.ttf, AmiriQuran.ttf |

Switch to stable and upgrade if needed:
```bash
flutter channel stable && flutter upgrade
```

## Setup

```bash
# Install all declared packages
flutter pub get

# Confirm no version conflicts
flutter pub deps
```

Both commands must complete with zero errors before proceeding to validation.

---

## Validation Scenarios

### SC-001 — Five-minute setup

**Goal**: A new developer can reach a running app in under five minutes.

```bash
time flutter pub get && flutter run
```

**Pass**: App launches with a five-tab bottom navigation bar and the timer reads < 5 minutes.
**Fail**: Any error during `pub get`, build, or app launch.

---

### SC-002 — All five tabs reachable

**Steps**:
1. With the app running, tap each of the five bottom-nav tabs.
2. Confirm each screen is displayed with its Arabic label.

**Tab order (RTL — right to left on screen)**:

| Position (RTL) | Index | Arabic label |
|---|---|---|
| Rightmost | 0 | الرئيسية |
| 2nd from right | 1 | القرآن |
| Centre | 2 | الأذكار |
| 2nd from left | 3 | القبلة |
| Leftmost | 4 | الصلاة |

**Pass**: No crash. Each tab shows its labelled screen.
**Fail**: Any tab causes a crash or shows a blank/error screen.

---

### SC-003 — RTL layout

**Steps**:
1. Observe the bottom navigation bar.
2. Confirm الرئيسية (Home) is on the **right** side.
3. Confirm Arabic text on all screens flows right-to-left.

**Pass**: Home tab on the right; Arabic text reads naturally right-to-left.
**Fail**: Home tab on the left; any text rendered LTR.

---

### SC-004 — Arabic font families visible

**Steps**:
1. Navigate to any screen with a heading or body text.
2. Compare with a reference screenshot of Amiri font.

**Pass**: Calligraphic letterforms visible; text looks distinctly different from Roboto (Android) / San Francisco (iOS).
**Fail**: App renders system default font (both fonts look identical).

---

### SC-005 — Zero compile errors

```bash
flutter analyze
flutter build apk --debug
# iOS (no signing required):
flutter build ios --debug --no-codesign
```

**Pass**: `flutter analyze` reports 0 errors; both builds complete.
**Fail**: Any error or unresolved package.

---

### SC-006 — Asset resolution

**Steps**:
1. Add any PNG file to `assets/images/` (e.g., `test.png`).
2. In `home_screen.dart`, add `Image.asset('assets/images/test.png')` inside the body.
3. Hot-restart the app.

**Pass**: Image renders on the Home screen.
**Fail**: "Unable to load asset" error or blank space.

*Remove the test image and code change after validation.*

---

### FR-007a — Tab state preservation

**Steps**:
1. Temporarily replace `QuranScreen`'s body with a `ListView.builder` that generates 50 items.
2. Run the app and scroll to item 30 in the Quran tab.
3. Switch to the الصلاة (Prayer Times) tab.
4. Switch back to the القرآن (Quran) tab.

**Pass**: List is still scrolled to item 30 — IndexedStack preserved the widget state.
**Fail**: List resets to item 0.

*Remove the temporary ListView after validation.*

---

## Known Limitations (Phase 1)

- Font files are not committed; developers must obtain and place them manually in `assets/fonts/`
- `assets/images/`, `assets/svg/`, `assets/audio/`, `assets/data/` may be empty (add a `.gitkeep` file to each)
- `TasbihScreen` exists as a file but is not accessible via any navigation path
- No automated tests are included in Phase 1
