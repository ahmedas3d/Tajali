import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../providers/adhkar_providers.dart';
import 'dhikr_detail_screen.dart';
import 'tasbih_screen.dart';
import 'widgets/adhkar_category_card.dart';

class AdhkarScreen extends ConsumerWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adhkarCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'الأذكار والدعاء',
          style: TextStyle(
            fontFamily: AppFonts.arabic,
            fontSize: 20,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _AyahBanner(),
          // Tasbih banner at the top — before the categories grid
          const _TasbihBanner(),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final isComplete =
                      ref.watch(categoryCompletionProvider(cat.id));
                  return AdhkarCategoryCard(
                    category: cat,
                    isComplete: isComplete,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DhikrDetailScreen(
                          categoryId: cat.id,
                          categoryName: cat.nameAr,
                          initialIndex: 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (e, _) => const Center(
                child: Text('خطأ في تحميل الأذكار'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: const Text(
        'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppFonts.quran,
          fontSize: 18,
          color: AppColors.goldLight,
          height: 2.0,
        ),
      ),
    );
  }
}

class _TasbihBanner extends StatelessWidget {
  const _TasbihBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المسبحة الإلكترونية',
                    style: TextStyle(
                      fontFamily: AppFonts.arabic,
                      fontSize: 16,
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'سبّح واذكر الله في كل وقت',
                    style: TextStyle(
                      fontFamily: AppFonts.arabic,
                      fontSize: 12,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasbihScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.primaryGreenDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text(
                'ابدأ الآن',
                style: TextStyle(
                  fontFamily: AppFonts.arabic,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
