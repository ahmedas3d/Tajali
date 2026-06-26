import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../data/models/daily_verse_model.dart';
import '../../providers/daily_verse_provider.dart';

class DailyVerseWidget extends ConsumerWidget {
  const DailyVerseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verseAsync = ref.watch(dailyVerseProvider);

    return verseAsync.when(
      loading: () => const _VerseSkeleton(),
      error: (_, __) => const _VerseFallback(),
      data: (verse) => _VerseCard(verse: verse),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({required this.verse});
  final DailyVerseModel verse;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEEE4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0C8A0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0C8A0), width: 1),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_outlined, size: 16, color: AppColors.goldText),
                SizedBox(width: 6),
                Text(
                  'آية اليوم',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldText,
                  ),
                ),
              ],
            ),
          ),
          // Verse text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              verse.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.amiriQuran,
                fontSize: 18,
                color: AppColors.textDark,
                height: 2.0,
              ),
            ),
          ),
          // Reference
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              verse.ref,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fallback to a local verse on network error
class _VerseFallback extends StatelessWidget {
  const _VerseFallback();

  @override
  Widget build(BuildContext context) {
    return const _VerseCard(
      verse: DailyVerseModel(
        text: 'إِنَّ ٱلصَّلَوٰةَ كَانَتۡ عَلَى ٱلۡمُؤۡمِنِينَ كِتَٰبٗا مَّوۡقُوتٗا',
        surahName: 'سورة النساء',
        ayahNumber: 103,
        surahNumber: 4,
      ),
    );
  }
}

class _VerseSkeleton extends StatelessWidget {
  const _VerseSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFFBEEE4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0C8A0), width: 1),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.goldText,
        ),
      ),
    );
  }
}
