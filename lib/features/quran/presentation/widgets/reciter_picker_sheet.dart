import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../data/models/reciter_model.dart';

class ReciterPickerSheet extends StatelessWidget {
  const ReciterPickerSheet({
    super.key,
    required this.currentReciterId,
    required this.onSelected,
  });

  final String currentReciterId;
  final void Function(String identifier) onSelected;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اختر القارئ',
            style: TextStyle(
              fontFamily: AppFonts.amiri,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 8),
          ...ReciterModel.reciters.map((reciter) {
            final isSelected = reciter.identifier == currentReciterId;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.gold : AppColors.navInactive,
              ),
              title: Text(
                reciter.nameAr,
                style: TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 16,
                  color: isSelected ? AppColors.gold : AppColors.textOnDark,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                reciter.nameEn,
                style: const TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 12,
                  color: AppColors.navInactive,
                ),
              ),
              onTap: () => onSelected(reciter.identifier),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}
