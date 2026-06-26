# PLAN2 — Tajali App (تجلي) — Development Phases

**App:** Tajali — Islamic Companion App  
**Framework:** Flutter (Dart)  
**Architecture:** Feature-first Clean Architecture  
**State Management:** Riverpod  

---

## Phase Overview

| Phase | Feature | Type | Depends On |
|-------|---------|------|------------|
| Phase 0 | Splash Screen & Onboarding | UI + Local Storage | — |
| Phase 1 | Prayer Times | Feature + API | Location permission |
| Phase 2 | Quran — Surah List | Feature + API | — |
| Phase 3 | Quran — Reading & Audio | Feature + API | Phase 2 |
| Phase 4 | Adhkar & Dua | Feature (offline) | — |
| Phase 5 | Qibla Compass | Feature + API | Location permission |
| Phase 6 | Tasbih Counter | Feature (offline) | — |
| Phase 7 | Notifications (Azan) | Feature | Phase 1 |
| Phase 8 | Testing | Unit + Widget + Integration + Golden | All phases |
| Phase 9 | Polish & Release Prep | — | All phases |

---

## Phase 0 — Splash Screen & Onboarding

### Feature Description
First-launch experience. Shows a branded splash screen, then walks the user through 3 onboarding slides. Requests location and notification permissions inside onboarding. On subsequent launches, skips directly to the home screen.

### Screens
- `SplashScreen` — animated app intro (shown every launch, ~2.5 seconds)
- `OnboardingScreen` — 3-slide walkthrough (shown only on first launch)

---

### Screen 0.1 — Splash Screen

#### Behavior
- Shown every time the app launches
- Duration: ~2.5 seconds
- After duration: check if first launch
  - First launch → navigate to `OnboardingScreen`
  - Returning user → navigate to `MainNavigation` (home)

#### Visual Design
- Full screen deep green background `#1B4332`
- Center: app logo — golden 8-pointed Islamic star with app name "تجلي" below it in Amiri Bold gold
- Tagline below name: "رفيقك الروحي اليومي" in small ivory Amiri
- Animation sequence:
  1. Logo fades in + scales up gently (0 → 1.0 scale, 800ms)
  2. Tagline fades in (delay 600ms, 400ms duration)
  3. Hold for 800ms
  4. Entire screen fades out (300ms) → navigate

#### Implementation

```dart
// lib/features/splash/presentation/splash_screen.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    final isFirstLaunch = await OnboardingService().isFirstLaunch();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isFirstLaunch
              ? const OnboardingScreen()
              : const MainNavigation(),
        ),
      );
    }
  }
}
```

---

### Screen 0.2 — Onboarding (3 Slides)

#### Behavior
- Shown only on first launch
- User can swipe between slides or tap "التالي"
- Last slide has a "ابدأ الآن" button that:
  1. Requests location permission
  2. Requests notification permission
  3. Marks onboarding as complete in SharedPreferences
  4. Navigates to `MainNavigation`
- Skip button available on slides 1 and 2 (top left) — jumps to slide 3

#### Slide Layout (shared structure)
Each slide contains (top to bottom):
- Full-screen background: deep green gradient `#1B4332` → `#0D2218`
- Decorative Islamic geometric pattern at top (SVG, gold, 15% opacity)
- Illustration area (center): custom SVG illustration per slide
- Slide title: Amiri Bold, gold, 24px, centered
- Slide subtitle: Amiri Regular, ivory, 15px, centered, max 2 lines
- Bottom area: page indicator dots + action button

---

#### Slide 1 — Welcome

**Title:** `أهلاً بك في تجلي`  
**Subtitle:** `رفيقك الروحي في كل يوم — قرآن، أذكار، صلاة، وقبلة`

**Illustration:**
- Centered golden mosque silhouette (dome + minarets)
- Behind it: soft golden circular glow (radial gradient)
- Stars scattered lightly around the mosque
- Style: flat Islamic illustration, warm gold on dark green

**Animation:** illustration slides up + fades in on page appear

---

#### Slide 2 — Features Highlight

**Title:** `كل ما تحتاجه في مكان واحد`  
**Subtitle:** `مواقيت الصلاة • القرآن الكريم • الأذكار • القبلة • التسبيح`

