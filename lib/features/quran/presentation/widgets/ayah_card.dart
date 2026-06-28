import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../data/models/ayah_model.dart';
import '../../providers/reader_providers.dart';

class AyahCard extends ConsumerWidget {
  const AyahCard({
    super.key,
    required this.ayah,
    required this.isPlaying,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  final AyahModel ayah;
  final bool isPlaying;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isPlaying
            ? AppColors.gold.withValues(alpha: 0.14)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${ayah.text} ',
                style: TextStyle(
                  fontFamily: AppFonts.amiriQuran,
                  fontSize: fontSize,
                  color: isPlaying ? AppColors.goldText : AppColors.mushafText,
                  height: 2.2,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _AyahMarker(
                  number: ayah.numberInSurah,
                  isPlaying: isPlaying,
                  isBookmarked: isBookmarked,
                  onTap: onBookmarkToggle,
                ),
              ),
            ],
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AyahMarker extends StatelessWidget {
  const _AyahMarker({
    required this.number,
    required this.isPlaying,
    required this.isBookmarked,
    required this.onTap,
  });

  final int number;
  final bool isPlaying;
  final bool isBookmarked;
  final VoidCallback onTap;

  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  String _toArabic(int n) =>
      n.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();

  @override
  Widget build(BuildContext context) {
    final ringColor = isPlaying ? AppColors.goldText : AppColors.goldDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: isPlaying ? 1.5 : 1.0),
          color: isBookmarked
              ? AppColors.gold.withValues(alpha: 0.3)
              : isPlaying
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          _toArabic(number),
          style: TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 8,
            color: ringColor,
          ),
        ),
      ),
    );
  }
}
