import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';

class SettingsWelcomeCard extends StatelessWidget {
  const SettingsWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
      ),
      child: Row(
        children: [
          const Icon(Icons.nightlight_round, color: AppColors.gold, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أهلاً وسهلاً',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'خصّص تجربتك مع تجلّي',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 14,
                    color: AppColors.textOnDark.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
