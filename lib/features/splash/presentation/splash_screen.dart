import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tajali/app/theme/app_colors.dart';
import 'package:tajali/app/theme/app_text_styles.dart';
import '../data/services/onboarding_service.dart';
import '../../../app/routes.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  static const _primaryGreen = Color(0xFF1B4332);
  static const _deepGreen = Color(0xFF0D2218);
  static const _gold = Color(0xFFC9A84C);
  static const _goldLight = Color(0xFFE8C97A);
  static const _ivory75 = Color(0xBFFFF1E8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    final firstLaunchFuture = OnboardingService().isFirstLaunch();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    final isFirst = await firstLaunchFuture;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isFirst ? const OnboardingScreen() : const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryGreen, _deepGreen],
            ),
          ),
          child: Stack(
            children: [
              // Corner ornaments — top-right and top-left (mirrored)
              Positioned(
                top: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    'assets/svg/corner_ornament.svg',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Opacity(
                  opacity: 0.5,
                  child: Transform.scale(
                    scaleX: -1,
                    child: SvgPicture.asset(
                      'assets/svg/corner_ornament.svg',
                      width: 110,
                      height: 110,
                    ),
                  ),
                ),
              ),
              // Arabesque bands
              const Positioned(
                  top: 72, left: 0, right: 0, child: _ArabesqueLine()),
              const Positioned(
                  bottom: 72, left: 0, right: 0, child: _ArabesqueLine()),
              // Central animated composition
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _LogoDisc(),
                        const SizedBox(height: 36),
                        // App name with gold gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [_goldLight, _gold],
                          ).createShader(bounds),
                          child: Text(
                            'تَجَلِّي',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.gold,
                              fontSize: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const _OrnamentalDivider(),
                        const SizedBox(height: 14),
                        const Text(
                          'رفيقك الروحي اليومي',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: _ivory75,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Pulsing dot loading indicator
              const Positioned(
                bottom: 56,
                left: 0,
                right: 0,
                child: _PulsingDots(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo disc: circular container + SVG star ──────────────────────────────────

class _LogoDisc extends StatelessWidget {
  const _LogoDisc();

  static const _gold = Color(0xFFC9A84C);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial glow
          Container(
            width: 240,
            height: 240,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x30C9A84C),
                  blurRadius: 72,
                  spreadRadius: 24,
                ),
              ],
            ),
          ),
          // Outer halo ring with 8 diamonds
          const _HaloRing(diameter: 220, diamondRadius: 110),
          // Inner subtle ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x1AC9A84C),
                width: 0.5,
              ),
            ),
          ),
          // Logo disc
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF091A11),
              border: Border.all(color: _gold, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x60000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x20C9A84C),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/splash_image.png',
                width: 110,
                height: 110,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Halo ring with 8 diamond points ──────────────────────────────────────────

class _HaloRing extends StatelessWidget {
  const _HaloRing({required this.diameter, required this.diamondRadius});

  final double diameter;
  final double diamondRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x33C9A84C),
                width: 1,
              ),
            ),
          ),
          for (final angle in [
            0.0,
            45.0,
            90.0,
            135.0,
            180.0,
            225.0,
            270.0,
            315.0
          ])
            _DiamondPoint(angleDeg: angle, radius: diamondRadius),
        ],
      ),
    );
  }
}

class _DiamondPoint extends StatelessWidget {
  const _DiamondPoint({required this.angleDeg, required this.radius});

  final double angleDeg;
  final double radius;

  static double _sin(double r) => r - r * r * r / 6 + r * r * r * r * r / 120;
  static double _cos(double r) => 1 - r * r / 2 + r * r * r * r / 24;

  @override
  Widget build(BuildContext context) {
    final rad = angleDeg * 3.14159265 / 180;
    return Transform.translate(
      offset: Offset(_sin(rad) * radius, -_cos(rad) * radius),
      child: Transform.rotate(
        angle: 3.14159265 / 4,
        child: Container(
          width: 7,
          height: 7,
          color: const Color(0xFFC9A84C),
        ),
      ),
    );
  }
}

// ── Ornamental divider ────────────────────────────────────────────────────────

class _OrnamentalDivider extends StatelessWidget {
  const _OrnamentalDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _line(Alignment.centerRight),
        const SizedBox(width: 6),
        Transform.rotate(
          angle: 3.14159265 / 4,
          child: Container(
            width: 7,
            height: 7,
            color: const Color(0xFFC9A84C),
          ),
        ),
        const SizedBox(width: 6),
        _line(Alignment.centerLeft),
      ],
    );
  }

  Widget _line(Alignment end) {
    return Container(
      width: 56,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: end == Alignment.centerRight
              ? Alignment.centerLeft
              : Alignment.centerRight,
          end: end,
          colors: const [Color(0x00C9A84C), Color(0xFFC9A84C)],
        ),
      ),
    );
  }
}

// ── Pulsing dot loading indicator ────────────────────────────────────────────

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFC9A84C);
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _anims = List.generate(3, (i) {
      final start = i * 0.2;
      return Tween<double>(begin: 0.25, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, start + 0.5, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: _anims[i].value),
            ),
          );
        }),
      ),
    );
  }
}

// ── Arabesque decorative line ─────────────────────────────────────────────────

class _ArabesqueLine extends StatelessWidget {
  const _ArabesqueLine();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.22,
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
              child: Container(height: 0.5, color: const Color(0xFFC9A84C))),
          const SizedBox(width: 10),
          _diamond(),
          const SizedBox(width: 8),
          _diamond(size: 10),
          const SizedBox(width: 8),
          _diamond(),
          const SizedBox(width: 10),
          Expanded(
              child: Container(height: 0.5, color: const Color(0xFFC9A84C))),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _diamond({double size = 7}) {
    return Transform.rotate(
      angle: 3.14159265 / 4,
      child:
          Container(width: size, height: size, color: const Color(0xFFC9A84C)),
    );
  }
}
