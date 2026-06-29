import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';

class QiblaStatsRow extends StatelessWidget {
  const QiblaStatsRow({
    super.key,
    required this.distanceKm,
    required this.cityName,
  });

  final double distanceKm;
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final distStr = TimeFormatter.toIndicDigits(distanceKm.toStringAsFixed(0));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'المدينة', value: cityName),
          _Divider(),
          _Stat(label: 'المسافة', value: '$distStr كم'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.onDarkBold),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36, color: AppColors.gold.withValues(alpha: 0.35));
  }
}
