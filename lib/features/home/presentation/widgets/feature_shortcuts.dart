import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';

class _FeatureItem {
  const _FeatureItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Widget icon;
  final VoidCallback onTap;
}

class FeatureShortcuts extends StatelessWidget {
  const FeatureShortcuts({
    super.key,
    required this.onQuranTap,
    required this.onAdhkarTap,
    required this.onQiblaTap,
    required this.onTasbihTap,
  });

  final VoidCallback onQuranTap;
  final VoidCallback onAdhkarTap;
  final VoidCallback onQiblaTap;
  final VoidCallback onTasbihTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureItem(
        label: 'الأذكار',
        icon: SvgPicture.asset('assets/svg/icon_adhkar.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
                AppColors.primaryGreen, BlendMode.srcIn)),
        onTap: onAdhkarTap,
      ),
      _FeatureItem(
        label: 'القرآن الكريم',
        icon: SvgPicture.asset('assets/svg/icon_quran.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
                AppColors.primaryGreen, BlendMode.srcIn)),
        onTap: onQuranTap,
      ),
      _FeatureItem(
        label: 'التسبيح',
        icon: SvgPicture.asset('assets/svg/icon_tasbih.svg',
            width: 28,
            height: 28,
            colorFilter: const ColorFilter.mode(
                AppColors.primaryGreen, BlendMode.srcIn)),
        onTap: onTasbihTap,
      ),
      _FeatureItem(
        label: 'القبلة',
        icon: SvgPicture.asset('assets/svg/icon_qibla.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
                AppColors.primaryGreen, BlendMode.srcIn)),
        onTap: onQiblaTap,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.8,
        children: items.map((item) => _FeatureCard(item: item)).toList(),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});
  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceIvory,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceCard, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              item.icon,
              const SizedBox(height: 8),
              Text(
                item.label,
                style: const TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
