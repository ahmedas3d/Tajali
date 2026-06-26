# Flutter Project Spec — تطبيق "تَجَلِّي" الإسلامي


## Phase 1 — Project Structure & Folder Setup

Create the following folder structure inside `lib/`:

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_fonts.dart
│       └── app_text_styles.dart
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── utils/
│   │   └── helpers.dart
│   ├── widgets/
│   │   ├── islamic_card.dart
│   │   ├── gold_divider.dart
│   │   └── arabesque_header.dart
│   └── services/
│       └── location_service.dart
│
├── features/
│   ├── home/
│   │   └── presentation/
│   │       └── home_screen.dart
│   ├── prayer_times/
│   │   └── presentation/
│   │       └── prayer_times_screen.dart
│   ├── quran/
│   │   └── presentation/
│   │       └── quran_screen.dart
│   ├── adhkar/
│   │   └── presentation/
│   │       └── adhkar_screen.dart
│   └── qibla/
│       └── presentation/
│           ├── qibla_screen.dart
│           └── tasbih_screen.dart
│
└── shared/
    └── local_storage/
        └── storage_service.dart
```

### pubspec.yaml — Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1

  # Fonts
  google_fonts: ^6.2.1

  # Local Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.3

  # Location & Compass
  geolocator: ^11.0.0
  flutter_compass: ^0.7.0
  permission_handler: ^11.3.1

  # Prayer Times
  adhan: ^1.1.0

  # Audio
  just_audio: ^0.9.38

  # Notifications
  flutter_local_notifications: ^17.2.2

  # UI Extras
  flutter_svg: ^2.0.10+1
  vibration: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

### pubspec.yaml — Assets & Fonts

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/svg/
    - assets/audio/
    - assets/data/

  fonts:
    - family: Amiri
      fonts:
        - asset: assets/fonts/Amiri-Regular.ttf
        - asset: assets/fonts/Amiri-Bold.ttf
          weight: 700
    - family: AmiriQuran
      fonts:
        - asset: assets/fonts/AmiriQuran.ttf
```

---

## Phase 2 — Theme System

### File: `lib/app/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primaryGreen     = Color(0xFF1B4332);
  static const Color primaryGreenDark = Color(0xFF0D2218);
  static const Color gold             = Color(0xFFC9A84C);
  static const Color goldLight        = Color(0xFFE8C97A);
  static const Color goldDark         = Color(0xFF9A7A2E);

  // Background & Surface
  static const Color backgroundParchment = Color(0xFFF5E6C8);
  static const Color surfaceIvory        = Color(0xFFFAF0DC);
  static const Color surfaceCard         = Color(0xFFF0E0BE);

  // Text
  static const Color textDark    = Color(0xFF3D1F00);
  static const Color textMedium  = Color(0xFF6B3A1F);
  static const Color textMuted   = Color(0xFF9C7A5A);
  static const Color textOnDark  = Color(0xFFFAF0DC);

  // Dark Mode
  static const Color darkBackground = Color(0xFF1A1209);
  static const Color darkSurface    = Color(0xFF2A1F0E);
  static const Color darkCard       = Color(0xFF332810);

  // Status Colors
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFC9A84C);
  static const Color error   = Color(0xFF8B0000);

  // Navigation
  static const Color navBackground = Color(0xFF0A1A10);
  static const Color navActive     = Color(0xFFC9A84C);
  static const Color navInactive   = Color(0x80FAF0DC);
}
```

### File: `lib/app/theme/app_fonts.dart`

```dart
class AppFonts {
  AppFonts._();

