import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../../../core/utils/helpers.dart';

// Soft rose used for non-active prayer indicators
const _indicatorRose = Color(0xFFF5C6B8);

class PrayerTimeRow extends StatelessWidget {
  const PrayerTimeRow({
    super.key,
    required this.nameAr,
    required this.time,
    this.isHighlighted = false,
    this.subLabel,
    this.isImsak = false,
  });

  final String nameAr;
  final String time;
  final bool isHighlighted;

  /// Extra label below the prayer name, e.g. "الآن"
  final String? subLabel;

  /// Imsak is shown in a smaller, muted style — not highlightable.
  final bool isImsak;

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighlighted
        ? AppColors.gold.withValues(alpha: 0.12)
        : isImsak
            ? AppColors.backgroundParchment
            : AppColors.surfaceIvory;
    final borderColor = isHighlighted
        ? AppColors.gold
        : isImsak
            ? AppColors.surfaceCard.withValues(alpha: 0.5)
            : AppColors.surfaceCard;
    final indicatorColor = isHighlighted
        ? AppColors.primaryGreen
        : isImsak
            ? const Color(0xFFD9C9B8)
            : _indicatorRose;
    final nameColor = isImsak ? AppColors.textMuted : AppColors.textDark;
    final timeColor = isHighlighted ? AppColors.goldText : AppColors.textMedium;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: isImsak ? 2 : 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isHighlighted ? 1.5 : 1),
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 14, vertical: isImsak ? 8 : 12),
        child: Row(
          children: [
            // Indicator square
            Container(
              width: isImsak ? 18 : 18,
              height: isImsak ? 18 : 18,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Prayer name + optional sub-label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameAr,
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: isImsak ? 14 : 16,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.normal,
                    color: nameColor,
                  ),
                ),
                if (subLabel != null)
                  Text(
                    subLabel!,
                    style: const TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 11,
                      color: AppColors.goldText,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Time
            Text(
              TimeFormatter.toIndicDigits(time),
              style: TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: isImsak ? 13 : 15,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: timeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