**Illustration:**
- 5 feature icons arranged in a gentle arc or pentagon shape
- Each icon in a small golden hexagon card:
  - 🕌 مواقيت الصلاة
  - 📖 القرآن
  - 📿 الأذكار
  - 🧭 القبلة
  - ☪️ التسبيح
- Icons illustrated in gold on dark green backgrounds
- Subtle connecting lines between hexagons (golden dotted)

**Animation:** icons appear one by one with stagger (100ms delay each)

---

#### Slide 3 — Permissions Request

**Title:** `نحتاج إذنك`  
**Subtitle:** `لنقدم لك أوقات الصلاة الدقيقة واتجاه القبلة حسب موقعك`

**Illustration:**
- Large golden compass rose illustration centered
- Below it: location pin icon with golden glow pulse

**Permission Items (shown as cards below subtitle):**

```
┌─────────────────────────────────────────┐
│  📍  الموقع الجغرافي                     │
│      لتحديد مواقيت الصلاة والقبلة        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  🔔  الإشعارات                           │
│      لتذكيرك بأوقات الأذان              │
└─────────────────────────────────────────┘
```

- Each card: ivory background, golden border, icon + title + subtitle
- Both cards visible before tapping "ابدأ الآن"

**Button:** `ابدأ الآن` — large, full-width, deep green background, gold text, golden border

---

#### Bottom Navigation Area (all slides)

```
[Skip]                    ●  ○  ○        [التالي →]
                    (page dots)
```

- Page dots: active = gold filled circle, inactive = ivory outline circle
- "التالي" button: gold text, no background (text button)
- "Skip" button: muted ivory text, top-left corner (slides 1 & 2 only)
- Slide 3: replaces "التالي" with "ابدأ الآن" (full-width primary button)

---

### Data Models

```dart
class OnboardingSlide {
  final String title;
  final String subtitle;
  final String illustrationAsset;  // SVG path
  final Color backgroundColor;
}
```

### Services

```dart
// lib/features/splash/data/services/onboarding_service.dart
class OnboardingService {
  static const _key = 'onboarding_complete';

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
```

### State Management

```dart
final onboardingPageProvider = StateProvider<int>((ref) => 0);

final onboardingSlidesProvider = Provider<List<OnboardingSlide>>((ref) => [
  OnboardingSlide(
    title: 'أهلاً بك في تجلي',
    subtitle: 'رفيقك الروحي في كل يوم',
    illustrationAsset: 'assets/svg/onboarding_mosque.svg',
    backgroundColor: AppColors.primaryGreen,
  ),
  OnboardingSlide(
    title: 'كل ما تحتاجه في مكان واحد',
    subtitle: 'مواقيت الصلاة • القرآن • الأذكار • القبلة • التسبيح',
    illustrationAsset: 'assets/svg/onboarding_features.svg',
    backgroundColor: AppColors.primaryGreen,
  ),
  OnboardingSlide(
    title: 'نحتاج إذنك',
    subtitle: 'لنقدم لك أوقات الصلاة الدقيقة واتجاه القبلة',
    illustrationAsset: 'assets/svg/onboarding_permissions.svg',
    backgroundColor: AppColors.primaryGreen,
  ),
]);
```

### Permission Handling (Slide 3)

```dart
Future<void> _requestPermissionsAndProceed() async {
  // 1. Request location permission
  final locationStatus = await Permission.locationWhenInUse.request();

  // 2. Request notification permission (Android 13+)
  final notifStatus = await Permission.notification.request();

  // 3. Mark onboarding complete regardless of permission result
  await OnboardingService().markOnboardingComplete();

  // 4. Navigate to main app
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (_) => false,
    );
  }
}
```

### Assets Required

```
assets/
├── svg/
│   ├── onboarding_mosque.svg       ← mosque illustration (slide 1)
│   ├── onboarding_features.svg     ← feature icons grid (slide 2)
│   └── onboarding_permissions.svg  ← compass + location (slide 3)
├── images/
│   └── splash_logo.png             ← app logo (star + name)
```

### App Launch Flow

```
App Start
    │
    ▼
SplashScreen (2.5s animation)
    │
    ├── isFirstLaunch = true ──▶ OnboardingScreen
    │                                   │
    │                           Slide 1 → Slide 2 → Slide 3
    │                                               │
    │                                    Request Permissions
    │                                               │
    │                                    markOnboardingComplete()
    │                                               │
    └── isFirstLaunch = false ─────────▶ MainNavigation (Home)
```

