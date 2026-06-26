# Data Model: App Entry Point & Navigation

**Date**: 2026-06-25 | **Feature**: [spec.md](spec.md)

Phase 3 introduces no persistent data model. The only runtime state is the active tab index, held in memory by a Riverpod provider.

---

## Entities

### NavigationState

Represents which of the five tabs is currently selected.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `selectedIndex` | `int` | 0 ≤ value ≤ 4; never null | Zero-based index of the active tab |

**Owner**: `selectedTabProvider` (`StateProvider<int>`) in `lib/app/routes.dart`

**Lifecycle**:
- Created at app start with value `0` (الرئيسية tab)
- Mutated by `BottomNavigationBar.onTap`
- Destroyed when the app process exits (not persisted)

**State transitions**:

```
[0..4] --onTap(n)--> n     (any valid index, including same index — no-op visually)
```

---

### FeatureScreen

A placeholder screen widget mounted in the `IndexedStack`.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `tabIndex` | `int` (implicit) | Fixed per screen class | Position in the `IndexedStack` (0=Home, 1=Quran, 2=Adhkar, 3=Qibla, 4=PrayerTimes) |
| `appBarTitle` | `String` (const) | Always `'تَجَلِّي'` | Displayed in `AppBar.title` |
| `bodyLabel` | `String` (const) | Arabic section name | Centred text identifying the section |

**Screen registry**:

| Index | Class | File | `bodyLabel` |
|-------|-------|------|-------------|
| 0 | `HomeScreen` | `features/home/presentation/home_screen.dart` | `'الشاشة الرئيسية'` |
| 1 | `QuranScreen` | `features/quran/presentation/quran_screen.dart` | `'القرآن الكريم'` |
| 2 | `AdhkarScreen` | `features/adhkar/presentation/adhkar_screen.dart` | `'الأذكار'` |
| 3 | `QiblaScreen` | `features/qibla/presentation/qibla_screen.dart` | `'القبلة'` |
| 4 | `PrayerTimesScreen` | `features/prayer_times/presentation/prayer_times_screen.dart` | `'مواقيت الصلاة'` |

---

## Provider Graph

```
selectedTabProvider (StateProvider<int>)
    └── MainNavigation (ConsumerWidget)
            ├── IndexedStack [index = selectedIndex]
            │       ├── HomeScreen [0]
            │       ├── QuranScreen [1]
            │       ├── AdhkarScreen [2]
            │       ├── QiblaScreen [3]
            │       └── PrayerTimesScreen [4]
            └── BottomNavigationBar [currentIndex = selectedIndex]

themeProvider (AsyncNotifierProvider<ThemeNotifier, ThemeMode>)  ← Phase 2
    └── TajaliApp (ConsumerWidget)
            └── MaterialApp [themeMode = themeProvider.value ?? ThemeMode.light]
```

---

## Navigation Tab Definition

Each tab entry in the `BottomNavigationBar`:

| Index (RTL position) | Label | Inactive Icon | Active Icon |
|----------------------|-------|---------------|-------------|
| 0 (rightmost in RTL) | `'الرئيسية'` | `Icons.home_outlined` | `Icons.home` |
| 1 | `'القرآن'` | `Icons.menu_book_outlined` | `Icons.menu_book` |
| 2 | `'الأذكار'` | `Icons.self_improvement_outlined` | `Icons.self_improvement` |
| 3 | `'القبلة'` | `Icons.explore_outlined` | `Icons.explore` |
| 4 (leftmost in RTL) | `'الصلاة'` | `Icons.access_time_outlined` | `Icons.access_time` |
