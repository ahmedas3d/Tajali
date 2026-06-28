# Quickstart Validation Guide: Quran Reading & Audio

**Feature**: 007-quran-reader-audio  
**Date**: 2026-06-27

---

## Prerequisites

- Flutter SDK ≥ 3.3.0 installed
- Device/emulator with network access (required for first load and audio)
- Phase 2 (Quran Surah List) fully implemented and merged

---

## Setup

```bash
# From project root
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # regenerate Hive adapters
flutter run
```

---

## Validation Scenarios

Run each scenario in order; each builds on the state left by the previous.

---

### Scenario 1 — Open Surah Reader (P1: Core text display)

**Steps**:
1. Launch app → tap **القرآن** tab
2. Tap **Al-Fatiha (الفاتحة)** in the surah list

**Expected**:
- Reader screen opens with title "سُورَةُ ٱلْفَاتِحَةِ" in the app bar
- Basmala appears as a styled header above the ayah list
- 7 ayahs displayed in `AmiriQuran` font with ayah number markers
- No loading error; text visible within 2 seconds (SC-001)

---

### Scenario 2 — Audio Playback & Ayah Highlighting (P2: Audio)

**Steps** (continue from Scenario 1):
1. Tap the **play** button in the audio player bar at the bottom
2. Watch as ayahs highlight one by one during recitation
3. Tap **pause**; verify audio stops but highlight stays
4. Tap **play** again; verify audio resumes from the same ayah

**Expected**:
- Audio begins within 1.5 seconds of tapping play (SC-002)
- Current ayah highlighted in gold; highlight advances with audio (SC-003: within 200ms)
- Pause/resume works correctly with button icon toggling
- Tapping a different ayah jumps playback to that ayah

---

### Scenario 3 — Audio Stops on Navigation (FR-019)

**Steps**:
1. Start playing Al-Fatiha (audio playing)
2. Press the back button to return to the surah list

**Expected**:
- Audio stops immediately on back press
- No audio continues playing in background

---

### Scenario 4 — Single-Ayah Repeat (FR-020)

**Steps**:
1. Open any surah; tap an ayah to select it
2. Tap the **repeat** toggle button on the player bar (icon: repeat/loop)
3. Tap **play**

**Expected**:
- The selected ayah plays and then loops continuously
- Highlight stays on the same ayah and never advances
- Tapping a different ayah while repeat is active: that new ayah loops instead
- Turning off repeat: playback advances normally from current ayah

---

### Scenario 5 — Change Reciter (P2: Reciter selection)

**Steps**:
1. Open a surah; tap the **reciter name/icon** in the player area
2. Select **عبد الصمد** from the picker
3. Tap play

**Expected**:
- Audio uses Abdul Samad's recitation (noticeably different voice)
- Close app and reopen → Abdul Samad is still selected (SC-007)

---

### Scenario 6 — Bookmark Ayah & Deep-Link from Bookmarks Tab (P3: Bookmarks)

**Steps**:
1. Long-press (or tap bookmark icon on) ayah 3 of Al-Baqara
2. Verify bookmark icon fills/activates
3. Navigate back → tap **المفضلة** (Bookmarks) tab on the Quran screen
4. Find the bookmarked ayah in the list; tap it

**Expected**:
- Reader opens at Al-Baqara, scrolled to ayah 3, with it highlighted briefly (FR-015a)
- Navigate away and back; bookmark icon on ayah 3 is still active (SC-005)

---

### Scenario 7 — Remove Bookmark (FR-014)

**Steps**:
1. With ayah 3 of Al-Baqara bookmarked, tap the bookmark icon again

**Expected**:
- Icon returns to inactive state
- Bookmarks tab no longer shows the entry after navigating away and back

---

### Scenario 8 — Font Size Adjustment (P3: Accessibility)

**Steps**:
1. In the reader, open the **display settings** (font size control — e.g., settings icon in app bar)
2. Increase font size to largest option

**Expected**:
- Ayah text grows immediately (under 100ms — SC-006)
- Navigate to a different surah: same font size applies
- Restart app: font size preference restored (SC-007)

---

### Scenario 9 — Reading Position Restored (P3: Session continuity)

**Steps**:
1. Open Al-Baqara; scroll down to ayah 50
2. Close the app completely
3. Reopen → tap Al-Baqara in the surah list

**Expected**:
- Reader auto-scrolls to ayah 50 (or the last visible ayah)
- Al-Fatiha still opens at the beginning (per-surah position is independent)

---

### Scenario 10 — Offline: Cached Surah (FR-004)

**Steps**:
1. Open Al-Fatiha once (with internet) to populate cache
2. Disable device network
3. Navigate back and re-open Al-Fatiha

**Expected**:
- Text displays from cache with no error
- Audio player bar shows an info banner explaining audio requires internet; play button is disabled

---

### Scenario 11 — Offline: Uncached Surah

**Steps**:
1. With network disabled, navigate to a surah that has NOT been previously opened

**Expected**:
- Loading indicator appears briefly
- Error message appears in Arabic explaining no internet + no cache
- Retry button visible; tapping it re-attempts the fetch

---

### Scenario 12 — Surah At-Tawbah (Surah 9 — No Basmala)

**Steps**:
1. Open Surah At-Tawbah (surah 9)

**Expected**:
- No Basmala header displayed above ayahs
- First ayah displayed directly

---

## Performance Checks

After all scenarios, verify:

| Check | Target | Method |
|---|---|---|
| Cached surah open time | < 300ms | Use Flutter DevTools Timeline |
| First load (with network) | < 2s visible | Observe loading indicator duration |
| Audio start latency | < 1.5s | Tap play and count |
| Highlight advance lag | < 200ms | Watch highlight jump between ayahs |

---

## Known Out-of-Scope Items (do not test in this phase)

- Audio plays while app is in background
- Quran translation display
- Sharing individual ayahs
- Full-surah loop/repeat
- Search within reader
