import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tajali/app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).valueOrNull == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('تَجَلِّي',
            style: AppTextStyles.heading1.copyWith(color: AppColors.gold)),
        actions: [
          IconButton(
            icon:
                Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round),
            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
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
