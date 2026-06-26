# Feature Specification: Quran Surah List (قائمة السور)

**Feature Branch**: `006-quran-surah-list`

**Created**: 2026-06-26

**Status**: Draft

**Input**: User description: "Phase 2 — Quran Surah List. Display all 114 surahs in a scrollable list. Support bookmarking a surah, showing last read position, and searching by surah name. Tabs: Surahs / Juz / Bookmarks."

**Design References**:
- Figma Node 1-970: Quran screen — surah list view
- Figma Node 1-805: Quran screen — alternate / detail state

---

## Clarifications

### Session 2026-06-26

- Q: When a user taps a surah card in Phase 2, what should happen given the reader (Phase 3) does not exist yet? → A: Navigate to a named per-surah stub screen showing the surah's Arabic name and a "قريباً" (Coming Soon) message — fully wired navigation, empty reader placeholder.
- Q: In Phase 2, what mechanism writes the "last read" position that drives the "Continue Reading" banner? → A: Phase 3 (Quran reader) is the sole writer of last read positions. The banner infrastructure is specced and built in Phase 2 but will always render hidden until Phase 3 ships and writes its first position.
- Q: Does the search bar apply only on the Surahs tab, or does it also filter the Juz and Bookmarks tabs? → A: Search is visible and functional on the Surahs tab only; it is hidden when the user switches to the Juz or Bookmarks tabs.
- Q: Which canonical term and icon should represent saved surahs — Bookmark or Favourite? → A: Bookmark (إشارة مرجعية) with a 🔖 bookmark icon. The tab label remains "المفضلة" as a familiar Arabic UI convention; the entity, icon, and all spec references use "Bookmark".
- Q: What is the layout of the Juz tab — collapsible accordion or flat list with sticky headers? → A: Flat scrollable list with sticky Juz section headers — all surahs are always visible; the Juz header pins at the top of the viewport while scrolling through its surahs.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Browse All Surahs (Priority: P1)

A user opens the Quran screen and sees the complete list of all 114 surahs of the Holy Quran. Each entry displays the surah number in a decorative Arabic-numeral circle, the full Arabic name of the surah, its English transliteration, a badge indicating whether it was revealed in Mecca or Medina, and the total number of verses. The list is scrollable and loads quickly.

**Why this priority**: Presenting the full, accurate surah list is the core purpose of this screen. Every other story (search, bookmarks, last read) depends on this list being correctly rendered.

**Independent Test**: Can be fully tested by opening the Quran screen and verifying 114 surah entries are displayed in order with all four data points visible for each entry.

**Acceptance Scenarios**:

1. **Given** the user opens the Quran screen, **When** the screen loads, **Then** all 114 surahs are displayed in canonical order (Al-Fatiha first, An-Nas last), each showing its Arabic name, English transliteration, revelation type (مكية / مدنية), and verse count.
2. **Given** the surah list has loaded, **When** the user scrolls to the bottom, **Then** all 114 surahs are accessible without truncation.
3. **Given** surah data is not yet loaded, **When** the screen opens, **Then** skeleton placeholder cards are shown in place of surah entries until data is available, maintaining layout stability.
4. **Given** surah data was previously cached, **When** the user opens the Quran screen without internet, **Then** the full surah list is still displayed from cache without any missing entries.

---

### User Story 2 — Search for a Surah (Priority: P1)

A user wants to find a specific surah quickly. While on the Surahs tab, they tap the search bar and type part of a surah name in Arabic or English. The list immediately filters to show only matching surahs. Clearing the search restores the full list. The search bar is not available on the Juz or Bookmarks tabs.

**Why this priority**: With 114 surahs, manual scrolling to find a specific one is tedious. Search is a core productivity feature that significantly reduces time-to-surah.

**Independent Test**: Can be fully tested by typing Arabic or English text in the search bar and verifying that only surahs matching the query are shown, and that clearing the field restores all 114 surahs.

**Acceptance Scenarios**:

1. **Given** the user is on the Surahs tab, **When** they tap the search bar and type an Arabic name (e.g., "البقرة"), **Then** only surahs whose Arabic name contains that text are shown.
2. **Given** the user types an English transliteration (e.g., "Al-Baqara"), **When** the list filters, **Then** the matching surah appears in the results.
3. **Given** the user types a query that matches no surah, **When** the filter runs, **Then** a clear empty-state message is shown (e.g., "لا توجد نتائج لـ «...»") with an option to clear the search.
4. **Given** the user has typed a search query, **When** they clear the search field, **Then** all 114 surahs are immediately restored without any additional tap.
5. **Given** the search bar is active, **When** the user types any text, **Then** results update with each keystroke (no submit button required).

---

### User Story 3 — Resume Last Read (Priority: P1)

