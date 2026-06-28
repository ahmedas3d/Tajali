import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';

class _AdhkarCategory {
  const _AdhkarCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const _categories = [
  _AdhkarCategory(
    title: 'أذكار الصباح',
    subtitle: 'ابدأ يومك بذكر الله',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFFF59E0B),
  ),
  _AdhkarCategory(
    title: 'أذكار المساء',
    subtitle: 'أختم يومك بذكر الله',
    icon: Icons.nights_stay_outlined,
    color: Color(0xFF6366F1),
  ),
  _AdhkarCategory(
    title: 'بعد الصلاة',
    subtitle: 'أذكار تعقيب الصلوات',
    icon: Icons.mosque_outlined,
    color: Color(0xFF10B981),
  ),
  _AdhkarCategory(
    title: 'أذكار النوم',
    subtitle: 'سُنّة قبل النوم',
    icon: Icons.bedtime_outlined,
    color: Color(0xFF8B5CF6),
  ),
];


class HomeAdhkarSection extends StatelessWidget {
  const HomeAdhkarSection({super.key, required this.onCategoryTap});

  final VoidCallback onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'الأذكار',
                style: TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCategoryTap,
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Category grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: _categories
                .map((c) => _CategoryCard(category: c, onTap: onCategoryTap))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});
  final _AdhkarCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: category.color.withValues(alpha: 0.25),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, size: 18, color: category.color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    category.subtitle,
                    style: const TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
