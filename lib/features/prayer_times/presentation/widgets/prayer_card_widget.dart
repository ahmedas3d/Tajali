import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../providers/prayer_times_providers.dart';

/// Home screen card — shows next prayer name, time, and countdown.
/// Zero-parameter: wires directly to [nextPrayerProvider].
class PrayerCardWidget extends ConsumerWidget {
  const PrayerCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextAsync = ref.watch(nextPrayerProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primaryGreen,
      elevation: 4,
      shadowColor: AppColors.cardShadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: nextAsync.when(
          loading: () => const _CardSkeleton(),
          error: (_, __) => const _CardError(),
          data: (next) => _CardContent(next: next),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.next});
  final NextPrayerModel next;

  @override
  Widget build(BuildContext context) {
    final h = next.remaining.inHours;
    final m = next.remaining.inMinutes.remainder(60);
    final countdown =
        h > 0 ? 'بعد $h:${m.toString().padLeft(2, '0')}' : 'بعد $m د';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(next.nameAr,
                style: AppTextStyles.heading3.copyWith(color: AppColors.gold)),
            const SizedBox(height: 2),
            Text(next.scheduledTime,
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textOnDark)),
          ],
        ),
        Text(countdown,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldLight)),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(height: 48, color: AppColors.primaryGreenDark);
  }
}

class _CardError extends StatelessWidget {
  const _CardError();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('—', style: AppTextStyles.heading3),
        Text('—', style: AppTextStyles.bodySmall),
      ],
    );
  }
}