A returning user who has previously used the Quran reader (Phase 3) opens the Quran screen and sees a prominent "Continue Reading" banner at the top, showing the name of the surah and ayah they last read. Tapping it takes them to that surah. In Phase 2, the banner infrastructure is fully built but will always be hidden because Phase 3 — the sole writer of last-read positions — does not yet exist.

**Why this priority**: Continuity of reading is a deeply meaningful feature for Quran recitation. Building the banner in Phase 2 ensures it is ready to activate the moment Phase 3 ships, with no rework required on the list screen.

**Independent Test**: Can be tested by injecting a mock "last read" position directly into storage, opening the Quran screen, and verifying the banner appears with the correct surah name and ayah number; in a clean install (no stored position) the banner must be absent.

**Acceptance Scenarios**:

1. **Given** a last-read position (surah + ayah) has been stored by Phase 3, **When** the user opens the Quran screen, **Then** a "استكمل القراءة" (Continue Reading) banner is displayed at the top showing the surah's Arabic name and the last ayah number.
2. **Given** the last read banner is visible, **When** the user taps it, **Then** the app navigates to the surah stub screen for the saved surah (showing its name and "قريباً"); in Phase 3 this same tap will open the reader at the saved ayah position.
3. **Given** no last-read position has ever been stored (Phase 3 has not yet written one), **When** the user opens the Quran screen, **Then** no banner is shown and the surah list fills the full screen area.
4. **Given** a last read position exists, **When** Phase 3 updates it to a newer ayah and the user returns to the surah list, **Then** the banner updates to reflect the new position.

---

### User Story 4 — Browse Surahs by Juz (Priority: P2)

A user who organises their reading by the 30 Juz divisions of the Quran taps the "الأجزاء" tab. The screen shows a flat scrollable list where all surahs are always visible, grouped under their respective Juz. Each Juz header sticks to the top of the viewport as the user scrolls through its surahs, then gives way to the next Juz header.

**Why this priority**: Many Muslims pace their Quran recitation by Juz (especially during Ramadan — one Juz per day). This alternate organisation provides a familiar and spiritually meaningful navigation mode.

**Independent Test**: Can be tested by switching to the Juz tab and verifying 30 sticky Juz section headers appear in order, each followed by the correct surah entries, with the header pinning at the top while scrolling within that Juz.

**Acceptance Scenarios**:

1. **Given** the user is on the Quran screen, **When** they tap the "الأجزاء" tab, **Then** a flat list appears showing all surahs grouped under 30 numbered Juz headers in canonical order, with all surahs visible without any expand/collapse interaction.
2. **Given** the Juz view is active and the user scrolls, **When** a Juz header reaches the top of the visible list, **Then** it sticks (pins) there until the next Juz header scrolls up and replaces it.
3. **Given** the Juz view is active, **When** the user taps a surah entry within a Juz section, **Then** they are navigated to the surah stub screen for that surah.

---

### User Story 5 — Bookmark a Surah (Priority: P2)

A user wants to save a surah for quick access later. They tap the 🔖 bookmark icon on a surah card. The icon fills with gold to indicate the surah is saved. They can then find all bookmarked surahs on the "المفضلة" tab. Tapping the filled bookmark icon again removes it.

**Why this priority**: Bookmarks enable personalisation and quick access to frequently recited surahs (e.g., Al-Kahf on Fridays). This enhances daily engagement without adding complexity.

**Independent Test**: Can be tested by bookmarking a surah, switching to the Bookmarks tab, and verifying the surah appears there; then removing the bookmark and verifying it disappears.

**Acceptance Scenarios**:

1. **Given** the user views any surah card, **When** they tap the bookmark icon, **Then** the icon updates to show the surah is saved and the change persists after the app is closed and reopened.
2. **Given** the user has bookmarked one or more surahs, **When** they tap the "المفضلة" tab, **Then** only their bookmarked surahs are listed.
3. **Given** a surah is already bookmarked, **When** the user taps its bookmark icon again, **Then** it is removed from bookmarks and no longer appears in the Bookmarks tab.
4. **Given** the user has no bookmarks, **When** they open the "المفضلة" tab, **Then** a friendly empty state is shown (e.g., "لا توجد سور محفوظة بعد — احفظ سورة لتجدها هنا") with guidance to add bookmarks.

---

### Edge Cases

