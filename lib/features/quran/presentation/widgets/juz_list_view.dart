import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/juz_data.dart';
import '../../data/models/surah_model.dart';
import '../../providers/quran_providers.dart';
import 'surah_card.dart';
import 'surah_skeleton_card.dart';

class JuzListView extends ConsumerWidget {
  const JuzListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);

    return surahsAsync.when(
      loading: () => ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) => const SurahSkeletonCard(),
      ),
      error: (_, __) => Center(
        child: Text(
          'تعذّر التحميل',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textOnDark),
        ),
      ),
      data: (surahs) {
        final byJuz = <int, List<SurahModel>>{};
        for (final surah in surahs) {
          final juz = surahToJuz[surah.number] ?? 1;
          (byJuz[juz] ??= []).add(surah);
        }

        final slivers = <Widget>[];
        for (var j = 1; j <= 30; j++) {
          final juzSurahs = byJuz[j] ?? [];
          slivers.add(SliverPersistentHeader(
            pinned: true,
            delegate: _JuzHeaderDelegate(juzNumber: j),
          ));
          if (juzSurahs.isEmpty) {
            slivers.add(const SliverToBoxAdapter(
              child: _ContinuationNote(),
            ));
          } else {
            slivers.add(SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => SurahCard(surah: juzSurahs[i]),
                childCount: juzSurahs.length,
              ),
            ));
          }
        }

        return CustomScrollView(slivers: slivers);
      },
    );
  }
}

class _JuzHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _JuzHeaderDelegate({required this.juzNumber});
  final int juzNumber;

  @override
  double get minExtent => 40;

  @override
  double get maxExtent => 40;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.primaryGreen,
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Text(
        'الجزء $juzNumber',
        style: const TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _JuzHeaderDelegate oldDelegate) =>
      juzNumber != oldDelegate.juzNumber;
}

class _ContinuationNote extends StatelessWidget {
  const _ContinuationNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          start: 16, end: 16, top: 8, bottom: 8),
      child: Text(
        'يتضمن هذا الجزء تتمة السور السابقة',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
