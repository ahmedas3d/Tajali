class OnboardingSlide {
  const OnboardingSlide({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.illustrationAsset,
    required this.showSkip,
    required this.showBack,
    required this.isPermissionSlide,
  });

  final int index;
  final String title;
  final String subtitle;
  final String illustrationAsset;
  final bool showSkip;
  final bool showBack;
  final bool isPermissionSlide;

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      index: 0,
      title: 'أهلاً بك في تجلي',
      subtitle: 'رفيقك الروحي في كل يوم — قرآن، أذكار، صلاة، وقبلة',
      illustrationAsset: 'assets/images/onboarding_1.png',
      showSkip: true,
      showBack: false,
      isPermissionSlide: false,
    ),
    OnboardingSlide(
      index: 1,
      title: 'كل ما تحتاجه في مكان واحد',
      subtitle: 'مواقيت الصلاة · القرآن الكريم · الأذكار · القبلة · التسبيح',
      illustrationAsset: 'assets/images/onboarding_2.png',
      showSkip: true,
      showBack: true,
      isPermissionSlide: false,
    ),
    OnboardingSlide(
      index: 2,
      title: 'نحتاج إذنك',
      subtitle:
          'لنقدم لك أوقات الصلاة الدقيقة واتجاه القبلة حسب موقعك',
      illustrationAsset: 'assets/images/onboarding_3.png',
      showSkip: false,
      showBack: true,
      isPermissionSlide: true,
    ),
  ];
}
