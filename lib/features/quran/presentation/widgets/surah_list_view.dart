import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../providers/quran_providers.dart';
import 'surah_card.dart';
import 'surah_skeleton_card.dart';

class SurahListView extends ConsumerWidget {
  const SurahListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);
    final query = ref.watch(quranSearchProvider);

    return surahsAsync.when(
      loading: () => ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) => const SurahSkeletonCard(),
      ),
      error: (_, __) => _ErrorState(
        onRetry: () => ref.invalidate(surahListProvider),
      ),
      data: (_) {
        final surahs = ref.watch(filteredSurahsProvider);
        if (surahs.isEmpty && query.isNotEmpty) {
          return _EmptySearchState(query: query);
        }
        return ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (_, i) => SurahCard(surah: surahs[i]),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.goldDark, size: 48),
          const SizedBox(height: 16),
          Text(
            'تعذّر تحميل السور',
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.textOnDark),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.primaryGreenDark,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'لا توجد نتائج لـ «$query»',
        style: AppTextStyles.body.copyWith(color: AppColors.textOnDark),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
