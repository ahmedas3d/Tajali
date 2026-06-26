# Research: Theme System

**Date**: 2026-06-25 | **Feature**: [002-theme-system](spec.md)

---

## Decision 1: WCAG AA Gold Color on Light Backgrounds

**Decision**: Introduce a dedicated `goldText` color token (~`#7B5F00`) for all text styles rendered on light backgrounds. Retain the original `gold` (`#C9A84C`) exclusively for decorative and dark-background contexts.

**Rationale**: The original gold at `#C9A84C` has a calculated luminance of ~0.41, yielding only ~1.85:1 contrast against parchment (`#F5E6C8`, luminance ~0.80) — far below the WCAG AA threshold of 4.5:1 for normal text. A value near `#7B5F00` achieves ~4.87:1. The split token approach (`gold` vs `goldText`) preserves the full visual richness of the original gold everywhere it works well (dark AppBar titles, nav active icon, card borders on dark cards) while ensuring accessibility for legible text.

**Alternatives considered**:
- Replace all gold usage with a single accessible value — rejected because the original gold looks correct and rich on dark backgrounds; darkening it would dull the dark-theme AppBar and nav.
- Use a single gold and allow heading text to fail WCAG — rejected per spec FR-014/FR-015.
- Use white text for headings instead of gold — rejected as it would remove the gold accent from the primary typographic hierarchy.

---

## Decision 2: Theme Toggle Mechanism

**Decision**: Riverpod `Notifier<ThemeMode>` provider (`AsyncNotifier` variant to support async init from storage) declared in `lib/core/providers/theme_provider.dart`. `TajaliApp` in `app.dart` watches the provider and passes the resolved `ThemeMode` to `MaterialApp`.

**Rationale**: The app already uses `flutter_riverpod` for state management and `app.dart` already extends `ConsumerWidget`. Adding a `ThemeNotifier` follows the established pattern with minimal new surface area. `AsyncNotifier` handles the async SharedPreferences read on first build cleanly, falling back to `ThemeMode.light` until the stored value resolves.

**Alternatives considered**:
- `StateProvider<ThemeMode>` — simpler but can't encapsulate the SharedPreferences read/write logic cleanly; side-effects scattered outside the provider.
- `ChangeNotifierProvider` — Riverpod 1.x pattern, not idiomatic in Riverpod 2.x.
- `InheritedWidget` with manual `setState` — no Riverpod benefit; rejected.

---

## Decision 3: Theme Preference Persistence Backend

**Decision**: `shared_preferences` package (already a declared dependency). Store a single `String` key `'theme_mode'` with values `'light'` or `'dark'`.

**Rationale**: Theme mode is a single primitive preference. `shared_preferences` is synchronous to read and already in `pubspec.yaml`. `Hive` (also a declared dependency) would require schema registration and a generated adapter for a trivial use case. `StorageService` (the existing stub at `lib/shared/local_storage/storage_service.dart`) is implemented using `shared_preferences` in this phase.

**Alternatives considered**:
- Hive — more powerful, but overengineered for one string value; adds code-generation overhead.
- Direct `SharedPreferences` calls in `ThemeNotifier` (bypass `StorageService`) — rejected because `StorageService` is the declared storage abstraction layer; all persistence should go through it.

---

## Decision 4: Toggle UI Placement

**Decision**: A moon/sun icon button in the `AppBar` of `HomeScreen` (the default landing tab). Tapping it calls `ref.read(themeProvider.notifier).toggle()`.

**Rationale**: Home screen AppBar is always visible when the app opens, making the toggle discoverable without a dedicated settings screen. An icon button is the lightest possible UI surface for a Phase 2 feature — no new screen, no navigation change.

**Alternatives considered**:
- Dedicated settings screen — more scalable for future preferences, but overscoped for Phase 2 (spec defers "settings screen" to a later phase).
- BottomNavigationBar settings tab — would consume one of the 5 fixed tabs; not worth it for a single toggle.
- System-level dark mode following — rejected because spec requires explicit user control and persistence.

---

## Decision 5: `.withOpacity()` Deprecation

**Decision**: No action required. Phase 1 scaffold already resolved this — `app_theme.dart` uses pre-computed ARGB constants (`Color(0x4DC9A84C)`, `Color(0x33C9A84C)`) and `app_colors.dart` uses `Color(0x80FAF0DC)` for `navInactive`. All theme files are `const`-safe.

**Rationale**: Confirmed by reading the existing files. The Phase 1 scaffold anticipated and resolved this per the PLAN.md specification.

**Alternatives considered**: N/A — already done.
