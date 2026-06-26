import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/onboarding_slide.dart';
import '../data/models/permission_models.dart';
import '../data/services/onboarding_service.dart';
import '../providers/onboarding_providers.dart';
import '../../../app/routes.dart';
import 'widgets/page_indicator_widget.dart';
import 'widgets/permission_card_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  static const _primaryGreen = Color(0xFF1B4332);
  static const _deepGreen = Color(0xFF0D2218);

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: ref.read(onboardingPageProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    ref.read(onboardingPageProvider.notifier).state = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    final current = ref.read(onboardingPageProvider);
    final slides = ref.read(onboardingSlidesProvider);
    if (current < slides.length - 1) _goToPage(current + 1);
  }

  void _onBack() {
    final current = ref.read(onboardingPageProvider);
    if (current > 0) _goToPage(current - 1);
  }

  void _onSkip() => _goToPage(ref.read(onboardingSlidesProvider).length - 1);

  Future<void> _onStartNow() async {
    final locState = ref.read(locationPermissionProvider);
    final notifState = ref.read(notificationPermissionProvider);

    if (locState == PermissionCardState.pending) {
      final result = await Permission.locationWhenInUse.request();
      ref.read(locationPermissionProvider.notifier).state = result.isGranted
          ? PermissionCardState.granted
          : PermissionCardState.denied;
    }

    if (notifState == PermissionCardState.pending) {
      final result = await Permission.notification.request();
      ref.read(notificationPermissionProvider.notifier).state = result.isGranted
          ? PermissionCardState.granted
          : PermissionCardState.denied;
    }

    await OnboardingService().markOnboardingComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _onPermissionCardTap(PermissionType type) async {
    if (type == PermissionType.location) {
      final result = await Permission.locationWhenInUse.request();
      ref.read(locationPermissionProvider.notifier).state = result.isGranted
          ? PermissionCardState.granted
          : PermissionCardState.denied;
    } else {
      final result = await Permission.notification.request();
      ref.read(notificationPermissionProvider.notifier).state = result.isGranted
          ? PermissionCardState.granted
          : PermissionCardState.denied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = ref.watch(onboardingSlidesProvider);

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
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              // RTL: swipe left = next (forward), swipe right = back
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < -300) _onNext();
              if (details.primaryVelocity! > 300) _onBack();
            },
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) =>
                  ref.read(onboardingPageProvider.notifier).state = i,
              children: [
                _Slide1(
                  slide: slides[0],
                  onNext: _onNext,
                  onSkip: _onSkip,
                ),
                _Slide2(
                  slide: slides[1],
                  onNext: _onNext,
                  onBack: _onBack,
                  onSkip: _onSkip,
                ),
                _Slide3(
                  slide: slides[2],
                  onBack: _onBack,
                  onStartNow: _onStartNow,
                  onPermissionTap: _onPermissionCardTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Slide 1: Welcome ──────────────────────────────────────────────────────────

class _Slide1 extends ConsumerWidget {
  const _Slide1({
    required this.slide,
    required this.onNext,
    required this.onSkip,
  });

  final OnboardingSlide slide;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  static const _gold = Color(0xFFC9A84C);
  static const _ivory = Color(0xFFFFF1E8);
  static const _ivory75 = Color(0xBFFFF1E8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(onboardingPageProvider);
    return SafeArea(
      child: Column(
        children: [
          // Skip button row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: _ivory75,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(slide.illustrationAsset, height: 320),
                  const SizedBox(height: 40),
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _ivory,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15,
                      color: _ivory75,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed bottom: indicator + button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              children: [
                PageIndicatorWidget(count: 3, currentIndex: currentPage),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: const Color(0xFF0D2218),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 2: Features ─────────────────────────────────────────────────────────

class _Slide2 extends ConsumerWidget {
  const _Slide2({
    required this.slide,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final OnboardingSlide slide;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  static const _gold = Color(0xFFC9A84C);
  static const _ivory = Color(0xFFFFF1E8);
  static const _ivory75 = Color(0xBFFFF1E8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(onboardingPageProvider);
    return SafeArea(
      child: Column(
        children: [
          // Skip button row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: _ivory75,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(slide.illustrationAsset, height: 320),
                  const SizedBox(height: 40),
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _ivory,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15,
                      color: _ivory75,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed bottom: indicator + buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              children: [
                PageIndicatorWidget(count: 3, currentIndex: currentPage),
                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ivory75,
                        side: const BorderSide(color: Color(0x33FFF1E8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: const Text(
                        'السابق',
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: const Color(0xFF0D2218),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'التالي',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 3: Permissions ──────────────────────────────────────────────────────

class _Slide3 extends ConsumerWidget {
  const _Slide3({
    required this.slide,
    required this.onBack,
    required this.onStartNow,
    required this.onPermissionTap,
  });

  final OnboardingSlide slide;
  final VoidCallback onBack;
  final VoidCallback onStartNow;
  final Future<void> Function(PermissionType) onPermissionTap;

  static const _gold = Color(0xFFC9A84C);
  static const _ivory = Color(0xFFFFF1E8);
  static const _ivory75 = Color(0xBFFFF1E8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(onboardingPageProvider);
    final locState = ref.watch(locationPermissionProvider);
    final notifState = ref.watch(notificationPermissionProvider);

    return SafeArea(
      child: Column(
        children: [
          // Top spacer placeholder (no skip on final slide)
          const SizedBox(height: 56),
          // Scrollable content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(slide.illustrationAsset, height: 320),
                  const SizedBox(height: 32),
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _ivory,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15,
                      color: _ivory75,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PermissionCardWidget(
                    type: PermissionType.location,
                    state: locState,
                    onTap: () => onPermissionTap(PermissionType.location),
                  ),
                  const SizedBox(height: 12),
                  PermissionCardWidget(
                    type: PermissionType.notification,
                    state: notifState,
                    onTap: () => onPermissionTap(PermissionType.notification),
                  ),
                ],
              ),
            ),
          ),
          // Fixed bottom: indicator + buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              children: [
                PageIndicatorWidget(count: 3, currentIndex: currentPage),
                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ivory75,
                        side: const BorderSide(color: Color(0x33FFF1E8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: const Text(
                        'السابق',
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onStartNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: const Color(0xFF0D2218),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ابدأ الآن',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