### Testing (Phase 0)

**Unit Tests:**
```dart
// test/unit/onboarding_service_test.dart
test('isFirstLaunch returns true before onboarding', () async { ... });
test('isFirstLaunch returns false after markOnboardingComplete', () async { ... });
```

**Widget Tests:**
```dart
// test/widget/splash_screen_test.dart
testWidgets('SplashScreen shows app name', (tester) async { ... });
testWidgets('OnboardingScreen renders 3 slides', (tester) async { ... });
testWidgets('Skip button navigates to slide 3', (tester) async { ... });
```

**Golden Tests:**
```dart
// test/golden/splash_golden_test.dart
matchesGoldenFile('goldens/splash_screen.png');
matchesGoldenFile('goldens/onboarding_slide_1.png');
matchesGoldenFile('goldens/onboarding_slide_2.png');
matchesGoldenFile('goldens/onboarding_slide_3.png');
```

---

## Phase 1 — Prayer Times (مواقيت الصلاة)

### Feature Description
Display the five daily prayer times based on the user's GPS location. Show a countdown to the next prayer, support multiple calculation methods, and display the Hijri date.

### Screens
- `PrayerTimesScreen` — full prayer times list with countdown hero
- `PrayerTimesScreen` is also the source for the home screen prayer card widget

### Data Models

```dart
class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
  final HijriDate hijriDate;
  final int method;
  final double latitude;
  final double longitude;
}

class HijriDate {
  final String day;
  final String monthAr;
  final String year;
  final String readable;
}

class NextPrayerModel {
  final String name;     // e.g. "Asr"
  final String nameAr;   // e.g. "العصر"
  final String time;     // e.g. "15:48"
  final Duration remaining;
}
```

### API Integration — AlAdhan API

**Base URL:** `https://api.aladhan.com/v1`  
**No API Key required. No rate limit.**

#### Endpoints to use:

```
# Get prayer times by GPS coordinates
GET /v1/timings/{DD-MM-YYYY}
  ?latitude={lat}
  &longitude={lon}
  &method={method}
  &school={0|1}
  &timezonestring={timezone}

# Get next prayer
GET /v1/nextPrayer/{DD-MM-YYYY}
  ?latitude={lat}
  &longitude={lon}
  &method={method}

# Get qibla direction (reused in Phase 5)
GET /v1/qibla/{latitude}/{longitude}

# Convert Gregorian to Hijri
GET /v1/gToH/{DD-MM-YYYY}
```

#### Default parameters:
- `method=5` — Egyptian General Authority of Survey (default for Arabic users)
- `school=0` — Shafi'i

#### Response fields to extract:
```
data.timings.Fajr
data.timings.Sunrise
data.timings.Dhuhr
data.timings.Asr
data.timings.Maghrib
data.timings.Isha
data.timings.Imsak
data.date.hijri.date
data.date.hijri.month.ar
data.date.hijri.year
```

### Services

```dart
// lib/features/prayer_times/data/services/prayer_times_service.dart
class PrayerTimesService {
  Future<PrayerTimesModel> getTodayTimes(double lat, double lon, int method);
  Future<NextPrayerModel> getNextPrayer(double lat, double lon, int method);
  Future<String> getHijriDate(String gregorianDate);
}

// lib/core/services/location_service.dart
class LocationService {
  Future<Position> getCurrentPosition();
  Future<bool> requestPermission();
}
```

### State Management (Riverpod)

```dart
// Providers
final locationProvider = FutureProvider<Position>((ref) => ...);
final prayerTimesProvider = FutureProvider.family<PrayerTimesModel, Position>((ref, pos) => ...);
final nextPrayerProvider = StreamProvider<NextPrayerModel>((ref) => ...); // updates every minute
final calculationMethodProvider = StateProvider<int>((ref) => 5);
```

### Local Storage
- Cache today's prayer times in Hive to work offline after first load
- Store user's preferred calculation method in SharedPreferences
- Cache last known location

### Error Handling
| Error | Behavior |
|-------|----------|
| No location permission | Show permission dialog, fallback to manual city entry |
| No internet | Show cached times with "last updated" timestamp |
| API error (5xx) | Show cached times, display error banner |
| Location timeout | Use last known location |

