import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../data/models/qibla_model.dart';
import '../providers/qibla_providers.dart';
import 'widgets/compass_widget.dart';
import 'widgets/qibla_direction_badge.dart';
import 'widgets/calibration_hint.dart';
import 'widgets/nearest_mosque_card.dart';
import 'widgets/qibla_stats_row.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(qiblaLocationProvider);
    final serviceStatus = ref.watch(locationServiceStatusProvider);

    // Mid-session revocation: service turned off while screen is visible
    final serviceOff = serviceStatus.valueOrNull != null &&
        serviceStatus.valueOrNull.toString().contains('disabled');

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text('القبلة',
            style: AppTextStyles.heading2.copyWith(color: AppColors.gold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: serviceOff
          ? const _ErrorBody(error: 'location_service_off')
          : locationAsync.when(
              loading: () => const _LoadingBody(),
              error: (e, _) => _ErrorBody(error: e.toString()),
              data: (_) => const _CompassBody(),
            ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text('جارٍ تحديد الاتجاه...', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ── Error / permission card ───────────────────────────────────────────────────

class _ErrorBody extends ConsumerWidget {
  const _ErrorBody({required this.error});
  final String error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPermission = error.contains('permission_denied') ||
        error.contains('location_service_off');
    final title = isPermission ? 'إذن الموقع مطلوب' : 'تعذّر تحديد الموقع';
    final subtitle = isPermission
        ? 'يرجى السماح بالوصول إلى الموقع لعرض اتجاه القبلة.'
        : 'تحقق من اتصالك أو أعد المحاولة.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded,
                size: 64, color: AppColors.gold),
            const SizedBox(height: 20),
            Text(title,
                style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(subtitle,
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            if (isPermission) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await Geolocator.requestPermission();
                  ref.invalidate(qiblaLocationProvider);
                },
                icon: const Icon(Icons.location_on_rounded,
                    color: AppColors.gold),
                label: const Text('السماح بالوصول',
                    style: TextStyle(
                        fontFamily: 'Amiri', color: AppColors.gold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Main compass body ─────────────────────────────────────────────────────────

class _CompassBody extends ConsumerWidget {
  const _CompassBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaAsync = ref.watch(qiblaModelProvider);
    final rotationTurns = ref.watch(qiblaRotationProvider) / 360;
    final accuracy =
        ref.watch(compassAccuracyProvider).valueOrNull ?? AccuracyLevel.low;

    return qiblaAsync.when(
      loading: () => const _LoadingBody(),
      error: (e, _) => _ErrorBody(error: e.toString()),
      data: (model) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              CompassWidget(
                rotationTurns: rotationTurns,
                accuracy: accuracy,
              ),
              const SizedBox(height: 20),
              QiblaDirectionBadge(degrees: model.direction),
              const SizedBox(height: 20),
              QiblaStatsRow(
                distanceKm: model.distanceKm,
                cityName: model.cityName,
              ),
              const SizedBox(height: 12),
              CalibrationHint(accuracy: accuracy),
              const _MosqueSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nearest mosque (live-only, hidden when offline or no result) ──────────────

class _MosqueSection extends ConsumerWidget {
  const _MosqueSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mosque = ref.watch(nearestMosqueProvider).valueOrNull;
    if (mosque == null) return const SizedBox.shrink();
    return Column(
      children: [
        const SizedBox(height: 16),
        NearestMosqueCard(mosque: mosque),
      ],
    );
  }
}
