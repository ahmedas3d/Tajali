# Feature Specification: Prayer Times (مواقيت الصلاة)

**Feature Branch**: `005-prayer-times`

**Created**: 2026-06-26

**Status**: Draft

**Input**: User description: "Phase 1 Prayer Times (مواقيت الصلاة) — Display the five daily prayer times based on the user's GPS location, show a countdown to the next prayer, support multiple calculation methods, and display the Hijri date."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Today's Prayer Times (Priority: P1)

A Muslim user opens the app and immediately sees all five daily prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha) along with Sunrise and Imsak, calculated for their current GPS location. The Hijri date is displayed alongside the Gregorian date. The currently active or next prayer is visually highlighted.

**Why this priority**: This is the core value proposition of the feature. Without accurate prayer times, no other part of the feature has purpose. Every other user story builds on this foundation.

**Independent Test**: Can be tested by opening the Prayer Times screen with a mocked GPS location and verifying all seven time slots render with correct values alongside the Hijri date.

**Acceptance Scenarios**:

1. **Given** the user has granted location permission and has an internet connection, **When** they open the Prayer Times screen, **Then** all five prayer times (plus Sunrise and Imsak) are displayed in Arabic, the current Hijri date is shown, and the next upcoming prayer is visually highlighted.
2. **Given** the app has cached prayer times from a previous session, **When** the user opens the app without internet, **Then** the cached times are shown along with a "last updated" timestamp.
3. **Given** the Prayer Times screen is open, **When** the current time passes a prayer time, **Then** the highlight automatically moves to the next upcoming prayer.

---

### User Story 2 — Countdown to Next Prayer (Priority: P1)

The user sees a live countdown timer showing exactly how much time remains until the next prayer. This hero element updates every minute so the user always has an accurate sense of urgency.

**Why this priority**: The countdown is the most time-sensitive UI element and the primary reason users return to this screen throughout the day. It is inseparable from P1 value.

**Independent Test**: Can be tested by mocking a fixed current time and next prayer time, verifying the countdown displays correctly and ticks down each minute.

**Acceptance Scenarios**:

1. **Given** the Prayer Times screen is displayed, **When** the user views the screen, **Then** a prominent countdown shows the remaining hours and minutes until the next prayer, along with the prayer's Arabic name.
2. **Given** a prayer countdown is showing, **When** one minute elapses, **Then** the countdown updates to reflect the new remaining time without requiring a manual refresh.
3. **Given** the countdown reaches zero, **When** the prayer time arrives, **Then** the display transitions to show the current active prayer and begins counting down to the following prayer.

---

### User Story 3 — Offline Access with Cached Times (Priority: P2)

A user who previously loaded prayer times loses internet connectivity. They open the app and still see their prayer times, clearly marked as cached, so they can plan their day without needing a network connection.

**Why this priority**: Offline reliability is critical for a prayer app used throughout the day. Users may be in areas with poor connectivity during prayer time checks.

**Independent Test**: Can be tested by loading prayer times, disabling network, re-opening the screen, and confirming cached data is displayed with a staleness indicator.

**Acceptance Scenarios**:

1. **Given** the user previously loaded prayer times and is now offline, **When** they open the Prayer Times screen, **Then** the cached times are shown with a visible "آخر تحديث" (last updated) timestamp.
2. **Given** prayer times are shown from cache, **When** internet is restored, **Then** the data refreshes automatically and the staleness indicator disappears.
3. **Given** the app has never loaded prayer times and has no internet, **When** the user opens the Prayer Times screen, **Then** an appropriate empty state is shown prompting the user to connect.

---

### User Story 4 — Change Calculation Method (Priority: P2)

A user who follows a specific juristic school (e.g., Hanafi, Muslim World League) can change the prayer time calculation method in settings. The prayer times immediately recalculate and update for the newly selected method.

**Why this priority**: Calculation method significantly affects prayer times (sometimes by 10–20 minutes). Serving users from diverse regions and schools requires this flexibility.

**Independent Test**: Can be tested by switching from the default method to another, and verifying the displayed times change accordingly.

**Acceptance Scenarios**:

1. **Given** the user is on the Prayer Times screen or settings, **When** they select a different calculation method, **Then** the prayer times immediately update to reflect the new method.
2. **Given** the user has changed the calculation method, **When** they close and reopen the app, **Then** the previously selected method is remembered and applied.
3. **Given** multiple calculation methods are available, **When** the user opens the method selector, **Then** at least the following methods are listed: Egyptian General Authority (default), Muslim World League, Umm Al-Qura, ISNA, and Karachi/Hanafi.

---

### User Story 5 — Location Permission Denied / Manual City Fallback (Priority: P3)

A user who denied location permission during onboarding, or whose location cannot be determined, is offered a fallback flow to manually enter or search for their city so prayer times can still be calculated.

**Why this priority**: A small percentage of users deny location permissions. The app should remain functional for them rather than showing a broken state.

**Independent Test**: Can be tested by simulating denied location permission and verifying the manual city entry UI is presented and times are calculated correctly after entry.

**Acceptance Scenarios**:

1. **Given** location permission is denied, **When** the user opens the Prayer Times screen, **Then** a clear prompt explains why location is needed and offers a "تحديد المدينة يدوياً" (set city manually) option.
2. **Given** the user selects manual city entry, **When** they search for and confirm a city, **Then** prayer times are calculated for that city and displayed.
3. **Given** the user has manually set a city, **When** they reopen the app, **Then** the last chosen city is remembered and prayer times are shown without re-prompting.

---

### Edge Cases

- What happens when GPS fix takes longer than expected (>10 seconds)? → Use last known cached location; show a non-blocking loading indicator.
- What happens when the API returns a 5xx error? → Display cached times with an error banner; do not show an empty screen.
- What happens at midnight when the prayer date rolls over? → Fetch new times for the new date automatically; cached data for the previous date is invalidated.
- What happens in polar regions where prayer times cannot be calculated by standard methods? → Display an informational message; offer alternative calculation convention selection.
- What happens when the device clock is wrong? → Prayer times are calculated server-side based on date passed; local countdown timer may show unexpected values — display times as-is without adjustment.
- What happens when the user travels to a new city mid-day? → The next foreground open or background refresh detects the location change and fetches updated times.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display the five daily prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha) plus Sunrise (الشروق) and Imsak for the user's current date and GPS location.
- **FR-002**: The system MUST display the current Hijri calendar date alongside the Gregorian date on the prayer times screen.
- **FR-003**: The system MUST show a live countdown timer to the next upcoming prayer, updated every minute.
- **FR-004**: The system MUST visually distinguish the next/current prayer from the remaining prayer time entries.
- **FR-005**: The system MUST cache today's prayer times locally so they are available when the device is offline.
- **FR-006**: The system MUST display a "last updated" timestamp when showing cached (offline) data.
- **FR-007**: The system MUST support at least five prayer time calculation methods selectable by the user, defaulting to the Egyptian General Authority of Survey method.
- **FR-008**: The system MUST persist the user's chosen calculation method across app restarts.
- **FR-009**: The system MUST automatically refresh prayer times when the date changes (midnight rollover) or when the app returns to the foreground on a new day.
- **FR-010**: When location permission is denied, the system MUST offer a manual city entry/search fallback so prayer times can still be calculated.
- **FR-011**: The system MUST cache the user's last known location and use it as a fallback when a fresh GPS fix cannot be obtained within a reasonable timeout.
- **FR-012**: When an API error occurs, the system MUST show cached data (if available) with a non-blocking error banner rather than an empty or broken screen.
- **FR-013**: All text and labels on the prayer times screen MUST be displayed in Arabic (RTL layout).
- **FR-014**: The prayer times screen widget data MUST be accessible as a reusable card component for embedding on the home screen.

### Key Entities

- **Prayer Times Record**: Represents a complete set of prayer times for a specific date, location, and calculation method. Includes time values for Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha, and Imsak. Tied to a geographic coordinate and a calculation method identifier.
- **Hijri Date**: Represents the Islamic calendar equivalent of a Gregorian date. Includes day number, month name in Arabic, and year.
- **Next Prayer**: A derived view of the nearest upcoming prayer relative to the current time. Includes the prayer name (in Arabic), its scheduled time, and the duration remaining until it occurs.
- **Calculation Method**: Represents a named juristic authority's formula for computing prayer times. Has an identifier, a human-readable Arabic name, and an associated school of thought (Asr convention: Standard vs. Hanafi).
- **Cached Location**: The most recently resolved GPS coordinate, stored locally to use when a fresh location fix is unavailable.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can see all prayer times for the current day within 3 seconds of opening the Prayer Times screen on a standard mobile connection.
- **SC-002**: The live countdown to the next prayer is accurate to within 1 minute at all times and updates without requiring a manual screen refresh.
- **SC-003**: Users who have previously loaded prayer times can view the full prayer schedule in offline mode without any missing data.
- **SC-004**: Users can switch calculation methods and see updated prayer times in under 2 seconds.
- **SC-005**: Users who deny location permission are presented with a functional city-search fallback within one interaction step; prayer times load successfully after city selection.
- **SC-006**: On a new calendar day, updated prayer times are shown without the user needing to manually refresh.
- **SC-007**: The prayer times card/component renders correctly when embedded in the home screen without additional network calls if data is already cached.

---

## Assumptions

- Location permission is requested during the onboarding flow (Phase 0); this screen assumes the permission flow has already been attempted.
- Prayer time data is fetched from a remote API on first load each day; the app does not ship bundled prayer time tables.
- The default calculation method (Egyptian General Authority of Survey, method 5) is appropriate for the primary target audience (Arabic-speaking users in Egypt and similar regions).
- The app targets portrait orientation only; no landscape layout is required for this screen.
- Prayer time display is date-local to the device's configured timezone; no timezone selector UI is required in Phase 1.
- Audio Azan notifications are out of scope for this phase (handled in Phase 7); this spec covers display only.
- The home screen prayer card is a read-only widget that consumes the same data as the full Prayer Times screen; it does not have its own data-fetching logic.
- "Today's" prayer times expire at midnight device-local time; cross-midnight edge cases (e.g., Isha near midnight) are handled by always displaying the times for the current calendar date.
- Manual city search results are provided by a built-in curated list of major cities; a live geocoding API search is not required for this phase.