  static const String amiri     = 'Amiri';
  static const String amiriQuran = 'AmiriQuran';
}
```

### File: `lib/app/theme/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.gold,
    height: 1.4,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.4,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 16,
    color: AppColors.textDark,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 13,
    color: AppColors.textMedium,
    height: 1.5,
  );

  // Quran Text
  static const TextStyle quranText = TextStyle(
    fontFamily: AppFonts.amiriQuran,
    fontSize: 24,
    color: AppColors.textDark,
    height: 2.0,
  );

  // Gold Label
  static const TextStyle goldLabel = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.gold,
    letterSpacing: 0.5,
  );

  // On Dark Background
  static const TextStyle onDark = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 16,
    color: AppColors.textOnDark,
    height: 1.6,
  );

  static const TextStyle onDarkBold = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnDark,
  );
}
```

### File: `lib/app/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppFonts.amiri,

    colorScheme: const ColorScheme.light(
      primary:   AppColors.primaryGreen,
      secondary: AppColors.gold,
      surface:   AppColors.surfaceIvory,
      error:     AppColors.error,
      onPrimary: AppColors.textOnDark,
      onSecondary: AppColors.textDark,
      onSurface: AppColors.textDark,
    ),

    scaffoldBackgroundColor: AppColors.backgroundParchment,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.textOnDark,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: AppTextStyles.onDarkBold,
      iconTheme: IconThemeData(color: AppColors.gold),
    ),

    cardTheme: CardTheme(
      color: AppColors.surfaceIvory,
      elevation: 2,
      shadowColor: AppColors.gold.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.gold, width: 1),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.gold,
      thickness: 0.8,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navBackground,
      selectedItemColor: AppColors.navActive,
      unselectedItemColor: AppColors.navInactive,
      selectedLabelStyle: TextStyle(
        fontFamily: AppFonts.amiri,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppFonts.amiri,
        fontSize: 11,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    textTheme: const TextTheme(
      displayLarge:  AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      displaySmall:  AppTextStyles.heading3,
      bodyLarge:     AppTextStyles.body,
      bodySmall:     AppTextStyles.bodySmall,
      labelLarge:    AppTextStyles.goldLabel,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppFonts.amiri,

    colorScheme: const ColorScheme.dark(
      primary:   AppColors.gold,
      secondary: AppColors.primaryGreen,
      surface:   AppColors.darkSurface,
      error:     AppColors.error,
      onPrimary: AppColors.darkBackground,
      onSecondary: AppColors.textOnDark,
      onSurface: AppColors.textOnDark,
    ),

    scaffoldBackgroundColor: AppColors.darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.textOnDark,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.amiri,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
      ),
      iconTheme: IconThemeData(color: AppColors.gold),
    ),

    cardTheme: CardTheme(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: AppColors.gold.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.goldDark, width: 1),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0A0A05),
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.navInactive,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
```

---

## Phase 3 — App Entry Point & Navigation

### File: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: NoorApp()));
}
```

### File: `lib/app/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'routes.dart';

class NoorApp extends ConsumerWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'تَجَلِّي',
      debugShowCheckedModeBanner: false,

      // RTL Arabic layout
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Navigation
      home: const MainNavigation(),
    );
  }
}
```

### File: `lib/app/routes.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/quran/presentation/quran_screen.dart';
import '../features/adhkar/presentation/adhkar_screen.dart';
import '../features/qibla/presentation/qibla_screen.dart';
import '../features/prayer_times/presentation/prayer_times_screen.dart';

// Provider to track selected tab index
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    QuranScreen(),
    AdhkarScreen(),
    QiblaScreen(),
    PrayerTimesScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildNavBar(context, ref, selectedIndex),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, WidgetRef ref, int selectedIndex) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => ref.read(selectedTabProvider.notifier).state = index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'القرآن',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement_outlined),
          activeIcon: Icon(Icons.self_improvement),
          label: 'الأذكار',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'القبلة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time_outlined),
          activeIcon: Icon(Icons.access_time),
          label: 'الصلاة',
        ),
      ],
    );
  }
}
```

### Placeholder Screens (one per feature)

Each screen file follows this template. Create one file for each:
`home_screen.dart` / `quran_screen.dart` / `adhkar_screen.dart` / `qibla_screen.dart` / `prayer_times_screen.dart`

```dart
// Example: lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نور'),
      ),
      body: const Center(
        child: Text(
          'الشاشة الرئيسية',
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}

// Repeat for: QuranScreen, AdhkarScreen, QiblaScreen, PrayerTimesScreen
// Change class name and label text accordingly
```

---

## Phase Summary

| Phase | الملفات | الهدف |
|-------|---------|-------|
| Phase 1 | Folder structure + pubspec.yaml | هيكل المشروع والـ packages |
| Phase 2 | app_colors + app_fonts + app_text_styles + app_theme | نظام الثيم الكامل |
| Phase 3 | main.dart + app.dart + routes.dart + 5 placeholder screens | تشغيل التطبيق مع الـ navigation |

**النتيجة بعد الـ 3 phases:**
تطبيق Flutter يعمل، فيه Bottom Navigation بـ 5 تابات، كل tab بيفتح شاشة فارغة، بالثيم التراثي الإسلامي جاهز للبناء عليه.
