# Research: Splash Screen & Onboarding

**Feature**: 004-splash-onboarding | **Date**: 2026-06-26

---

## Decision 1: Splash Screen Routing Strategy

**Decision**: Use `SplashScreen` as the `MaterialApp` home widget. It performs the first-launch check internally and calls `Navigator.pushReplacement` to replace itself with either `OnboardingScreen` or `MainNavigation`.

**Rationale**: This is the standard Flutter pattern for a startup gate screen. Setting `home: SplashScreen()` in `app.dart` means the splash widget is only instantiated on cold start (app process creation), not on warm resume — which satisfies the "cold-start only" requirement without any extra lifecycle management. `pushReplacement` removes `SplashScreen` from the navigation stack so the back button cannot return to it.

**Alternatives considered**:
- *`go_router` with a redirect guard*: Would require adding a new routing package and restructuring existing routes. Overkill for a single gate check with no deep-linking requirements at this phase.
- *`FutureBuilder` in `app.dart`*: Would put routing logic in the app shell rather than a dedicated screen, making it harder to animate and test in isolation.

---

## Decision 2: Animation Implementation

**Decision**: Flutter's built-in `AnimationController` + `Tween` + `CurvedAnimation`. Single controller (1600 ms), two animations driven from it (scale + opacity). Navigation timer runs concurrently via `Future.delayed(2500 ms)` started in `initState`.

**Rationale**: No external animation package needed — `AnimationController` is sufficient for the two-step fade+scale sequence. The 2500 ms `Future.delayed` starts concurrently with the animation, so the storage read and animation run in parallel. Navigation always fires at exactly 2.5 s or later if the `mounted` check requires a frame, ensuring the minimum hold time is respected.

**Alternatives considered**:
- *`flutter_animate` package*: Simpler declarative syntax but an extra dependency. The spec's animation is simple enough that the built-in API is cleaner.
- *Sequential `await Future.delayed` calls*: Would chain delays and add up to more than 2.5 s total. Concurrent approach is correct.

---

## Decision 3: Onboarding Page Navigation

**Decision**: `PageView` with `PageController`, `physics: NeverScrollableScrollPhysics()`. Swipe-to-advance is added via `GestureDetector` horizontal drag detection. Skip jumps to page index 2 via `jumpToPage`. Back/next use `animateToPage` with `Curves.easeInOut` and 300 ms duration.

**Rationale**: `PageView` is the idiomatic Flutter component for horizontally paginated content. Disabling the default scroll physics and implementing swipe manually gives precise control — specifically, it prevents the user from accidentally swiping backwards past slide 1 or forward past slide 3 (which would bypass the permissions flow). RTL swipe direction is handled naturally by `Directionality`.

**Alternatives considered**:
- *`IndexedStack` with manual state*: Would preserve all slide widgets in memory simultaneously but makes animation between slides harder. `PageView` is the right tool.
- *Allow free swipe past slide 3 to navigate to home*: Rejected — this would bypass the permission request requirement.

---

## Decision 4: Permission State Management

**Decision**: Two `StateProvider<PermissionCardState>` instances (one per card), where `PermissionCardState` is an enum (`pending`, `granted`, `denied`). Providers are declared in `onboarding_providers.dart`. The `PermissionCardWidget` reads its own provider and calls `permission_handler` on tap.

**Rationale**: Riverpod `StateProvider` is the lightest-weight reactive primitive for simple enum state — no `StateNotifier` boilerplate needed. Scoping each card's state to its own provider makes the widgets independently testable and avoids entangling card-1 logic with card-2 logic.

**Alternatives considered**:
- *Single `StateProvider<Map<PermissionType, PermissionCardState>>`*: Requires more boilerplate to update a single key in the map (Riverpod's immutability model). Two independent providers are simpler.
- *Local `StatefulWidget` state*: State would be lost on widget rebuild and not accessible to `OnboardingScreen`'s "ابدأ الآن" button logic. Provider-based state is necessary for cross-widget access.

---

## Decision 5: Onboarding Completion Persistence

**Decision**: `SharedPreferences` accessed directly in `OnboardingService` using `setBool`/`getBool` with key `onboarding_complete`. The existing `StorageService` is not extended.

**Rationale**: `StorageService` only supports `String` operations. Adding `bool` support would widen its interface for a single use case. Calling `SharedPreferences` directly in `OnboardingService` keeps the service self-contained and avoids premature abstraction in `StorageService`. The `SharedPreferences` instance is already initialised by `main.dart` before the app starts.

**Alternatives considered**:
- *Extending `StorageService` with bool methods*: Would be the right call if multiple features needed bool storage. Currently only onboarding needs it — defer until a second caller exists.
- *Hive box for onboarding flag*: Overkill. Hive is appropriate for collections and typed objects (future phases); a single boolean belongs in SharedPreferences.

---

## Decision 6: SVG Illustration Strategy

**Decision**: SVG files loaded via `flutter_svg`'s `SvgPicture.asset()`. Files are placed in `assets/svg/` (already registered in `pubspec.yaml`). Illustrations are treated as opaque assets; their internal paths are not manipulated at runtime.

**Rationale**: `flutter_svg` is already declared in `pubspec.yaml`. SVG assets render crisply at all screen densities without rasterization artefacts. The spec illustrations (mosque, feature hexagons, compass rose, ornaments) are flat Islamic geometric designs well-suited to SVG.

**Alternatives considered**:
- *PNG assets at 2×/3× resolution*: Would require maintaining multiple resolution variants. SVG is superior for geometric/illustrative content.
- *Lottie animations*: Introduces a new dependency (`lottie` package) and requires separate `.json` animation files. The spec's illustration animations (slide-up, fade-in, stagger) can be achieved with standard Flutter animation APIs applied to the SVG widget.

---

## Decision 7: Decorative Elements (Arabesque Bands, Corner Ornaments)

**Decision**: Reuse the existing `ArabesqueHeader` widget (`lib/core/widgets/arabesque_header.dart`) for any overlapping patterns. Splash-screen-specific decorative elements (halo ring, radial glow, ornamental underline) are inline widgets within `SplashScreen` using `Container`, `BoxDecoration`, and `Transform.rotate`.

**Rationale**: The existing `ArabesqueHeader` widget provides a foundation for Arabic decorative headers. Splash-specific elements are unique to this screen and do not warrant extraction to shared widgets at this stage.

**Alternatives considered**:
- *Custom painter for all decorations*: `CustomPainter` offers pixel-level control but is harder to maintain. The design's elements (circles, rotated squares, gradients) are achievable with standard Flutter layout widgets.
