import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../data/models/surah_model.dart';

class SurahStubScreen extends StatelessWidget {
  const SurahStubScreen({super.key, required this.surah});
  final SurahModel surah;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreenDark,
        iconTheme: const IconThemeData(color: AppColors.gold),
        title: Text(
          surah.name,
          style: AppTextStyles.heading2.copyWith(color: AppColors.gold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded,
                color: AppColors.gold, size: 64),
            const SizedBox(height: 24),
            Text(
              surah.name,
              style: AppTextStyles.heading1.copyWith(color: AppColors.gold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              surah.englishName,
              style: AppTextStyles.body.copyWith(color: AppColors.textOnDark),
            ),
            const SizedBox(height: 24),
            Text(
              'قريباً — الإصدار القادم',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.goldLight),
            ),
          ],
        ),
      ),
    );
  }
}
