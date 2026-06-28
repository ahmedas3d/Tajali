import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/surah_model.dart';
import '../../providers/quran_providers.dart';
import '../quran_reader_screen.dart';

class SurahCard extends ConsumerWidget {
  const SurahCard({super.key, required this.surah});
  final SurahModel surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarksProvider).contains(surah.number);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x22C9A84C), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            _NumberCircle(number: surah.number),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        surah.name,
                        style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primaryGreenDark, fontSize: 16),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        '${surah.numberOfAyahs} آية',
                        style: const TextStyle(
                          fontFamily: AppFonts.amiri,
                          fontSize: 11,
                          color: AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RevelationBadge(type: surah.revelationType),
                      Text(
                        surah.englishName,
                        style: const TextStyle(
                          fontFamily: AppFonts.amiri,
                          fontSize: 11,
                          color: AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  ref.read(bookmarksProvider.notifier).toggle(surah.number),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked
                      ? AppColors.gold
                      : AppColors.primaryGreenDark,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberCircle extends StatelessWidget {
  const _NumberCircle({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreenDark, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 14,
          color: AppColors.primaryGreenDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RevelationBadge extends StatelessWidget {
  const _RevelationBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final label = type == 'Meccan' ? 'مكية' : 'مدنية';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGreenDark, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 10,
          color: AppColors.primaryGreenDark,
        ),
      ),
    );
  }
}