---

## Phase 2 — Quran Surah List (قائمة السور)

### Feature Description
Display all 114 surahs in a scrollable list. Support bookmarking a surah, showing last read position, and searching by surah name.

### Screens
- `QuranScreen` — surah list with search and tabs (Surahs / Juz / Bookmarks)

### Data Models

```dart
class SurahModel {
  final int number;
  final String name;           // "سُورَةُ ٱلْفَاتِحَةِ"
  final String englishName;    // "Al-Faatiha"
  final String revelationType; // "Meccan" | "Medinan"
  final int numberOfAyahs;
}

class LastReadModel {
  final int surahNumber;
  final int ayahNumber;
  final DateTime timestamp;
}
```

### API Integration — AlQuran Cloud

**Base URL:** `https://api.alquran.cloud/v1`

```
# Get list of all surahs (metadata only, no text)
GET /v1/surah
```

#### Strategy:
- Fetch surah list once on first launch → cache in Hive
- Do NOT fetch all Quran text upfront — lazy load per surah in Phase 3

### Services

```dart
class QuranService {
  Future<List<SurahModel>> getAllSurahs();      // cached after first call
  Future<SurahModel> getSurah(int number);
}
```

### State Management

```dart
final surahListProvider = FutureProvider<List<SurahModel>>((ref) => ...);
final lastReadProvider = StateProvider<LastReadModel?>((ref) => ...);
final quranSearchProvider = StateProvider<String>((ref) => '');
final filteredSurahsProvider = Provider<List<SurahModel>>((ref) => ...); // derived
```

### Local Storage
- Cache full surah metadata list in Hive after first API call
- Store last read (surahNumber + ayahNumber) in SharedPreferences

---

## Phase 3 — Quran Reading & Audio (شاشة القراءة والتلاوة)

### Feature Description
Display full surah text in Uthmanic script. Play audio recitation per ayah or full surah. Support multiple reciters. Allow bookmarking individual ayahs.

### Screens
- `QuranReaderScreen` — full Quran reading view with audio player bar

### Data Models

```dart
class AyahModel {
  final int number;
  final int numberInSurah;
  final String text;           // Arabic text (Uthmanic)
  final String? audioUrl;      // mp3 URL from AlQuran Cloud
  final int juz;
  final int page;
}

class ReciterModel {
  final String identifier;  // e.g. "ar.alafasy"
  final String nameAr;      // "مشاري العفاسي"
  final String nameEn;      // "Mishary Alafasy"
}
```

### API Integration — AlQuran Cloud

```
# Get full surah text (Uthmanic)
GET /v1/surah/{number}/quran-uthmani

# Get full surah with audio for specific reciter
GET /v1/surah/{number}/{reciter_edition}
  e.g. GET /v1/surah/1/ar.alafasy

# Get surah in multiple editions at once (text + audio)
GET /v1/surah/{number}/editions/quran-uthmani,ar.alafasy

# Search in Quran
GET /v1/search/{keyword}/all/ar
```

#### Available Reciters (default options):
| Identifier | الاسم |
|------------|-------|
| `ar.alafasy` | مشاري العفاسي |
| `ar.abdulsamad` | عبد الصمد |
| `ar.abdullahbasfar` | عبدالله بصفر |
| `ar.hudhaify` | علي الحذيفي |

#### Audio URL format:
```
https://cdn.islamic.network/quran/audio/128/{edition}/{ayah_global_number}.mp3
e.g. https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3
```

### Services

```dart
class QuranReaderService {
  Future<List<AyahModel>> getSurahWithAudio(int surahNum, String reciterEdition);
  Future<List<AyahModel>> getSurahText(int surahNum);
  Future<List<AyahModel>> searchQuran(String keyword);
}

class AudioPlayerService {
  Future<void> playAyah(String audioUrl);
  Future<void> playSurah(List<String> audioUrls);
  Future<void> pause();
  Future<void> stop();
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
}
```

### State Management

```dart
final currentSurahProvider = StateProvider<int>((ref) => 1);
final selectedReciterProvider = StateProvider<String>((ref) => 'ar.alafasy');
final surahAyahsProvider = FutureProvider.family<List<AyahModel>, int>((ref, surahNum) => ...);
final audioPlayerProvider = Provider<AudioPlayerService>((ref) => ...);
final currentPlayingAyahProvider = StateProvider<int?>((ref) => null);
```

