import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../providers/prayer_times_providers.dart';

class NextPrayerHero extends ConsumerWidget {
  const NextPrayerHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextAsync = ref.watch(nextPrayerProvider);

    return nextAsync.when(
      loading: () => const _HeroSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (next) => _HeroContent(next: next),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.next});
  final NextPrayerModel next;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}' : '${m.toString()} د';
  }

  @override
  Widget build(BuildContext context) {
    final isElapsed = next.elapsed != null;
    final label = isElapsed
        ? 'مضى على الأذان ${_formatDuration(next.elapsed!)}'
        : 'بعد ${_formatDuration(next.remaining)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(next.nameAr,
              style: AppTextStyles.heading2.copyWith(color: AppColors.gold)),
          const SizedBox(height: 4),
          Text(next.scheduledTime,
              style: AppTextStyles.heading3
                  .copyWith(color: AppColors.textOnDark)),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.goldLight)),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: AppColors.primaryGreen,
    );
  }
}
