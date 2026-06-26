import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../prayer_times/providers/prayer_times_providers.dart';

class CalculationMethodTile extends StatelessWidget {
  const CalculationMethodTile({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final CalculationMethodConfig method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isSelected
          ? AppColors.primaryGreen.withValues(alpha: 0.08)
          : null,
      title: Text(
        method.nameAr,
        style: AppTextStyles.body.copyWith(
          color: isSelected ? AppColors.goldText : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.gold)
          : const Icon(Icons.radio_button_unchecked, color: AppColors.textMuted),
    );
  }
}