### Local Storage
- Cache fetched surah text in Hive (avoid re-fetching)
- Store bookmarked ayahs as list in Hive
- Store preferred reciter in SharedPreferences

---

## Phase 4 — Adhkar & Dua (الأذكار والدعاء)

### Feature Description
Show categorized Islamic remembrances. Each dhikr has a counter. User can tap through all adhkar in a category. Fully offline.

### Screens
- `AdhkarScreen` — category grid
- `DhikrDetailScreen` — single dhikr with counter and navigation

### Data Models

```dart
class AdhkarCategoryModel {
  final String id;
  final String nameAr;
  final int count;
  final String iconName;
}

class DhikrModel {
  final String text;
  final int repeat;
  final String? source;    // e.g. "رواه مسلم"
  final String? virtue;    // فضل الذكر
}
```

### API Integration — Offline JSON

**Source:** Azkar API (bundled locally)
```
https://raw.githubusercontent.com/nawajalqari/azkar-api/main/azkar.json
```

**Strategy:** Download once, bundle as local asset at `assets/data/azkar.json`.  
No network calls needed at runtime — fully offline.

#### Categories to include:
- أذكار الصباح
- أذكار المساء
- أذكار بعد الصلاة
- أذكار النوم
- أذكار الاستيقاظ
- أدعية متنوعة

### Services

```dart
class AdhkarService {
  Future<List<AdhkarCategoryModel>> getCategories();
  Future<List<DhikrModel>> getDhikrByCategory(String categoryId);
}
```

### State Management

```dart
final adhkarCategoriesProvider = FutureProvider<List<AdhkarCategoryModel>>((ref) => ...);
final currentCategoryProvider = StateProvider<String?>((ref) => null);
final dhikrListProvider = FutureProvider.family<List<DhikrModel>, String>((ref, catId) => ...);
final dhikrCounterProvider = StateNotifierProvider.family<DhikrCounter, int, String>((ref, id) => ...);
```

### Local Storage
- Store completed adhkar progress per day in Hive
- Reset daily counters at midnight

---

## Phase 5 — Qibla Compass (القبلة)

### Feature Description
Show a compass pointing toward Mecca. Fetch Qibla angle from API using GPS. Use device compass sensor for real-time rotation.

### Screens
- `QiblaScreen` — animated compass with Qibla direction

### Data Models

```dart
class QiblaModel {
  final double latitude;
  final double longitude;
  final double direction;    // degrees from North toward Qibla
  final double distanceKm;   // calculated locally
}
```

### API Integration — AlAdhan Qibla

```
GET https://api.aladhan.com/v1/qibla/{latitude}/{longitude}

Response:
{
  "data": {
    "latitude": 30.06,
    "longitude": 31.24,
    "direction": 136.87    ← degrees from North
  }
}
```

#### Distance Calculation (local, no API):
```dart
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  // Haversine formula
  // Mecca coordinates: lat=21.3891, lon=39.8579
}
```

### Flutter Packages Used
- `flutter_compass` — device compass heading stream
- `geolocator` — GPS coordinates

### Services

```dart
class QiblaService {
  Future<double> getQiblaDirection(double lat, double lon);  // from API
  Stream<double> get compassHeading;                          // from sensor
  double calculateDistance(double lat, double lon);           // local
}
```

### State Management

```dart
final qiblaDirectionProvider = FutureProvider<double>((ref) => ...);
final compassHeadingProvider = StreamProvider<double>((ref) => ...);
final qiblaRotationProvider = Provider<double>((ref) {
  final qibla = ref.watch(qiblaDirectionProvider).value ?? 0;
  final heading = ref.watch(compassHeadingProvider).value ?? 0;
  return qibla - heading;   // angle to rotate compass widget
});
```

### Error Handling
| Error | Behavior |
|-------|----------|
| No compass sensor | Show static direction + "لا يوجد بوصلة" message |
| No location | Show permission request |
| API error | Use last cached direction |

---

## Phase 6 — Tasbih Counter (التسبيح)

