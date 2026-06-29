import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../core/services/adhan_audio_service.dart';
import '../../../core/services/adhan_notification_service.dart';
import '../../../core/utils/helpers.dart';
import '../data/models/hijri_date_model.dart';
import '../data/models/prayer_times_model.dart';
import '../providers/prayer_times_providers.dart';
import 'widgets/city_search_sheet.dart';
import 'widgets/prayer_time_row.dart';

// ── Arabic date helpers ───────────────────────────────────────────────────────

const _daysAr = [
  'الأحد',
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
];
const _monthsAr = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

String _gregorianAr(DateTime d) {
  final day = _daysAr[d.weekday % 7];
  final num = TimeFormatter.toIndicDigits(d.day.toString());
  final month = _monthsAr[d.month - 1];
  final year = TimeFormatter.toIndicDigits(d.year.toString());
  return '$day، $num $month $year';
}

String _hijriAr(HijriDateModel h) {
  final d = TimeFormatter.toIndicDigits(h.day.toString());
  final y = TimeFormatter.toIndicDigits(h.year.toString());
  return '$d ${h.monthAr} $y هـ';
}

String _buildCountdown(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  final parts = <String>[];
  if (h > 0) parts.add('${TimeFormatter.toIndicDigits(h.toString())} ساعة');
  if (m > 0) parts.add('${TimeFormatter.toIndicDigits(m.toString())} دقيقة');
  parts.add(
      '${TimeFormatter.toIndicDigits(s.toString().padLeft(2, '0'))} ثانية');
  return 'متبقى ${parts.join(' و')}';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final times = ref.read(prayerTimesProvider).valueOrNull;
      if (times == null || _isNewDay(times.date)) {
        ref.invalidate(prayerTimesProvider);
        ref.invalidate(hijriDateProvider);
      }
    }
  }

  bool _isNewDay(String cachedDate) {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return cachedDate != today;
  }

  @override
  Widget build(BuildContext context) {
    final timesAsync = ref.watch(prayerTimesProvider);
    final hijriAsync = ref.watch(hijriDateProvider);
    final nextAsync = ref.watch(nextPrayerProvider);
    final currentAsync = ref.watch(currentPrayerNameProvider);
    final manualCity = ref.watch(manualCityProvider);
    final methodId = ref.watch(calculationMethodProvider);

    // Play adhan in-app when prayer time just arrived (elapsed ≤ 5s)
    // and only when the user has chosen full-sound mode.
    ref.listen<AsyncValue<NextPrayerModel>>(nextPrayerProvider, (prev, next) {
      final model = next.valueOrNull;
      if (model == null) return;
      final elapsed = model.elapsed;
      if (elapsed == null || elapsed.inSeconds > 5) return;
      if (prev?.valueOrNull?.elapsed != null) return; // already in elapsed mode

      final mode = ref.read(notificationModeProvider);
      if (mode == AdhanNotificationMode.fullSound) {
        final src = ref.read(adhanSoundProvider);
        final audioSound = src == AdhanSoundSource.egypt ? AdhanSound.egypt : AdhanSound.makkah;
        AdhanAudioService.instance.play(
          isFajr: model.name == 'fajr',
          sound: audioSound,
        );
      }
    });

    final cityName = manualCity?.nameAr ?? 'القاهرة';

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'مواقيت الصلاة',
          style: TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
      ),
      body: timesAsync.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => const _ErrorState(),
        data: (times) => _PrayerTimesBody(
          times: times,
          hijriAsync: hijriAsync,
          nextAsync: nextAsync,
          currentPrayerKey: currentAsync.valueOrNull,
          methodId: methodId,
          isStale: _isNewDay(times.date),
          manualCity: manualCity,
          onSelectCity: () => showCitySearchSheet(context),
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _PrayerTimesBody extends StatelessWidget {
  const _PrayerTimesBody({
    required this.times,
    required this.hijriAsync,
    required this.nextAsync,
    required this.currentPrayerKey,
    required this.methodId,
    required this.isStale,
    required this.manualCity,
    required this.onSelectCity,
  });

  final PrayerTimesModel times;
  final AsyncValue<HijriDateModel> hijriAsync;
  final AsyncValue<NextPrayerModel> nextAsync;
  final String? currentPrayerKey;
  final int methodId;
  final bool isStale;
  final ManualCityEntry? manualCity;
  final VoidCallback onSelectCity;

  // nameAr, provider key, imsak-style flag
  static const _rows = [
    ('الإمساك', 'imsak', true),
    ('الفجر', 'fajr', false),
    ('الشروق', 'sunrise', false),
    ('الظهر', 'dhuhr', false),
    ('العصر', 'asr', false),
    ('المغرب', 'maghrib', false),
    ('العشاء', 'isha', false),
  ];

  static const _prayerOrder = [
    'fajr',
    'sunrise',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  /// Always returns the key of the truly upcoming prayer.
  /// During the 10-min elapsed window, [next.name] is the prayer that just
  /// called azan — we advance one step to find the actual next prayer.
  static String? _upcomingKey(NextPrayerModel? next) {
    if (next == null) return null;
    if (next.elapsed == null) return next.name;
    final idx = _prayerOrder.indexOf(next.name);
    if (idx < 0 || idx >= _prayerOrder.length - 1) return null;
    return _prayerOrder[idx + 1];
  }

  String _timeFor(String key) {
    switch (key) {
      case 'fajr':
        return times.fajr;
      case 'sunrise':
        return times.sunrise;
      case 'dhuhr':
        return times.dhuhr;
      case 'asr':
        return times.asr;
      case 'maghrib':
        return times.maghrib;
      case 'isha':
        return times.isha;
      default:
        return times.imsak;
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = nextAsync.valueOrNull;
    final methodName = CalculationMethodConfig.all
        .firstWhere((m) => m.id == methodId,
            orElse: () => CalculationMethodConfig.all.first)
        .nameAr;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date section
          // _DateSection(
          //   hijriAsync: hijriAsync,
          //   manualCity: manualCity,
          //   onSelectCity: onSelectCity,
          // ),
          const SizedBox(height: 15),

          // Hero card
          if (next != null)
            _HeroCard(next: next)
          else
            const SizedBox(height: 8),

          // Offline banner
          if (isStale) _OfflineBanner(fetchedAt: times.fetchedAt),

          const SizedBox(height: 8),

          // Prayer rows — highlight the UPCOMING prayer, not the one that passed
          ..._rows.map((r) {
            final upcomingKey = _upcomingKey(next);
            final isNext = !r.$3 && upcomingKey == r.$2;
            return PrayerTimeRow(
              nameAr: r.$1,
              time: _timeFor(r.$2),
              isHighlighted: isNext,
              subLabel: isNext ? 'القادمة' : null,
              isImsak: r.$3,
            );
          }),

          const SizedBox(height: 16),

          // Calculation method chip
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                'طريقة الحساب: $methodName',
                style: const TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Date section ──────────────────────────────────────────────────────────────

// class _DateSection extends StatelessWidget {
//   const _DateSection({
//     required this.hijriAsync,
//     required this.manualCity,
//     required this.onSelectCity,
//   });

//   final AsyncValue<HijriDateModel> hijriAsync;
//   final ManualCityEntry? manualCity;
//   final VoidCallback onSelectCity;

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hijriText = hijriAsync.when(
//       data: _hijriAr,
//       loading: () => '...',
//       error: (_, __) => '',
//     );

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//       child: Column(
//         children: [
// // Hijri date
// Text(
//   hijriText,
//   textAlign: TextAlign.center,
//   style: const TextStyle(
//     fontFamily: AppFonts.amiri,
//     fontSize: 22,
//     fontWeight: FontWeight.bold,
//     color: AppColors.textDark,
//   ),
// ),
// const SizedBox(height: 8),
// Decorative divider with "+" change-city button
// Row(
//   children: [
//     const Expanded(
//         child: Divider(color: AppColors.gold, thickness: 0.6)),
//     const SizedBox(width: 10),
//     GestureDetector(
//       onTap: onSelectCity,
//       child: Container(
//         width: 28,
//         height: 28,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//               color: AppColors.gold.withValues(alpha: 0.6), width: 1),
//           color: AppColors.backgroundParchment,
//         ),
//         alignment: Alignment.center,
//         child: const Icon(Icons.add,
//             size: 16, color: AppColors.goldText),
//       ),
//     ),
//     const SizedBox(width: 10),
//     const Expanded(
//         child: Divider(color: AppColors.gold, thickness: 0.6)),
//   ],
// ),
// const SizedBox(height: 6),
// // Gregorian date
// Text(
//   _gregorianAr(now),
//   textAlign: TextAlign.center,
//   style: const TextStyle(
//     fontFamily: AppFonts.amiri,
//     fontSize: 14,
//     color: AppColors.textMedium,
//   ),
// ),
//         ],
//       ),
//     );
//   }
// }

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.next});
  final NextPrayerModel next;

  @override
  Widget build(BuildContext context) {
    final timeIndic = TimeFormatter.toIndicDigits(next.scheduledTime);
    final countdown = _buildCountdown(next.remaining);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceIvory,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(90),
            bottom: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadowDark,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
        child: Column(
          children: [
            const Text(
              'الصلاة القادمة',
              style: TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              next.nameAr,
              style: const TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeIndic,
              style: const TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Countdown pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.6), width: 1),
                color: AppColors.gold.withValues(alpha: 0.08),
              ),
              child: Text(
                countdown,
                style: const TextStyle(
                  fontFamily: AppFonts.amiri,
                  fontSize: 13,
                  color: AppColors.goldText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Offline banner ────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.fetchedAt});
  final DateTime fetchedAt;

  @override
  Widget build(BuildContext context) {
    final h = fetchedAt.hour % 12 == 0 ? 12 : fetchedAt.hour % 12;
    final m = fetchedAt.minute.toString().padLeft(2, '0');
    final marker = fetchedAt.hour >= 12 ? 'م' : 'ص';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 15, color: AppColors.warning),
          const SizedBox(width: 8),
          Text(
            'آخر تحديث: $h:$m $marker',
            style: const TextStyle(
              fontFamily: AppFonts.amiri,
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: 12),
            Text(
              'تعذّر تحميل أوقات الصلاة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.amiri,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date section skeleton
        Container(
          height: 80,
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Hero card skeleton
        Container(
          height: 170,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(90),
              bottom: Radius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Row skeletons
        ...List.generate(
          7,
          (_) => Container(
            height: 58,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
