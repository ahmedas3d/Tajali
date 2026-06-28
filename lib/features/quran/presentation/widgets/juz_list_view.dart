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

        final items = <Widget>[];
        for (var j = 1; j <= 30; j++) {
          if (j > 1) items.add(const SizedBox(height: 12));
          items.add(_JuzHeader(juzNumber: j));
          final juzSurahs = byJuz[j] ?? [];
          if (juzSurahs.isEmpty) {
            items.add(const _ContinuationNote());
          } else {
            for (final surah in juzSurahs) {
              items.add(SurahCard(surah: surah));
            }
          }
        }
        items.add(const SizedBox(height: 24));

        return ListView(children: items);
      },
    );
  }
}

class _JuzHeader extends StatelessWidget {
  const _JuzHeader({required this.juzNumber});
  final int juzNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppColors.primaryGreen,
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Text(
        'الجزء $juzNumber',
        style: const TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _ContinuationNote extends StatelessWidget {
  const _ContinuationNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          start: 16, end: 16, top: 14, bottom: 14),
      child: Text(
        'يتضمن هذا الجزء تتمة السور السابقة',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
