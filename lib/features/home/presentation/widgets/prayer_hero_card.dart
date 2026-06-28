import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../../../core/utils/helpers.dart';
import '../../../prayer_times/data/models/prayer_times_model.dart';
import '../../../prayer_times/providers/prayer_times_providers.dart';

class PrayerHeroCard extends ConsumerWidget {
  const PrayerHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timesAsync = ref.watch(prayerTimesProvider);
    final nextAsync = ref.watch(nextPrayerProvider);
    final progressAsync = ref.watch(prayerProgressProvider);
    final hijriAsync = ref.watch(hijriDateProvider);
    final qiyamAsync = ref.watch(qiyamTimeProvider);
    final city = ref.watch(manualCityProvider);

    final qiyamStr = qiyamAsync.whenOrNull(
      data: (dt) => dt != null ? TimeFormatter.toArabic12h(dt) : null,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background mosque silhouette
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.08,
                child: SvgPicture.asset(
                  'assets/svg/onboarding_mosque.svg',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: timesAsync.when(
                loading: () => const _CardLoadingState(),
                error: (_, __) => const _CardErrorState(),
                data: (times) => _CardContent(
                  times: times,
                  nextAsync: nextAsync,
                  progressAsync: progressAsync,
                  qiyamTime: qiyamStr,
                  hijriText: hijriAsync.when(
                    data: (h) =>
                        '${TimeFormatter.toIndicDigits(h.day.toString())} ${h.monthAr} ${TimeFormatter.toIndicDigits(h.year.toString())} هـ',
                    loading: () => '',
                    error: (_, __) => '',
                  ),
                  city: city,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card content ──────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.times,
    required this.nextAsync,
    required this.progressAsync,
    required this.hijriText,
    required this.city,
    this.qiyamTime,
  });

  final PrayerTimesModel times;
  final AsyncValue<NextPrayerModel> nextAsync;
  final AsyncValue<double> progressAsync;
  final String hijriText;
  final ManualCityEntry? city;
  final String? qiyamTime;

  @override
  Widget build(BuildContext context) {
    final next = nextAsync.valueOrNull;
    final progress = progressAsync.valueOrNull ?? 0.0;
    final nextKey = next?.name.toLowerCase();

    // Row 1: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
    final row1 = [
      ('الفجر', times.fajr, 'fajr'),
      ('الشروق', times.sunrise, 'sunrise'),
      ('الظهر', times.dhuhr, 'dhuhr'),
      ('العصر', times.asr, 'asr'),
      ('المغرب', times.maghrib, 'maghrib'),
      ('العشاء', times.isha, 'isha'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hijri date header
        if (hijriText.isNotEmpty) ...[
          Text(
            hijriText,
            style: const TextStyle(
              fontFamily: AppFonts.amiri,
              fontSize: 12,
              color: AppColors.navInactive,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          const _GoldDivider(),
          const SizedBox(height: 8),
        ],

        // Label + city
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              next?.elapsed != null ? 'مضى على أذان' : 'الصلاة القادمة',
              style: const TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 13,
                color: AppColors.goldLight,
              ),
            ),
            if (city != null) ...[
              const Text('  •  ',
                  style: TextStyle(fontSize: 10, color: AppColors.navInactive)),
              const Icon(Icons.location_on_outlined,
                  size: 12, color: AppColors.navInactive),
              const SizedBox(width: 2),
              Text(
                city!.nameAr,
                style: const TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 12,
                  color: AppColors.navInactive,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 4),

        // Prayer name
        Text(
          next?.nameAr ?? '—',
          style: const TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
            height: 1.1,
          ),
        ),

        // Countdown or elapsed
        if (next != null) ...[
          const SizedBox(height: 2),
          if (next.elapsed != null)
            _ElapsedDisplay(elapsed: next.elapsed!)
          else
            _CountdownDisplay(remaining: next.remaining),
        ],

        const SizedBox(height: 14),

        // Progress bar
        _ProgressBar(progress: progress),

        const SizedBox(height: 12),

        // Row 1: 6 prayers (Fajr → Isha + Sunrise)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row1.map((p) {
            return _PrayerChip(
              nameAr: p.$1,
              time: p.$2,
              isNext: nextKey == p.$3,
            );
          }).toList(),
        ),

        // Row 2: Qiyam al-Layl (centered, only when available)
        if (qiyamTime != null) ...[
          const SizedBox(height: 8),
          const _GoldDivider(),
          // const SizedBox(height: 8),
          // _PrayerChip(
          //   nameAr: 'قيام الليل',
          //   time: qiyamTime!,
          //   isNext: nextKey == 'qiyam',
          // ),
        ],
      ],
    );
  }
}

