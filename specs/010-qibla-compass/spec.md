# Feature Specification: Qibla Compass (القبلة)

**Feature Branch**: `010-qibla-compass`

**Created**: 2026-06-29

**Status**: Draft

**Input**: Phase 5 of PLAN2.md — Qibla Compass (real-time compass pointing toward Mecca using GPS and device magnetometer sensor)

---

## Clarifications

### Session 2026-06-29

- Q: When the user opens the Qibla screen offline after having previously seen mosque data, should the old mosque data still appear? → A: No — the nearest mosque card always requires a live network query. It is hidden entirely whenever the device is offline or the query fails. No mosque data is cached locally.
- Q: Should the cached Qibla direction expire after a maximum time period, forcing a re-fetch even without movement? → A: No — cache invalidation is distance-based only (≥50 km movement). No time-based TTL is applied. The Qibla bearing for a fixed location is geographically constant; a time expiry would cause unnecessary network calls with no accuracy benefit.
- Q: Which data from this feature is stored persistently on the user's device? → A: Derived data only — the Qibla bearing angle (degrees), the reverse-geocoded city name string, and the calculated distance to Mecca. Raw GPS coordinates (latitude/longitude) are used transiently at runtime for calculation and are never written to persistent storage.
- Q: When location permission is revoked while the Qibla screen is actively open, what should the app display? → A: The compass is immediately replaced by the same permission request card shown at cold-start (US-5 scenario 1). No stale reading is left on screen.
- Q: Should compass accuracy feedback be shown only when accuracy is low, or as a persistent badge at all times? → A: Persistent badge — a Low / Medium / High accuracy label is always visible in the compass area, regardless of accuracy level.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Real-Time Qibla Direction (Priority: P1)

A user opens the Qibla screen and sees an animated compass rose that continuously rotates as they physically turn their device. The compass needle consistently points toward Mecca regardless of which direction the user faces. A direction badge below the compass shows the cardinal abbreviation and exact degree angle (e.g., "SE 135°").

**Why this priority**: Showing a live, accurate Qibla direction is the entire purpose of this feature. All other elements on the screen exist to support or augment this core interaction. Without a working compass, nothing else on the screen is useful.

**Independent Test**: Can be fully tested by opening the Qibla tab, rotating the device 360°, and verifying that the compass needle consistently points in the same real-world direction (toward Mecca) throughout the full rotation.

**Acceptance Scenarios**:

1. **Given** the user opens the Qibla screen with location permission already granted, **When** the screen loads, **Then** an animated circular compass is displayed prominently in the center of the screen.
2. **Given** the compass is loaded, **When** the user physically rotates their device, **Then** the compass rose rotates in real-time so that the Qibla needle always visually points toward Mecca.
3. **Given** the compass is active, **When** the user views below the compass, **Then** a direction badge displays the cardinal direction abbreviation and the Qibla angle in degrees (e.g., "SE ١٣٥°").
4. **Given** the Qibla direction has been calculated, **When** the user views the compass, **Then** the compass contains a golden mosque/Ka'ba icon at its center and a distinctive golden needle indicating the Qibla direction.
5. **Given** the user's device supports the compass sensor, **When** they point the top of the device toward Mecca, **Then** the needle points straight up (toward the top of the screen).

---

### User Story 2 - See Location and Distance Stats (Priority: P1)

A user views their current city name and country displayed just below the app bar, confirming the compass is using their correct GPS position. Below the compass, two information cards show the exact Qibla angle in degrees and the distance to Mecca in kilometers.

**Why this priority**: Users need immediate confidence that the compass is calibrated to their actual location. City name + distance stats together deliver that assurance without requiring any user action.

**Independent Test**: Can be tested independently by opening the Qibla screen and verifying the city name and country appear, then checking that the distance card shows a value within ± 50 km of the known distance from that city to Mecca (lat 21.3891, lon 39.8579).

**Acceptance Scenarios**:

1. **Given** the user opens the Qibla screen with GPS available, **When** the screen loads, **Then** a location chip below the app bar displays the current city name and country (e.g., "القاهرة، مصر").
2. **Given** the user views the stats row below the direction badge, **When** the screen is fully loaded, **Then** two information cards are displayed side by side: one showing distance to Mecca (e.g., "١٬٢٤٠ كم") and one showing the Qibla angle (e.g., "١٣٥٫٤°").
3. **Given** the GPS location is Cairo, Egypt, **When** the distance card is displayed, **Then** it shows a value approximately 1,240 km (within 10 km margin).
4. **Given** the Qibla direction has been fetched, **When** the angle card is displayed, **Then** it shows the direction in decimal degrees matching the fetched Qibla angle.
5. **Given** the screen is loading GPS and Qibla data, **When** the cards are not yet populated, **Then** each card shows a skeleton/shimmer placeholder instead of empty content.

---

### User Story 3 - Calibrate the Compass Sensor (Priority: P2)

A user notices the compass may be inaccurate due to magnetic interference. A static hint row below the stats cards instructs them to move the device in a figure-8 motion to improve sensor accuracy.

**Why this priority**: Compass calibration guidance prevents user confusion when the sensor is slightly off. It is a secondary aid — the compass works without it, but the hint significantly improves the first-time user experience on poorly calibrated devices.

**Independent Test**: Can be tested by opening the Qibla screen and verifying the calibration hint row is visible and contains the figure-8 instruction text with an appropriate icon, without interacting with the compass at all.

**Acceptance Scenarios**:

1. **Given** the Qibla screen is open, **When** the user scrolls below the stats cards, **Then** a calibration hint row is visible containing a shake/motion icon and the text "حرك هاتفك على شكل رقم (8) لزيادة دقة البوصلة".
2. **Given** the hint row is displayed, **When** the user reads it, **Then** the text is legible in a muted/secondary style that does not distract from the compass.
3. **Given** the device reports a compass accuracy level, **When** the accuracy is "low", **Then** the calibration hint row is visually more prominent (e.g., highlighted or with a warning icon) to draw attention.
4. **Given** the compass is active, **When** the user views the compass area, **Then** a persistent accuracy badge is visible showing the current sensor accuracy level as one of three labels: "دقة منخفضة" (Low), "دقة متوسطة" (Medium), or "دقة عالية" (High).

---

### User Story 4 - Find and Navigate to the Nearest Mosque (Priority: P3)

A user sees a "Nearest Mosque" card at the bottom of the Qibla screen showing the name of the closest mosque and the approximate walking distance. Tapping "انتقل" opens the device's native maps application with the mosque pinned as a destination.

**Why this priority**: Knowing the nearest mosque is a natural companion to knowing the Qibla direction. It adds immediate real-world utility. It is a P3 because it requires an additional data source and the core compass experience is complete without it.

**Independent Test**: Can be tested by opening the Qibla screen, verifying the mosque name and distance appear in the bottom card, then tapping "انتقل" and confirming the native maps app opens with the mosque location.

**Acceptance Scenarios**:

1. **Given** the user's GPS location is available, **When** the Qibla screen loads, **Then** a "أقرب مسجد إليك" card at the bottom of the screen shows the nearest mosque's name and walking distance (e.g., "مسجد الفتح — على بعد ١٥٠ م").
2. **Given** the nearest mosque card is visible, **When** the user taps the "انتقل" button, **Then** the device's default maps application opens with the mosque pre-set as the navigation destination.
3. **Given** the device is offline or the mosque query fails, **When** the screen loads, **Then** the nearest mosque card is hidden entirely — no empty state, no stale data, no placeholder.
4. **Given** the screen is online and mosque data is loading, **When** the card area is visible, **Then** a skeleton/shimmer placeholder is shown until the live result arrives.

---

### User Story 5 - Handle No Location Permission or No Compass Sensor (Priority: P1)

A user who has not granted location permission or whose device lacks a compass sensor sees a clear, actionable error state instead of a broken or empty screen.

**Why this priority**: These are the two most common failure conditions. Showing a graceful error with clear guidance prevents user abandonment and maintains trust in the app.

**Independent Test**: Can be tested by (a) revoking location permission and opening the Qibla screen — verifying the permission request card appears — and (b) running on a device/emulator with no compass sensor and verifying the static direction fallback message is shown.

**Acceptance Scenarios**:

