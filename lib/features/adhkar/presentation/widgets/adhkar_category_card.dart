import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../data/models/adhkar_category_model.dart';

class AdhkarCategoryCard extends StatelessWidget {
  const AdhkarCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isComplete = false,
  });

  final AdhkarCategoryModel category;
  final VoidCallback onTap;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceIvory,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isComplete
                ? AppColors.primaryGreen.withValues(alpha: 0.5)
                : AppColors.gold.withValues(alpha: 0.25),
            width: isComplete ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isComplete
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(category.id),
                color: isComplete ? Colors.white : AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.nameAr,
                    style: TextStyle(
                      fontFamily: AppFonts.arabic,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isComplete
                          ? AppColors.primaryGreen
                          : AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${category.count} ذكر',
                    style: const TextStyle(
                      fontFamily: AppFonts.arabic,
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing: checkmark or chevron
            if (isComplete)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String id) {
    if (id == 'morning') return Icons.wb_sunny_outlined;
    if (id == 'evening') return Icons.nights_stay_outlined;
    if (id == 'wakeup') return Icons.alarm_outlined;
    if (id == 'sleep') return Icons.bedtime_outlined;

    if (id.contains('prayer') ||
        id.contains('salah') ||
        id.contains('sujood') ||
        id.contains('rukoo') ||
        id.contains('tashahhud') ||
        id.contains('istiftah') ||
        id.contains('qunut') ||
        id.contains('witr') ||
        id.contains('tilawa') ||
        id.contains('qabla_salam') ||
        id.contains('raf_rukoo') ||
        id.contains('jalsa')) {
      return Icons.mosque_outlined;
    }
    if (id == 'athan_adhkar') return Icons.notifications_outlined;
    if (id == 'dua_istikharah') return Icons.help_outline;

    if (id.contains('masjid')) return Icons.mosque_outlined;

    if (id.contains('wudu') || id.contains('khalaa')) {
      return Icons.water_drop_outlined;
    }
    if (id.contains('libs') || id.contains('thawb')) {
      return Icons.checkroom_outlined;
    }

    if (id.contains('manzil')) return Icons.home_outlined;

    if (id.contains('taaam') ||
        id.contains('talab_taaam') ||
        id.contains('dayf') ||
        id.contains('thamar') ||
        id.contains('sawm') ||
        id.contains('iftar') ||
        id.contains('saim')) {
      return Icons.restaurant_outlined;
    }

    if (id.contains('safar') ||
        id.contains('rukub') ||
        id.contains('markub') ||
        id.contains('musafir') ||
        id.contains('muqim') ||
        id.contains('qarya') ||
        id.contains('suq') ||
        id.contains('nuzul') ||
        id.contains('rujuu') ||
        id.contains('sahar')) {
      return Icons.directions_car_outlined;
    }

    if (id.contains('reeh') ||
        id.contains('raad') ||
        id.contains('matar') ||
        id.contains('istisqa') ||
        id.contains('istishhaa')) {
      return Icons.thunderstorm_outlined;
    }

    if (id.contains('hilal')) return Icons.nights_stay_outlined;
    if (id.contains('attas')) return Icons.face_outlined;

    if (id.contains('zawaj')) return Icons.favorite_outline;

    if (id.contains('ghadab') ||
        id.contains('hamm') ||
        id.contains('karb') ||
        id.contains('waswas') ||
        id.contains('amr_saab')) {
      return Icons.psychology_outlined;
    }

    if (id.contains('marid') ||
        id.contains('marad') ||
        id.contains('waja') ||
        id.contains('iyada')) {
      return Icons.local_hospital_outlined;
    }

    if (id.contains('mayyit') ||
        id.contains('qabr') ||
        id.contains('dafn') ||
        id.contains('muhtadar') ||
        id.contains('farat') ||
        id.contains('taziya') ||
        id.contains('ziyara_qubur')) {
      return Icons.brightness_1_outlined;
    }

    if (id.contains('mawlud') || id.contains('awlad')) {
      return Icons.child_care_outlined;
    }

    if (id.contains('ruqya') ||
        id.contains('shaytan') ||
        id.contains('ayn') ||
        id.contains('dajjal') ||
        id.contains('kayd')) {
      return Icons.shield_outlined;
    }

    if (id.contains('talbiyya') ||
        id.contains('arafa') ||
        id.contains('mashar') ||
        id.contains('jamarat') ||
        id.contains('safa') ||
        id.contains('rukn')) {
      return Icons.directions_walk_outlined;
    }

    if (id.contains('majlis') ||
        id.contains('kafarat') ||
        id.contains('salam') ||
        id.contains('madh') ||
        id.contains('barak') ||
        id.contains('maaruf') ||
        id.contains('ghafar') ||
        id.contains('hubb') ||
        id.contains('sabba')) {
      return Icons.groups_outlined;
    }

    if (id == 'tasbih_adhkar' ||
        id == 'istighfar' ||
        id.contains('fadl_salah_nabi') ||
        id.contains('nabi_sabbaha')) {
      return Icons.favorite_border;
    }

    if (id.contains('nawm') ||
        id.contains('layl') ||
        id.contains('ruya') ||
        id.contains('taqallub') ||
        id.contains('tayaar')) {
      return Icons.bedtime_outlined;
    }

    if (id.contains('dik') || id.contains('kalb')) return Icons.pets_outlined;
    if (id.contains('amakan') || id.contains('ijaba')) {
      return Icons.place_outlined;
    }

    return Icons.auto_awesome_outlined;
  }
}
