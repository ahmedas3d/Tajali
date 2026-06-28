import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../providers/quran_providers.dart';
import '../quran_reader_screen.dart';

class LastReadBanner extends ConsumerWidget {
  const LastReadBanner({super.key});

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

  static String _toArabic(int n) =>
      n.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadAsync = ref.watch(lastReadProvider);
    final surahsAsync = ref.watch(surahListProvider);

    return lastReadAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (position) {
        if (position == null) return const SizedBox.shrink();

        final surah = surahsAsync.valueOrNull?.firstWhere(
          (s) => s.number == position.surahNumber,
          orElse: () => surahsAsync.valueOrNull!.first,
        );
        if (surah == null) return const SizedBox.shrink();

        final surahLabel = 'سورة ${surah.name}';
        final ayahLabel = 'الآية ${_toArabic(position.ayahNumber)}';

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

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: InkWell(
            onTap: openReader,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Continue button
                    _ContinueButton(onTap: openReader),
                    const Spacer(),
                    // Last-read info (RTL: label on top, surah+ayah below)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'آخر قراءة',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: AppFonts.amiri,
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          surahLabel,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: AppFonts.amiri,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    );
  }
}
