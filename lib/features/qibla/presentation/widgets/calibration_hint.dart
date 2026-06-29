import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/qibla_model.dart';

class CalibrationHint extends StatelessWidget {
  const CalibrationHint({super.key, required this.accuracy});

  final AccuracyLevel accuracy;

  @override
  Widget build(BuildContext context) {
    if (accuracy == AccuracyLevel.high) return const SizedBox.shrink();

    final message = accuracy == AccuracyLevel.low
        ? 'حرّك هاتفك في شكل رقم ٨ لمعايرة البوصلة'
        : 'أبعد الهاتف عن الأجسام المعدنية لتحسين الدقة';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}