- What happens when surah data fails to load and no cache exists? → A clear error state is displayed with a retry button and an Arabic error message; the screen does not remain blank.
- What happens when the user's search query contains diacritics (tashkeel) that differ from the stored name? → Search is normalised to ignore diacritics so "البَقَرَة" and "البقرة" both match.
- What happens if there are 0 bookmarks and the user lands on the Bookmarks tab directly? → A friendly empty-state illustration and message guide the user to the Surahs tab to add bookmarks.
- What happens when the last-read position refers to a surah that cannot be found (data corruption)? → The banner is silently hidden; no crash or broken state is shown.
- What happens when data is loading and the user switches tabs? → Each tab independently reflects its own loading state; switching never freezes or crashes the screen.
- What happens on very slow connections where skeleton loading lasts many seconds? → Skeleton cards remain visible and a subtle loading indicator confirms progress; no timeout screen replaces the skeletons within a reasonable time window.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display all 114 surahs of the Holy Quran in canonical order on the Surahs tab.
- **FR-002**: Each surah entry MUST display: the surah number, the full Arabic name, the English transliteration, the revelation type (مكية or مدنية), and the total number of verses.
- **FR-003**: The Quran screen MUST contain three tabs: السور (Surahs), الأجزاء (Juz), المفضلة (Bookmarks).
- **FR-004**: The system MUST display a real-time search bar on the Surahs tab that filters the surah list as the user types, matching against both Arabic names and English transliterations. The search bar MUST be hidden when the user navigates to the Juz or Bookmarks tabs.
- **FR-005**: Search results MUST be diacritic-normalised so that searches with or without tashkeel return the same results.
- **FR-006**: When a search query yields no results, the system MUST display an informative empty-state message specific to the query.
- **FR-007**: The system MUST display a "Continue Reading" (استكمل القراءة) banner at the top of the Quran screen when a last-read position (surah + ayah) is present in storage, showing the surah's Arabic name and the ayah number. The last-read position is written exclusively by the Quran reader (Phase 3); in Phase 2 the banner will always be hidden because no writer exists yet. The banner component MUST be fully built and reactive to storage so it activates automatically when Phase 3 ships.
- **FR-008**: Tapping any surah card (from the Surahs list, Juz view, or Bookmarks tab) or the "Continue Reading" banner MUST navigate the user to a per-surah stub screen displaying the surah's Arabic name and a "قريباً" placeholder. This stub acts as the Phase 3 reader entry point; the navigation route and surah identifier MUST be passed so Phase 3 can replace the stub without changing the call site.
- **FR-009**: The system MUST cache the full surah list locally after first load so it is available without an internet connection on subsequent sessions.
- **FR-010**: The Juz tab MUST present a flat scrollable list of all surahs grouped under 30 clearly labelled Juz section headers in canonical order. All surahs MUST be visible without any expand/collapse interaction. Juz headers MUST stick (pin) to the top of the viewport as the user scrolls through their respective surahs.
- **FR-011**: The system MUST allow users to bookmark or unbookmark any surah via a 🔖 bookmark toggle icon on each surah card. The icon MUST render as an outlined bookmark when not saved and as a filled gold bookmark when saved.
- **FR-012**: Bookmark state MUST persist across app restarts.
- **FR-013**: The Bookmarks tab MUST display only the surahs the user has bookmarked; when empty, it MUST show a friendly empty-state message.
- **FR-014**: While surah data is loading, the system MUST show skeleton placeholder cards to maintain layout stability and communicate progress.
- **FR-015**: When surah data cannot be loaded and no cache exists, the system MUST show an error state with a retry action rather than a blank or crashed screen.
- **FR-016**: The entire screen MUST use a right-to-left layout with Arabic as the primary display language.

### Key Entities

- **Surah**: Represents a chapter of the Quran. Has a canonical number (1–114), a full Arabic name, an English transliteration, a revelation origin (Meccan or Medinan), and a total verse count. Order is fixed by Islamic tradition.
- **Juz**: Represents one of the 30 roughly equal divisions of the Quran used for reading pace. Contains multiple surahs (or parts of surahs). Juz membership is fixed.
- **Last Read Position**: Represents the most recent position a user reached while reading the Quran. Contains a surah number and an ayah number within that surah. Only one position is tracked at a time (the most recent). Written exclusively by the Quran reader (Phase 3); Phase 2 only reads and displays it.
- **Bookmark**: Represents a user's saved reference to a specific surah for quick access. Each bookmark is tied to one surah. A user may have multiple bookmarks. Bookmarks have no order beyond the canonical surah order.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The surah list is fully visible and interactive within 2 seconds of opening the Quran screen on a standard mobile connection.
- **SC-002**: Returning users with a saved reading position see the "Continue Reading" banner without any additional taps or navigation.
- **SC-003**: Search results appear within 200 milliseconds of each keystroke, with no perceptible delay between typing and filtering.
- **SC-004**: Users can locate any of the 114 surahs by name (Arabic or English) in under 10 seconds from opening the screen.
- **SC-005**: Users who have previously opened the Quran screen can access the full surah list in offline mode without missing data.
- **SC-006**: Bookmarked surahs are accessible immediately from the Bookmarks tab; adding or removing a bookmark takes effect in a single tap with no confirmation dialog required.
- **SC-007**: The surah list, search results, and Juz view render without layout shifts after the skeleton loading phase completes.
- **SC-008**: 90% of users can successfully find and open a specific surah on first attempt without assistance.

