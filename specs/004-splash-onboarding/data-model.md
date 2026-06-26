# Data Model: Splash Screen & Onboarding

**Feature**: 004-splash-onboarding | **Date**: 2026-06-26

---

## Entities

### 1. OnboardingSlide

Represents the static content for one of the three onboarding slides. All three instances are defined as compile-time constants — no dynamic loading.

| Field | Type | Description |
|-------|------|-------------|
| `index` | `int` | Slide position (0, 1, 2) — drives `PageController` |
| `title` | `String` | Arabic slide title (e.g., "أهلاً بك في تجلي") |
| `subtitle` | `String` | Arabic slide subtitle (one or two lines) |
| `illustrationAsset` | `String` | Asset path for the SVG illustration (e.g., `assets/svg/onboarding_mosque.svg`) |
| `showSkip` | `bool` | Whether the skip button is visible — `true` for slides 0 and 1, `false` for slide 2 |
| `showBack` | `bool` | Whether the back button is visible — `false` for slide 0, `true` for slides 1 and 2 |
| `isPermissionSlide` | `bool` | `true` for slide 2 only — renders permission cards and "ابدأ الآن" button instead of "التالي" |

**Invariants**:
- Exactly 3 instances, ordered by `index` 0–2.
- `isPermissionSlide` is `true` only for the slide at `index == 2`.
- `showSkip` is always `false` when `isPermissionSlide` is `true`.

---

### 2. PermissionCardState

Enum representing the current status of a single permission card after the user has interacted (or not) with it.

| Value | Description | Visual Representation |
|-------|-------------|----------------------|
| `pending` | OS dialog not yet triggered | Frosted-glass card, gold border, gold icon badge |
| `granted` | User approved the permission | Gold checkmark icon, full-opacity gold border |
| `denied` | User denied the permission | Dimmed card (grey fill/border/text), subtle warning icon |

---

### 3. PermissionType

Enum identifying which OS permission a card represents.

| Value | OS Permission | Card Label (AR) |
|-------|--------------|-----------------|
| `location` | `Permission.locationWhenInUse` | "الموقع الجغرافي" |
| `notification` | `Permission.notification` | "الإشعارات" |

---

### 4. OnboardingService (Service, not entity)

Encapsulates the read/write operations for the onboarding completion flag. No fields — stateless service.

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `isFirstLaunch` | `Future<bool>` | Returns `true` if `onboarding_complete` key is absent or `false` in SharedPreferences |
| `markOnboardingComplete` | `Future<void>` | Writes `true` to `onboarding_complete` in SharedPreferences |

**Storage key**: `onboarding_complete` (bool, SharedPreferences)  
**Default value**: `false` (key absent = first launch)

---

## Riverpod Providers

| Provider | Type | Scope | Description |
|----------|------|-------|-------------|
| `onboardingPageProvider` | `StateProvider<int>` | App | Current active slide index (0–2) |
| `locationPermissionProvider` | `StateProvider<PermissionCardState>` | App | State of the location permission card |
| `notificationPermissionProvider` | `StateProvider<PermissionCardState>` | App | State of the notification permission card |
| `onboardingSlidesProvider` | `Provider<List<OnboardingSlide>>` | App | Static list of the 3 slide definitions |

---

## State Transitions

### Onboarding Page Flow

```
Page 0 (Slide 1)
  ├─ tap "التالي" → Page 1
  ├─ tap "تخطي"  → Page 2
  └─ swipe left  → Page 1

Page 1 (Slide 2)
  ├─ tap "التالي"  → Page 2
  ├─ tap "السابق"  → Page 0
  ├─ tap "تخطي"   → Page 2
  └─ swipe left   → Page 2

Page 2 (Slide 3 — Permissions)
  ├─ tap location card       → OS dialog → locationPermissionProvider: granted | denied
  ├─ tap notification card   → OS dialog → notificationPermissionProvider: granted | denied
  ├─ tap "السابق"             → Page 1
  └─ tap "ابدأ الآن"          → request any pending permissions → markOnboardingComplete() → MainNavigation
```

### Permission Card State Machine

```
pending ──tap──▶ [OS dialog shown]
                      │
              ┌───────┴───────┐
           approved        denied
              │                │
           granted           denied
              │                │
        (gold check)    (grey + warning)
```

Both `granted` and `denied` are terminal states within the onboarding session — no re-request once the card reaches a terminal state via individual tap. "ابدأ الآن" only requests permissions still in `pending` state.

---

## Persistence

| Key | Store | Type | Default | Set When |
|-----|-------|------|---------|----------|
| `onboarding_complete` | SharedPreferences | `bool` | absent (`false`) | `OnboardingService.markOnboardingComplete()` is called after "ابدأ الآن" completes permission requests |

No other data is persisted by this feature. Permission grant/deny outcomes are stored by the OS; the app reads them via `permission_handler` as needed in later phases.
