import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../../quran/presentation/quran_reader_screen.dart';
import '../../../quran/providers/quran_providers.dart';

class HomeQuranSection extends ConsumerWidget {
  const HomeQuranSection({super.key, required this.onBrowseTap});

  final VoidCallback onBrowseTap;

  static const _arabicDigits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩'
  ];
  static String _toAr(int n) =>
      n.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadAsync = ref.watch(lastReadProvider);
    final surahsAsync = ref.watch(surahListProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text(
                'القرآن الكريم',
                style: TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onBrowseTap,
                child: const Text(
                  'تصفّح',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          lastReadAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => _StartPrompt(onTap: onBrowseTap),
            data: (position) {
              if (position == null) return _StartPrompt(onTap: onBrowseTap);

              final surah = surahsAsync.valueOrNull?.firstWhere(
                (s) => s.number == position.surahNumber,
                orElse: () => surahsAsync.valueOrNull!.first,
              );
              if (surah == null) return _StartPrompt(onTap: onBrowseTap);

              void openReader() {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => QuranReaderScreen(
                        surah: surah,
                        initialScrollOffset: position.scrollOffset,
                        initialAyahIndex: position.ayahNumber - 1,
                      ),
                    ))
                    .then((_) => ref.invalidate(lastReadProvider));
              }

              return _LastReadCard(
                surahName: surah.name,
                ayahNumber: _toAr(position.ayahNumber),
                onTap: openReader,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LastReadCard extends StatelessWidget {
  const _LastReadCard({
    required this.surahName,
    required this.ayahNumber,
    required this.onTap,
  });

  final String surahName;
  final String ayahNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Continue button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'متابعة',
                style: TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 13,
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'آخر قراءة',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  surahName,
                  style: const TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StartPrompt extends StatelessWidget {
  const _StartPrompt({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ابدأ الآن',
                style: TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 13,
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'ابدأ رحلتك مع القرآن الكريم',
              style: TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