---

## Visual Design

> Design references: Figma nodes 1-970 and 1-805 (file: تطبيق ديني)

### Screen Layout

```
┌─────────────────────────────────────────────┐
│  [≡]          القرآن الكريم           [🔍]  │  ← AppBar
├─────────────────────────────────────────────┤
│  السور          الأجزاء       المفضلة        │  ← Tab Bar (gold underline on active)
├─────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────┐ │
│ │  📖  استكمل القراءة                     │ │  ← Last Read Banner (gold border)
│ │      سورة البقرة — الآية ٢٣            │ │
│ └─────────────────────────────────────────┘ │
│ ╔═══════════════════════════════════════╗   │
│ ║  🔍  ابحث عن سورة...              ║   │  ← Search Bar
│ ╚═══════════════════════════════════════╝   │
├─────────────────────────────────────────────┤
│ ┌──────┬──────────────────────────┬──────┐  │
│ │  ١   │ الفاتحة                  │  [🔖] │  │  ← Surah Card
│ │      │ Al-Faatiha               │      │  │
│ │      │ مكية  •  ٧ آيات          │      │  │
│ └──────┴──────────────────────────┴──────┘  │
│  (repeating for all 114 surahs)             │
└─────────────────────────────────────────────┘
```

### Surah Card Anatomy

Each surah card contains:
- **Left**: Surah number in a decorative golden Arabic-numeral circle (داخل إطار دائري ذهبي)
- **Center**: Arabic surah name (Amiri Bold, gold, 18sp) on line 1; English transliteration (Amiri Regular, ivory, 13sp) on line 2; revelation type badge (مكية / مدنية in a small pill) + verse count (ivory, 12sp) on line 3
- **Right**: Bookmark icon 🔖 (outlined = not saved, filled gold = saved)
- **Divider**: Subtle separator line between cards (gold at 10% opacity)

### Color & Typography

| Element | Color | Font |
|---|---|---|
| Background | #1B4332 (deep green) | — |
| Surah Arabic name | #C9A84C (gold) | Amiri Bold 18sp |
| English transliteration | #F5F0E8 (ivory) | Amiri Regular 13sp |
| Revelation badge text | #C9A84C (gold) | Amiri Regular 11sp |
| Revelation badge bg | #C9A84C at 15% opacity | — |
| Number circle border | #C9A84C (gold) | — |
| Tab active underline | #C9A84C (gold) | — |
| Last read banner border | #C9A84C (gold) | — |
| Skeleton cards | #2D5A43 (slightly lighter green) | — |

### States

- **Loading**: Skeleton cards (3 placeholder rows) with shimmer animation
- **Empty search**: Centered Arabic message + search icon illustration
- **Empty bookmarks**: Centered Arabic message + open-book illustration + CTA arrow toward Surahs tab
- **Error (no cache)**: Centered Arabic error message + retry button (gold border, ivory text)

---

## Assumptions

- Surah metadata (name, transliteration, revelation type, verse count) is fetched from a remote data source on first launch and cached locally; it is not bundled with the app at install time.
- Surah metadata is stable and does not require frequent updates; a one-time cache with no TTL is acceptable for this phase.
- The Quran reader screen (Phase 3) is not in scope for this specification; tapping a surah card or the "Continue Reading" banner navigates to a per-surah stub screen showing the surah name and a "قريباً" message. The stub is intentionally wired so Phase 3 can replace it without modifying call sites in Phase 2 code.
- The "Continue Reading" position is a single global value (the most recently read position across all surahs); per-surah reading progress tracking is not required in this phase. Phase 2 builds the banner as a read-only consumer of this value; the Quran reader (Phase 3) is the sole writer.
- Juz assignments for each surah are fixed and can be derived from a static mapping; no API call is needed for Juz organisation.
- Bookmark order follows canonical surah order (surah 1 before surah 2, etc.); custom ordering of bookmarks is not required.
- Search is performed locally on the cached surah list; no server-side search is required.
- The screen is portrait-only and right-to-left; no landscape or LTR layout is required.
- The app supports Arabic-script keyboard input natively via the device's built-in keyboard; no custom keyboard component is required.
- Audio recitation is not part of this phase (Phase 3); no audio controls appear on this screen.
- The Figma designs at nodes 1-970 and 1-805 are the authoritative visual references; the design descriptions in this spec are derived from those designs and should be validated against them during implementation.
