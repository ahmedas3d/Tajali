# Screen Widget Contract

**Feature**: 001-tajali-project-scaffold
**Date**: 2026-06-25
**Plan**: [plan.md](../plan.md)
**Data Model**: [data-model.md](../data-model.md)

## Overview

This document defines the interface each widget in Phase 1 must satisfy. All contracts are validated by running the app — not by automated tests (no test suite in Phase 1).

---

## Contract: FeaturePlaceholderScreen

Applies to: `HomeScreen`, `QuranScreen`, `AdhkarScreen`, `QiblaScreen`, `PrayerTimesScreen`

### Structural rules

| Rule | Requirement |
|------|-------------|
| Widget type | `StatelessWidget` |
| Constructor | `const ScreenName({super.key})` — no other parameters |
| Root widget | `Scaffold` |
| AppBar | Present; title is an Arabic string; inherits `AppBarTheme` from root `MaterialApp` |
| Body | `Center` wrapping a `Text` with the Arabic feature label using `AppTextStyles.heading2` |
| State | None — no `StatefulWidget`, no providers, no controllers |
| Compile result | Zero errors, zero warnings from `flutter analyze` |

### Per-screen values

See [data-model.md — Screen Registry](../data-model.md) for the Arabic label assigned to each screen.

### Out of scope (Phase 1)

- Loading / error / empty states
- Real data display
- User interactions (buttons, text fields, gestures)
- In-screen sub-navigation (except as noted for Tasbih below)
- Scroll controllers or list views

---

## Contract: TasbihScreen (scaffold only)

File: `features/qibla/presentation/tasbih_screen.dart`

| Rule | Requirement |
|------|-------------|
| Widget type | `StatelessWidget` |
| Constructor | `const TasbihScreen({super.key})` |
| Root widget | `Scaffold` with AppBar and centred body text (Arabic label: المسبحة) |
| Navigation wiring | **Not** imported or referenced in `routes.dart` or any other file in Phase 1 |
| Compile result | Zero errors when the file is compiled as part of the project |

---

## Contract: MainNavigation

File: `app/routes.dart`

| Rule | Requirement |
|------|-------------|
| Widget type | `ConsumerWidget` (uses Riverpod ref) |
| State source | `selectedTabProvider` (`StateProvider<int>`, default 0) |
| Screen host | `IndexedStack` containing all five screens (preserves state per FR-007a) |
| Tab count | Exactly 5 `BottomNavigationBarItem` entries |
| Tab order | Home (0) → Quran (1) → Adhkar (2) → Qibla (3) → Prayer Times (4) |
| Tab labels | Arabic: الرئيسية, القرآن, الأذكار, القبلة, الصلاة |
| Tab icons | Each tab has a distinct outlined icon (inactive) and filled icon (active) |
| RTL wrapper | `Directionality(textDirection: TextDirection.rtl)` wraps the `Scaffold` |
| Bar theme | Inherits `BottomNavigationBarTheme` from root `MaterialApp` |

---

## Contract: TajaliApp

File: `app/app.dart`

| Rule | Requirement |
|------|-------------|
| Widget type | `ConsumerWidget` |
| Root widget | `MaterialApp` |
| App title | `'تَجَلِّي'` |
| Class name | `TajaliApp` |
| Primary locale | `Locale('ar')` |
| Supported locales | `[Locale('ar'), Locale('en')]` |
| Light theme | `AppTheme.lightTheme` |
| Dark theme | `AppTheme.darkTheme` |
| Theme mode | `ThemeMode.light` (Phase 1 default) |
| Home | `MainNavigation()` |
| Debug banner | Hidden (`debugShowCheckedModeBanner: false`) |

---

## Contract: main.dart entry point

File: `lib/main.dart`

| Rule | Requirement |
|------|-------------|
| Initialisation | `WidgetsFlutterBinding.ensureInitialized()` called before anything else |
| Orientation | Portrait-up locked via `SystemChrome.setPreferredOrientations` |
| Status bar | Transparent with light icons via `SystemChrome.setSystemUIOverlayStyle` |
| Root widget | `ProviderScope(child: TajaliApp())` |
