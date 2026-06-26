import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../providers/quran_providers.dart';
import 'surah_card.dart';

class BookmarksView extends ConsumerWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);

    return surahsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (_) {
        final bookmarked = ref.watch(bookmarkedSurahsProvider);
        if (bookmarked.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_border,
                    color: AppColors.goldDark, size: 56),
                const SizedBox(height: 16),
                Text(
                  'لا توجد سور محفوظة بعد',
                  style: AppTextStyles.heading3
                      .copyWith(color: AppColors.primaryGreenDark),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Text(
                  'احفظ سورة لتجدها هنا',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.navInactive),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: bookmarked.length,
          itemBuilder: (_, i) => SurahCard(surah: bookmarked[i]),
        );
      },
    );
  }
}
