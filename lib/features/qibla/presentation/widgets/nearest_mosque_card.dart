import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/mosque_model.dart';

class NearestMosqueCard extends StatelessWidget {
  const NearestMosqueCard({super.key, required this.mosque});

  final MosqueModel mosque;

  Future<void> _openMaps() async {
    final geo = Uri.parse(mosque.mapsUrl);
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo);
    } else {
      final web = Uri.parse(mosque.fallbackMapsUrl);
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openMaps,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryGreenDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.mosque_rounded, color: AppColors.gold, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.nameAr,
                    style: AppTextStyles.onDarkBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(mosque.formattedDistance, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: AppColors.gold, size: 18),
          ],
        ),
      ),
    );
  }
}
