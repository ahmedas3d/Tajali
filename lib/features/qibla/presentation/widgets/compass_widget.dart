import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/qibla_model.dart';

class CompassWidget extends StatelessWidget {
  const CompassWidget({
    super.key,
    required this.rotationTurns,
    required this.accuracy,
    this.hasCompassSensor = true,
    this.size = 280,
  });

  final double rotationTurns;
  final AccuracyLevel accuracy;
  final bool hasCompassSensor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _CompassDial(size: size, rotationTurns: rotationTurns),
          _KaabaIcon(size: size),
          if (!hasCompassSensor) _NoSensorLabel(),
          Positioned(
            bottom: size * 0.07,
            child: _AccuracyBadge(accuracy: accuracy),
          ),
        ],
      ),
    );
  }
}

// ── Compass dial (rotates) ────────────────────────────────────────────────────

class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.size, required this.rotationTurns});
  final double size;
  final double rotationTurns;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: rotationTurns,
      duration: const Duration(milliseconds: 150),
      child: CustomPaint(
        size: Size(size, size),
        painter: _DialPainter(),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring background
    final bgPaint = Paint()..color = AppColors.primaryGreen;
    canvas.drawCircle(center, radius, bgPaint);

    // Gold border ring
    final borderPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius - 1, borderPaint);

    // Inner decorative ring
    final innerRingPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.82, innerRingPaint);

    // Cardinal direction tick marks
    final tickPaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = i * 45 * (math.pi / 180) - math.pi / 2;
      final isMajor = i % 2 == 0;
      final tickLen = isMajor ? radius * 0.12 : radius * 0.07;
      final outerPt = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      final innerPt = Offset(
        center.dx + (radius - 4 - tickLen) * math.cos(angle),
        center.dy + (radius - 4 - tickLen) * math.sin(angle),
      );
      canvas.drawLine(outerPt, innerPt, tickPaint);
    }

    // Qibla needle — golden triangle pointing to 0° (top = Qibla direction)
    final needlePaint = Paint()..color = AppColors.gold;
    final needlePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.62)
      ..lineTo(center.dx - 7, center.dy - radius * 0.20)
      ..lineTo(center.dx + 7, center.dy - radius * 0.20)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // Needle shadow half (muted)
    final needleShadePaint = Paint()
      ..color = AppColors.goldDark.withValues(alpha: 0.55);
    final needleShadePath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.55)
      ..lineTo(center.dx - 5, center.dy + radius * 0.20)
      ..lineTo(center.dx + 5, center.dy + radius * 0.20)
      ..close();
    canvas.drawPath(needleShadePath, needleShadePaint);

    // Center circle cap
    final capPaint = Paint()..color = AppColors.primaryGreenDark;
    canvas.drawCircle(center, radius * 0.13, capPaint);
    final capBorderPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.13, capBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Ka'ba icon at center ──────────────────────────────────────────────────────

class _KaabaIcon extends StatelessWidget {
  const _KaabaIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.18,
      height: size * 0.18,
      child: Icon(
        Icons.mosque_rounded,
        color: AppColors.gold,
        size: size * 0.18,
      ),
    );
  }
}

// ── No-sensor message ─────────────────────────────────────────────────────────

class _NoSensorLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        'لا يوجد بوصلة على هذا الجهاز',
        style: AppTextStyles.onDark.copyWith(fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Accuracy badge ────────────────────────────────────────────────────────────

class _AccuracyBadge extends StatelessWidget {
  const _AccuracyBadge({required this.accuracy});
  final AccuracyLevel accuracy;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (accuracy) {
      AccuracyLevel.high => ('دقة عالية', const Color(0xFF2D6A4F)),
      AccuracyLevel.medium => ('دقة متوسطة', const Color(0xFF9A7A2E)),
      AccuracyLevel.low => ('دقة منخفضة', const Color(0xFF8B0000)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
