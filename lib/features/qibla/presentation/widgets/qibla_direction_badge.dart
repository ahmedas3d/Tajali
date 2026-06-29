import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../data/services/qibla_service.dart';

class QiblaDirectionBadge extends StatelessWidget {
  const QiblaDirectionBadge({super.key, required this.degrees});

  final double degrees;

  @override
  Widget build(BuildContext context) {
    final cardinal = cardinalFromDegrees(degrees);
    final degStr = TimeFormatter.toIndicDigits(degrees.round().toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        '$cardinal °$degStr',
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
          letterSpacing: 1,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