1. **Given** the user has not granted location permission, **When** they open the Qibla screen, **Then** a clear permission request card is shown explaining why location is needed, with a button to open settings or grant permission.
2. **Given** the user grants location permission from the permission request card, **When** the permission is granted, **Then** the compass loads and shows the Qibla direction without requiring the user to restart the app.
3. **Given** the user has the Qibla screen open with a working compass, **When** they revoke location permission (e.g., via device settings mid-session), **Then** the compass is immediately replaced by the permission request card — no stale compass reading remains on screen.
4. **Given** the device does not have a compass sensor, **When** the Qibla screen loads, **Then** the compass widget shows the Qibla direction as a static angle (no rotation) and displays the message "لا يوجد بوصلة على هذا الجهاز" with a visual indicator that rotation is unavailable.
5. **Given** the Qibla API request fails and no cached direction exists, **When** the screen loads, **Then** an error banner is displayed and the compass needle is hidden; the city name and stats cards show their last known values or a clear error state.
6. **Given** a previously cached Qibla direction exists and the API request fails, **When** the screen loads, **Then** the cached direction is used to display the compass and a subtle "آخر تحديث: [date]" badge is shown.

---

### Edge Cases

- What happens when GPS takes more than 10 seconds to acquire a location? The screen shows a loading state with a spinner in place of the compass; the user is not shown a blank screen.
- What happens when the user physically moves to a significantly different location (e.g., different city)? The Qibla direction refreshes automatically when the location changes beyond a meaningful threshold.
- What happens when the device compass reading jumps erratically (magnetic interference)? The compass rotation uses smoothing/filtering so that erratic sensor noise does not cause the needle to flicker or spin wildly.
- What happens when the "انتقل" button is tapped but no maps app is installed? The system shows a brief toast/snack bar message explaining that no navigation app was found.
- What happens in airplane mode with a cached Qibla direction? The compass still works correctly using the cached direction; the city name and stats display the last known values.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display a circular animated compass on the Qibla screen that rotates in real-time based on the device's physical orientation.
- **FR-002**: The compass needle MUST always point toward Mecca (Masjid al-Haram, lat 21.3891, lon 39.8579) regardless of which direction the user physically faces.
- **FR-003**: The system MUST fetch the precise Qibla bearing angle for the user's GPS coordinates from an external Qibla direction service and cache it locally.
- **FR-004**: The system MUST display a direction badge below the compass showing the cardinal abbreviation (e.g., "SE") and the Qibla angle in degrees (e.g., "١٣٥°").
- **FR-005**: The system MUST display the user's current city name and country in a location chip below the app bar (e.g., "القاهرة، مصر").
- **FR-006**: The system MUST display two stat cards below the direction badge: one showing distance to Mecca in kilometers and one showing the exact Qibla bearing angle in decimal degrees.
- **FR-007**: The distance to Mecca MUST be calculated locally using the Haversine formula and the user's GPS coordinates.
- **FR-008**: The compass widget MUST contain a golden mosque/Ka'ba icon at its center as a visual reference point.
- **FR-009**: The system MUST display a calibration hint row below the stat cards containing an icon and the instruction text "حرك هاتفك على شكل رقم (8) لزيادة دقة البوصلة". When sensor accuracy is low, the hint row MUST be visually more prominent (e.g., highlighted border or warning icon).
- **FR-009a**: The system MUST display a persistent accuracy badge within the compass area showing the current sensor accuracy at all times as one of three states: "دقة منخفضة" (Low), "دقة متوسطة" (Medium), or "دقة عالية" (High). The badge is always visible while the compass is active, regardless of accuracy level.
- **FR-010**: When the device is online, the system MUST display a "أقرب مسجد إليك" card at the bottom of the screen showing the nearest mosque name and approximate distance from a live network query. The card MUST be hidden entirely when the device is offline or the query fails; no cached mosque data is shown.
- **FR-011**: Users MUST be able to tap an "انتقل" button on the nearest mosque card to open the device's native maps application with the mosque as the navigation destination.
- **FR-012**: When location permission is not granted, the system MUST display a permission request card instead of the compass, with a clear call-to-action to grant permission.
- **FR-013**: When the device lacks a compass sensor, the system MUST display the Qibla direction as a static bearing and show the message "لا يوجد بوصلة على هذا الجهاز".
- **FR-014**: When the Qibla direction cannot be fetched and no cached value exists, the system MUST show an error state with a clear message; the compass needle MUST be hidden.
- **FR-015**: When a cached Qibla direction is used due to API failure, the system MUST indicate that cached data is being displayed (e.g., last update timestamp).
- **FR-016**: All loading states (compass, stats, mosque card) MUST show skeleton/shimmer placeholders rather than blank areas.
- **FR-017**: Compass rotation MUST be smoothed to prevent erratic needle movement from sensor noise.
- **FR-018**: The feature MUST operate with a previously cached Qibla direction when no internet is available.
- **FR-019**: The system MUST NOT persist raw GPS coordinates (latitude/longitude) to local storage at any time. Only derived values — the Qibla bearing angle, city name string, and distance to Mecca — may be stored locally.

