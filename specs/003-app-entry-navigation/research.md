# Research: App Entry Point & Navigation

**Date**: 2026-06-25 | **Feature**: [spec.md](spec.md)

No external unknowns required investigation for this phase. All technical decisions were resolved from prior phases and the project's `PLAN.md` reference document.

---

## Resolved Decisions

### 1. Orientation lock API

**Decision**: `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`

**Rationale**: The Flutter `SystemChrome` API is the idiomatic cross-platform way to lock orientation. It works on both iOS (maps to `UIInterfaceOrientationMaskPortrait`) and Android (maps to `screenOrientation="portrait"` equivalent at runtime). Called before `runApp` to ensure it takes effect before the first frame.

**Alternatives considered**: Platform-specific `Info.plist` / `AndroidManifest.xml` entries lock orientation at install time but cannot be changed at runtime. The `SystemChrome` approach allows future unlocking (e.g., video playback) without manifest changes.

---

### 2. Status bar styling

**Decision**: `SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light))`

**Rationale**: Transparent status bar with light icons integrates cleanly with the dark-green `AppBar` (`AppColors.primaryGreen` / `0xFF1B4332`) from the Phase 2 theme. Light icons are legible against dark backgrounds.

**Alternatives considered**: `AppBar.systemOverlayStyle` sets per-screen status bar style but requires every `AppBar` to repeat the config. Setting it once globally in `main()` is DRY and consistent.

---

### 3. Global navigation state: StateProvider vs StateNotifierProvider

**Decision**: `StateProvider<int>` named `selectedTabProvider`

**Rationale**: The navigation state is a single integer (0–4). `StateProvider` is the idiomatic Riverpod choice for simple primitive values with no business logic. It is readable and writable from any widget tree node without boilerplate.

**Alternatives considered**: `StateNotifierProvider` with a `SelectedTabNotifier` class would add ~15 lines of boilerplate with no benefit. `ChangeNotifierProvider` is deprecated in Riverpod 2.x.

---

### 4. Tab state preservation: IndexedStack vs PageView

**Decision**: `IndexedStack` with all 5 screens pre-instantiated

**Rationale**: `IndexedStack` keeps all children in the widget tree simultaneously, preserving their state (scroll position, `StatefulWidget` local state) unconditionally. This satisfies FR-008 and SC-003 with zero per-screen boilerplate.

**Alternatives considered**: `PageView` + `AutomaticKeepAliveClientMixin` achieves the same result but requires each screen to implement the mixin and call `wantKeepAlive`. Since the feature count is fixed at 5 and screens are lightweight placeholders, the memory overhead of `IndexedStack` is negligible.

---

### 5. RTL layout scope

**Decision**: `Directionality(textDirection: TextDirection.rtl)` wrapping `MainNavigation`'s `Scaffold`

**Rationale**: Placing `Directionality` at the navigation shell level ensures every descendant widget — body, app bar, bottom bar — inherits RTL without each screen declaring it. The `MaterialApp.locale: Locale('ar')` also causes Flutter to infer RTL, but the explicit `Directionality` widget guarantees it regardless of device locale.

**Alternatives considered**: Setting `locale` alone in `MaterialApp` would inherit RTL only if the device locale is Arabic. Wrapping at `MaterialApp` level via `builder` is equally valid but the `MainNavigation` placement is more explicit.

---

### 6. Crash reporting

**Decision**: Deferred — no crash reporting initialised in Phase 3

**Rationale**: Clarified with user on 2026-06-25. `main()` stays minimal (binding + orientation + status bar). No Firebase, Sentry, or other observability SDK added until there are meaningful user flows to instrument.

---

### 7. AppBar title on placeholder screens

**Decision**: All 5 placeholder screens display `تَجَلِّي` as the AppBar title

**Rationale**: Clarified with user on 2026-06-25 (Option A). The centred body text provides the section-specific label. This gives every screen a consistent app-branded header during development.