### Feature Description
Digital tasbih counter. User taps to count. Supports multiple dhikr types, sets target count, vibrates on round completion. Saves daily history. Fully offline.

### Screens
- `TasbihScreen` — large tap button with counter and dhikr selector

### Data Models

```dart
class TasbihSession {
  final String dhikr;       // "سبحان الله"
  final int count;
  final int target;         // e.g. 33
  final int completedRounds;
  final DateTime date;
}

class TasbihHistoryEntry {
  final String dhikr;
  final int totalCount;
  final DateTime date;
}
```

### API Integration
None — fully offline.

### Services

```dart
class TasbihService {
  Future<void> saveSession(TasbihSession session);
  Future<List<TasbihHistoryEntry>> getDailyHistory(DateTime date);
  Future<void> resetToday();
}

class VibrationService {
  Future<void> tap();           // short 30ms on each tap
  Future<void> roundComplete(); // pattern [100, 50, 100] on round completion
}
```

### State Management

```dart
final selectedDhikrProvider = StateProvider<String>((ref) => 'سبحان الله');
final tasbihCountProvider = StateNotifierProvider<TasbihNotifier, TasbihSession>((ref) => ...);
final tasbihHistoryProvider = FutureProvider<List<TasbihHistoryEntry>>((ref) => ...);
final vibrationEnabledProvider = StateProvider<bool>((ref) => true);
final soundEnabledProvider = StateProvider<bool>((ref) => false);
```

### Available Dhikr Options
```
سبحان الله       — target: 33
الحمد لله        — target: 33
الله أكبر        — target: 33
لا إله إلا الله  — target: 100
الاستغفار        — target: 100
الصلاة على النبي  — target: 100
```

---

## Phase 7 — Notifications (إشعارات الأذان)

### Feature Description
Schedule local notifications for each prayer time. Play Azan sound when notification fires. Allow per-prayer notification toggle.

### Implementation

```dart
// Package: flutter_local_notifications
class AzanNotificationService {
  Future<void> schedulePrayerNotifications(PrayerTimesModel times);
  Future<void> cancelAllNotifications();
  Future<void> cancelPrayer(String prayerName);
  Future<void> togglePrayer(String prayerName, bool enabled);
}
```

### Notification Strategy
- Schedule all 5 prayers as local notifications each day
- Re-schedule daily at midnight or after app open
- Use full-screen notification for Azan (Android)
- Azan audio: bundled local MP3 file at `assets/audio/azan.mp3`

### Required Permissions
```
android.permission.SCHEDULE_EXACT_ALARM
android.permission.POST_NOTIFICATIONS (Android 13+)
android.permission.USE_EXACT_ALARM
```

---

## Phase 8 — Testing

### 8.1 Unit Tests

**Location:** `test/unit/`

| Test File | What to Test |
|-----------|--------------|
| `prayer_times_service_test.dart` | API response parsing, time formatting, Hijri date conversion |
| `qibla_service_test.dart` | Direction calculation, distance formula (Haversine) |
| `adhkar_service_test.dart` | JSON parsing, category filtering |
| `tasbih_notifier_test.dart` | Count increment, round completion logic, reset |
| `audio_player_service_test.dart` | Play/pause state transitions |

**Example:**
```dart
// test/unit/prayer_times_service_test.dart
void main() {
  group('PrayerTimesService', () {
    test('parses AlAdhan response correctly', () {
      final json = mockAlAdhanResponse;
      final model = PrayerTimesModel.fromJson(json);
      expect(model.fajr, '04:12');
      expect(model.hijriDate.monthAr, 'ذُو الحِجَّة');
    });

    test('returns correct next prayer given current time', () {
      // mock current time = 14:00
      // expect nextPrayer = Asr
    });
  });
}
```

### 8.2 Widget Tests

**Location:** `test/widget/`

| Test File | What to Test |
|-----------|--------------|
| `prayer_card_widget_test.dart` | Renders prayer names, times, highlights active prayer |
| `quran_surah_list_test.dart` | Renders 114 surahs, search filters correctly |
| `dhikr_counter_widget_test.dart` | Tap increments counter, shows correct progress |
| `compass_widget_test.dart` | Renders compass, rotates correctly with given angle |
| `tasbih_button_test.dart` | Tap triggers count, vibration called |

