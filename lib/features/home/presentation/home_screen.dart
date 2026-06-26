import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../prayer_times/providers/prayer_times_providers.dart';
import '../../settings/presentation/settings_screen.dart';
import 'widgets/daily_verse_widget.dart';
import 'widgets/feature_shortcuts.dart';
import 'widgets/prayer_hero_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activates adhan notification scheduling whenever prayer times load/change.
    ref.watch(adhanSchedulerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'تَجَلِّي',
          style: TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.settings_outlined, color: AppColors.goldLight),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PrayerHeroCard(),
            const SizedBox(height: 20),
            FeatureShortcuts(
              onQuranTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 1,
              onAdhkarTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 2,
              onQiblaTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 3,
              onTasbihTap: () =>
                  ref.read(selectedTabProvider.notifier).state = 2,
            ),
            const SizedBox(height: 20),
            const DailyVerseWidget(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
