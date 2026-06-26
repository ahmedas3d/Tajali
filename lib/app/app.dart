import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'theme/app_fonts.dart';
import '../core/providers/theme_provider.dart';
import '../features/splash/presentation/splash_screen.dart';

class TajaliApp extends ConsumerWidget {
  const TajaliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider).valueOrNull ?? ThemeMode.light;

    return MaterialApp(
      title: 'تَجَلِّي',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Guarantees Amiri for any text that bypasses the theme (e.g. overlays).
      builder: (context, child) => DefaultTextStyle(
        style: const TextStyle(fontFamily: AppFonts.amiri),
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