**Example:**
```dart
// test/widget/prayer_card_widget_test.dart
void main() {
  testWidgets('PrayerCard shows correct times', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prayerTimesProvider.overrideWith((_) => mockPrayerTimes)],
        child: const MaterialApp(home: PrayerCard()),
      ),
    );
    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('04:12'), findsOneWidget);
  });
}
```

### 8.3 Integration Tests

**Location:** `integration_test/`

| Test File | Flow |
|-----------|------|
| `prayer_times_flow_test.dart` | Open app → grant location → see prayer times |
| `quran_reading_flow_test.dart` | Open Quran → select surah → read ayahs → play audio |
| `adhkar_flow_test.dart` | Open Adhkar → select category → complete all dhikr |
| `qibla_flow_test.dart` | Open Qibla → see compass → direction shown |
| `tasbih_flow_test.dart` | Open Tasbih → tap 33 times → round completes → new round |

**Example:**
```dart
// integration_test/prayer_times_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full prayer times flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to prayer times tab
    await tester.tap(find.text('الصلاة'));
    await tester.pumpAndSettle();

    // Verify prayer times screen loads
    expect(find.text('مواقيت الصلاة'), findsOneWidget);
    expect(find.text('الفجر'), findsOneWidget);
  });
}
```

### 8.4 Golden Tests

**Location:** `test/golden/`

| Test File | Screenshot |
|-----------|-----------|
| `home_screen_golden_test.dart` | Home screen with prayer card |
| `quran_list_golden_test.dart` | Surah list |
| `adhkar_screen_golden_test.dart` | Category grid |
| `qibla_screen_golden_test.dart` | Compass pointing SE |
| `tasbih_screen_golden_test.dart` | Counter at 23/33 |
| `dark_mode_golden_test.dart` | Home screen in dark mode |

**Example:**
```dart
// test/golden/home_screen_golden_test.dart
void main() {
  testWidgets('HomeScreen golden test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prayerTimesProvider.overrideWith((_) => mockPrayerTimes)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_screen.png'),
    );
  });
}
```

---

## Phase 9 — Polish & Release Prep

### App Icon & Splash Screen
- App icon: golden Arabesque geometric design on deep green
- Splash screen: app name "تجلي" with subtle fade-in animation
- Package: `flutter_launcher_icons` + `flutter_native_splash`

### Performance
- Lazy load Quran ayahs (don't load all 6236 ayahs at once)
- Cache all API responses in Hive with TTL
- Compress audio: use 64kbps mp3 for bundled Azan
- App size target: under 50MB

### Accessibility
- Minimum tap target size: 48x48px (all buttons)
- Semantic labels on all icons
- Support system font size scaling

### Google Play Release Checklist
- [ ] `keytool` — generate release keystore
- [ ] `flutter build appbundle --release` — build AAB
- [ ] Privacy Policy URL (required for Play Store)
- [ ] App screenshots: 6 screenshots per screen size
- [ ] Feature graphic: 1024x500px
- [ ] App description in Arabic (short + full)
- [ ] Content rating questionnaire
- [ ] Target API level: 34 (Android 14)
- [ ] Permissions justification for: Location, Notifications

### Required Files for Release
```
android/
├── key.jks                          ← keystore (DO NOT commit to git)
├── key.properties                   ← keystore config (DO NOT commit)
└── app/build.gradle                 ← signing config
```

---

## API Summary

| Feature | API | Endpoint | Offline Fallback |
|---------|-----|----------|-----------------|
| Prayer Times | AlAdhan | `/v1/timings/{date}` | Hive cache |
| Next Prayer | AlAdhan | `/v1/nextPrayer/{date}` | Calculated locally |
| Hijri Date | AlAdhan | `/v1/gToH/{date}` | Hive cache |
| Qibla Direction | AlAdhan | `/v1/qibla/{lat}/{lon}` | Hive cache |
| Quran Surah List | AlQuran Cloud | `/v1/surah` | Hive cache |
| Quran Text | AlQuran Cloud | `/v1/surah/{n}/quran-uthmani` | Hive cache |
| Quran Audio | AlQuran Cloud CDN | `cdn.islamic.network/quran/audio/...` | — |
| Adhkar | Local JSON | `assets/data/azkar.json` | Always offline |
| Tasbih | Local only | — | Always offline |