### Key Entities

- **Qibla Direction**: A bearing angle in degrees from true north, specific to the user's GPS coordinates, indicating the direction toward Mecca. Fetched remotely and cached locally. Remains valid until the user moves a significant geographic distance.
- **User Location**: The device's current GPS coordinates (latitude, longitude), used transiently at runtime to calculate the Qibla direction and distance to Mecca, and reverse-geocoded to a human-readable city name and country for display. Raw coordinates are never written to persistent storage; only the derived city name string is cached.
- **Compass Heading**: A real-time stream of the device's magnetic bearing in degrees, sourced from the device's magnetometer sensor. Combined with the Qibla Direction to calculate how far to rotate the compass widget.
- **Nearest Mosque**: The name, geographic coordinates, and approximate distance of the closest mosque to the user's current location. Used to populate the bottom mosque card and drive native maps navigation.
- **Distance to Mecca**: A calculated value in kilometers representing the great-circle distance between the user's current GPS coordinates and Mecca (lat 21.3891, lon 39.8579), computed locally via Haversine formula.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can open the Qibla screen and see a working compass needle pointing toward Mecca within 5 seconds of granting location permission (on a stable network connection).
- **SC-002**: The compass needle updates its rotation within 100 milliseconds of a device orientation change, creating a smooth and real-time feel with no visible lag.
- **SC-003**: The displayed Qibla bearing angle matches the known correct angle for the user's location within ±1 degree.
- **SC-004**: The displayed distance to Mecca matches the geodesic distance for the user's location within ±10 kilometers.
- **SC-005**: When no internet is available and a cached Qibla direction exists, the compass still loads and functions correctly within 3 seconds.
- **SC-006**: 100% of users who open the Qibla screen see either the working compass or a clear, actionable error message — no user ever sees a blank or broken screen.
- **SC-007**: Users can navigate from the Qibla screen to the nearest mosque in their native maps app in a single tap.
- **SC-008**: The calibration hint is visible to all users who scroll past the stats cards without requiring any additional interaction.

---

## Assumptions

- The user's device runs iOS or Android; the feature is not intended for desktop/web.
- The majority of target users are located in the MENA region; the default compass and distance figures are calibrated against this expectation, but the feature is correct for any global location.
- Reverse geocoding (converting GPS coordinates to a city name) may rely on a system-level or bundled service; if unavailable, the city name falls back to displaying the raw coordinates.
- The nearest mosque data source is a live remote query (e.g., Overpass API); the nearest mosque card is hidden whenever the device is offline or the query fails. No mosque data is ever cached locally.
- A previously cached Qibla direction is considered valid indefinitely as long as the user has not moved more than 50 km from the location at which it was fetched. There is no time-based cache expiry — the bearing for a fixed location is geographically constant.
- The Qibla direction does not change significantly for typical user movements (within a city); a cached result is therefore reliable for daily use with no time limit.
- The feature is always in RTL (right-to-left) layout; no LTR configuration is required.
- Sharing the Qibla direction or taking a screenshot to share is out of scope for this phase.
- Augmented reality (AR) overlay mode is out of scope for this phase.
- The compass widget uses the device's magnetic north corrected for declination where the sensor API provides it; no manual declination offset is applied by the app.
