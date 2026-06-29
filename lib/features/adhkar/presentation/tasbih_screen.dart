import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../data/services/tasbih_audio_service.dart';
import '../providers/adhkar_providers.dart';
import 'tasbih_history_screen.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  final _audioService = TasbihAudioService();
  int _selectedDhikrIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAudioAndPrefs();
  }

  Future<void> _initAudioAndPrefs() async {
    await _audioService.init();
    final service = ref.read(tasbihServiceProvider);
    // Load persisted custom targets into memory before reading session
    await service.loadCustomTargets();
    final sound = await service.getSoundEnabled();
    final vibration = await service.getVibrationEnabled();
    if (mounted) {
      ref.read(tasbihSoundEnabledProvider.notifier).state = sound;
      ref.read(tasbihVibrationEnabledProvider.notifier).state = vibration;
      // Refresh session now that custom targets are loaded
      await ref
          .read(tasbihNotifierProvider.notifier)
          .switchDhikr(tasbihDhikrTypes[_selectedDhikrIndex]);
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final soundEnabled = ref.read(tasbihSoundEnabledProvider);
    final vibrationEnabled = ref.read(tasbihVibrationEnabledProvider);
    final roundCompleted =
        await ref.read(tasbihNotifierProvider.notifier).tap();

    if (roundCompleted) {
      if (soundEnabled) await _audioService.playRoundComplete();
      if (vibrationEnabled) await _audioService.vibrateRoundComplete();
    } else {
      if (soundEnabled) await _audioService.playTap();
      if (vibrationEnabled) await _audioService.vibrateTap();
    }
  }

  Future<void> _onReset() async {
    await ref.read(tasbihNotifierProvider.notifier).reset();
  }

  Future<void> _onLog() async {
    final ctx = context;
    await ref.read(tasbihNotifierProvider.notifier).logSession();
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تسجيل الجلسة',
          style: TextStyle(fontFamily: AppFonts.arabic),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const TasbihHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(tasbihNotifierProvider);
    final soundEnabled = ref.watch(tasbihSoundEnabledProvider);
    final vibrationEnabled = ref.watch(tasbihVibrationEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        // Back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'التسبيح',
          style: TextStyle(
            fontFamily: AppFonts.arabic,
            fontSize: 20,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _onReset,
            child: const Text(
              'إعادة',
              style: TextStyle(
                fontFamily: AppFonts.arabic,
                color: AppColors.gold,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: _onLog,
            child: const Text(
              'سجّل',
              style: TextStyle(
                fontFamily: AppFonts.arabic,
                color: AppColors.gold,
                fontSize: 14,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _DhikrTabs(
            selectedIndex: _selectedDhikrIndex,
            onSelect: (i) async {
              setState(() => _selectedDhikrIndex = i);
              await ref
                  .read(tasbihNotifierProvider.notifier)
                  .switchDhikr(tasbihDhikrTypes[i]);
            },
          ),
          const SizedBox(height: 16),
          // Tasbih bead rosary arc
          _RosaryArc(
            current: session.currentCount,
            target: session.target,
          ),
          const SizedBox(height: 8),
          _CounterDisplay(
            current: session.currentCount,
            target: session.target,
            completedRounds: session.completedRounds,
          ),
          const SizedBox(height: 12),
          _RoundDots(completedRounds: session.completedRounds),
          const Spacer(),
          _TasbihButton(onTap: _onTap),
          const SizedBox(height: 16),
          _ControlBar(
            soundEnabled: soundEnabled,
            vibrationEnabled: vibrationEnabled,
            onSoundToggle: (v) async {
              ref.read(tasbihSoundEnabledProvider.notifier).state = v;
              await ref.read(tasbihServiceProvider).setSoundEnabled(v);
            },
            onVibrationToggle: (v) async {
              ref.read(tasbihVibrationEnabledProvider.notifier).state = v;
              await ref.read(tasbihServiceProvider).setVibrationEnabled(v);
            },
            onSetTarget: () => _showSetTargetDialog(context, session.target),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  void _showSetTargetDialog(BuildContext context, int currentTarget) {
    final controller = TextEditingController(text: currentTarget.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceIvory,
        title: const Text(
          'تحديد العدد',
          style: TextStyle(
              fontFamily: AppFonts.arabic, color: AppColors.textDark),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.arabic,
            fontSize: 24,
            color: AppColors.textDark,
          ),
          decoration: const InputDecoration(
            hintText: '33 / 66 / 99',
            hintStyle: TextStyle(
              fontFamily: AppFonts.arabic,
              color: AppColors.textMuted,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                  fontFamily: AppFonts.arabic, color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () async {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                final dhikrType = tasbihDhikrTypes[_selectedDhikrIndex];
                await ref
                    .read(tasbihServiceProvider)
                    .setCustomTarget(dhikrType, val);
                await ref
                    .read(tasbihNotifierProvider.notifier)
                    .switchDhikr(dhikrType);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'تأكيد',
              style:
                  TextStyle(fontFamily: AppFonts.arabic, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rosary bead arc ──────────────────────────────────────────────────────────

class _RosaryArc extends StatelessWidget {
  const _RosaryArc({required this.current, required this.target});

  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: CustomPaint(
        painter: _RosaryPainter(current: current, target: target),
      ),
    );
  }
}

class _RosaryPainter extends CustomPainter {
  const _RosaryPainter({required this.current, required this.target});

  final int current;
  final int target;

  // Clamp bead count to avoid tiny beads on very large targets
  static const int _maxDisplayBeads = 99;
  static const int _minDisplayBeads = 11;

  @override
  void paint(Canvas canvas, Size size) {
    if (target <= 0) return;

    final beadCount = target.clamp(_minDisplayBeads, _maxDisplayBeads);
    final filledCount = current.clamp(0, beadCount);

    // Arc: semicircle from left (π) sweeping through top to right (0)
    // The arc opens downward — center is at the bottom of the widget
    final cx = size.width / 2;
    final cy = size.height; // bottom center is the "origin"
    final radius = size.height * 0.88;

    // Bead radius shrinks as count grows
    final beadR = (radius * math.pi / beadCount / 2.4).clamp(3.5, 11.0);

    // String
    final stringPaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final rect =
        Rect.fromCenter(center: Offset(cx, cy), width: radius * 2, height: radius * 2);
    canvas.drawArc(rect, math.pi, math.pi, false, stringPaint);

    // Beads
    final filledPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;
    final emptyPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final filledBorderPaint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final emptyBorderPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < beadCount; i++) {
      // Goes from π (left) → 0 (right) across the top
      final angle = math.pi - (math.pi * i / (beadCount - 1));
      final bx = cx + radius * math.cos(angle);
      final by = cy + radius * math.sin(angle);
      final offset = Offset(bx, by);

      final isFilled = i < filledCount;
      canvas.drawCircle(offset, beadR, isFilled ? filledPaint : emptyPaint);
      canvas.drawCircle(
          offset, beadR, isFilled ? filledBorderPaint : emptyBorderPaint);

      // Marker bead (every 33 or at target / 3 boundary) — slightly larger, gold accent
      if (beadCount >= 33 && i > 0 && i % 33 == 0) {
        final markerPaint = Paint()
          ..color = AppColors.gold
          ..style = PaintingStyle.fill;
        canvas.drawCircle(offset, beadR * 1.4, markerPaint);
      }
    }

    // Tassel indicator at the left end (position π)
    final tasselX = cx + radius * math.cos(math.pi);
    final tasselY = cy + radius * math.sin(math.pi);
    final tasselPaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(tasselX, tasselY),
      Offset(tasselX - 16, tasselY + 20),
      tasselPaint,
    );
    canvas.drawLine(
      Offset(tasselX, tasselY),
      Offset(tasselX - 8, tasselY + 24),
      tasselPaint,
    );
    canvas.drawLine(
      Offset(tasselX, tasselY),
      Offset(tasselX - 20, tasselY + 14),
      tasselPaint,
    );
  }

  @override
  bool shouldRepaint(_RosaryPainter old) =>
      old.current != current || old.target != target;
}

// ── Dhikr selector tabs ───────────────────────────────────────────────────────

class _DhikrTabs extends StatelessWidget {
  const _DhikrTabs({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(tasbihDhikrTypes.length, (i) {
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.surfaceIvory,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.gold.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              tasbihDhikrTypes[i],
              style: TextStyle(
                fontFamily: AppFonts.arabic,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Counter display ───────────────────────────────────────────────────────────

class _CounterDisplay extends StatelessWidget {
  const _CounterDisplay({
    required this.current,
    required this.target,
    required this.completedRounds,
  });

  final int current;
  final int target;
  final int completedRounds;

  @override
  Widget build(BuildContext context) {
    final roundsText = completedRounds == 0
        ? ''
        : completedRounds == 1
            ? 'دورة مكتملة'
            : '$completedRounds دورات مكتملة';

    return Column(
      children: [
        Text(
          '$current',
          style: const TextStyle(
            fontFamily: AppFonts.arabic,
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        Text(
          'من $target',
          style: const TextStyle(
            fontFamily: AppFonts.arabic,
            fontSize: 16,
            color: AppColors.textMuted,
          ),
        ),
        if (completedRounds > 0) ...[
          const SizedBox(height: 6),
          Text(
            roundsText,
            style: const TextStyle(
              fontFamily: AppFonts.arabic,
              fontSize: 13,
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Round dots ────────────────────────────────────────────────────────────────

class _RoundDots extends StatelessWidget {
  const _RoundDots({required this.completedRounds});

  final int completedRounds;

  @override
  Widget build(BuildContext context) {
    if (completedRounds == 0) return const SizedBox(height: 12);
    final dots = completedRounds.clamp(0, 10);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dots, (_) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen,
          ),
        );
      }),
    );
  }
}

// ── Big tap button ────────────────────────────────────────────────────────────

class _TasbihButton extends StatelessWidget {
  const _TasbihButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
          ),
          child: const Text(
            'اضغط للتسبيح',
            style: TextStyle(
              fontFamily: AppFonts.arabic,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Control bar ───────────────────────────────────────────────────────────────

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.onSoundToggle,
    required this.onVibrationToggle,
    required this.onSetTarget,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;
  final void Function(bool) onSoundToggle;
  final void Function(bool) onVibrationToggle;
  final VoidCallback onSetTarget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToggleChip(
            label: 'صوت',
            icon: soundEnabled ? Icons.volume_up : Icons.volume_off,
            enabled: soundEnabled,
            onTap: () => onSoundToggle(!soundEnabled),
          ),
          _ToggleChip(
            label: 'اهتزاز',
            icon: vibrationEnabled ? Icons.vibration : Icons.phone_android,
            enabled: vibrationEnabled,
            onTap: () => onVibrationToggle(!vibrationEnabled),
          ),
          GestureDetector(
            onTap: onSetTarget,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceIvory,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune, size: 16, color: AppColors.primaryGreen),
                  SizedBox(width: 6),
                  Text(
                    'تحديد العدد',
                    style: TextStyle(
                      fontFamily: AppFonts.arabic,
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryGreen : AppColors.surfaceIvory,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled
                ? AppColors.primaryGreen
                : AppColors.gold.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: enabled ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.arabic,
                fontSize: 13,
                color: enabled ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