// ── Gold divider ──────────────────────────────────────────────────────────────

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 0.5,
          color: AppColors.gold.withValues(alpha: 0.4),
        ),
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 24,
          height: 0.5,
          color: AppColors.gold.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

// ── Countdown ─────────────────────────────────────────────────────────────────

class _CountdownDisplay extends StatelessWidget {
  const _CountdownDisplay({required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);

    final showHours = h > 0;

    // In RTL: last item is on the visual left, so order [SS, :, MM, :, HH]
    // renders visually as HH:MM:SS (or MM:SS when no hours)
    final units = <Widget>[];

    // Seconds (rightmost in RTL = visual rightmost)
    units.add(_TimeUnit(
      value: TimeFormatter.toIndicDigits(s.toString().padLeft(2, '0')),
      label: 'ثانية',
    ));

    units.add(_Colon());

    // Minutes
    units.add(_TimeUnit(
      value: TimeFormatter.toIndicDigits(m.toString().padLeft(2, '0')),
      label: 'دقيقة',
    ));

    if (showHours) {
      units.add(_Colon());
      units.add(_TimeUnit(
        value: TimeFormatter.toIndicDigits(h.toString()),
        label: 'ساعة',
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: units,
    );
  }
}

class _Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: AppFonts.amiri,
          fontSize: 32,
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
          height: 1.15,
        ),
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  const _TimeUnit({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnDark,
            height: 1.0,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 10,
            color: AppColors.goldLight,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ── Elapsed display ───────────────────────────────────────────────────────────

class _ElapsedDisplay extends StatelessWidget {
  const _ElapsedDisplay({required this.elapsed});
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    final s = elapsed.inSeconds.remainder(60);

    final units = <Widget>[];

    units.add(_TimeUnit(
      value: TimeFormatter.toIndicDigits(s.toString().padLeft(2, '0')),
      label: 'ثانية',
    ));
    units.add(_Colon());
    units.add(_TimeUnit(
      value: TimeFormatter.toIndicDigits(m.toString().padLeft(2, '0')),
      label: 'دقيقة',
    ));
    if (h > 0) {
      units.add(_Colon());
      units.add(_TimeUnit(
        value: TimeFormatter.toIndicDigits(h.toString()),
        label: 'ساعة',
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: units,
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final totalWidth = constraints.maxWidth;
        final remaining = (1.0 - progress).clamp(0.0, 1.0);

        return Container(
          height: 4,
          width: totalWidth,
          decoration: BoxDecoration(
            color: AppColors.primaryGreenDark,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: remaining,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Prayer chip ───────────────────────────────────────────────────────────────

class _PrayerChip extends StatelessWidget {
  const _PrayerChip({
    required this.nameAr,
    required this.time,
    required this.isNext,
  });

  final String nameAr;
  final String time;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: isNext
          ? BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold, width: 1),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            TimeFormatter.toIndicDigits(time),
            style: TextStyle(
              fontFamily: AppFonts.amiri,
              fontSize: 12,
              color: isNext ? AppColors.gold : AppColors.textOnDark,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nameAr,
            style: TextStyle(
              fontFamily: AppFonts.amiri,
              fontSize: 11,
              color: isNext ? AppColors.goldLight : AppColors.navInactive,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _CardLoadingState extends StatelessWidget {
  const _CardLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hijri date skeleton
        const _SkeletonBox(width: 140, height: 12, radius: 6),
        const SizedBox(height: 10),
        // Prayer name skeleton
        const _SkeletonBox(width: 100, height: 34, radius: 8),
        const SizedBox(height: 8),
        // Countdown skeleton
        const _SkeletonBox(width: 180, height: 42, radius: 8),
        const SizedBox(height: 16),
        // Progress bar skeleton
        const _SkeletonBox(width: double.infinity, height: 4, radius: 2),
        const SizedBox(height: 16),
        // Prayer chips row skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            5,
            (_) => const _SkeletonBox(width: 52, height: 38, radius: 6),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryGreenDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _CardErrorState extends StatelessWidget {
  const _CardErrorState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: Text(
          'تعذّر تحميل أوقات الصلاة',
          style: TextStyle(
            fontFamily: AppFonts.amiri,
            color: AppColors.goldLight,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
