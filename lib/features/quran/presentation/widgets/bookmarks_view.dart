import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../data/models/ayah_bookmark.dart';
import '../../providers/quran_providers.dart';
import '../../providers/reader_providers.dart';
import '../quran_reader_screen.dart';
import 'surah_card.dart';

class BookmarksView extends ConsumerWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);
    final ayahBookmarks = ref.watch(ayahBookmarksProvider);

    return surahsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (allSurahs) {
        final bookmarkedSurahs = ref.watch(bookmarkedSurahsProvider);
        final hasAnything =
            bookmarkedSurahs.isNotEmpty || ayahBookmarks.isNotEmpty;

        if (!hasAnything) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border,
                    color: AppColors.goldDark, size: 56),
                SizedBox(height: 16),
                Text(
                  'لا توجد مفضلة بعد',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 18,
                    color: AppColors.primaryGreenDark,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 8),
                Text(
                  'احفظ سورة أو آية لتجدها هنا',
                  style: TextStyle(
                    fontFamily: AppFonts.amiri,
                    fontSize: 13,
                    color: AppColors.navInactive,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          );
        }

        return ListView(
          children: [
            if (bookmarkedSurahs.isNotEmpty) ...[
              _SectionHeader(label: 'السور المحفوظة'),
              ...bookmarkedSurahs.map((s) => SurahCard(surah: s)),
            ],
            if (ayahBookmarks.isNotEmpty) ...[
              _SectionHeader(label: 'الآيات المحفوظة'),
              ...ayahBookmarks.map((b) => _AyahBookmarkTile(
                    bookmark: b,
                    allSurahs: allSurahs,
                    onTap: () {
                      final surah = allSurahs.firstWhere(
                        (s) => s.number == b.surahNumber,
                        orElse: () => allSurahs.first,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuranReaderScreen(
                            surah: surah,
                            initialAyahIndex: b.ayahNumberInSurah - 1,
                          ),
                        ),
                      );
                    },
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 14,
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AyahBookmarkTile extends StatelessWidget {
  const _AyahBookmarkTile({
    required this.bookmark,
    required this.allSurahs,
    required this.onTap,
  });

  final AyahBookmark bookmark;
  final List<dynamic> allSurahs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x22C9A84C), width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.bookmark, color: AppColors.gold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${bookmark.surahName} — آية ${bookmark.ayahNumberInSurah}',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: AppFonts.amiri,
                      fontSize: 12,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bookmark.ayahText,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.amiriQuran,
                      fontSize: 16,
                      color: AppColors.textOnDark,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_left, color: AppColors.navInactive, size: 18),
          ],
        ),
      ),
    );
  }
}
