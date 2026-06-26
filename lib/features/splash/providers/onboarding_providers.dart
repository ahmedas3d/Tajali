import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/onboarding_slide.dart';
import '../data/models/permission_models.dart';

final onboardingPageProvider = StateProvider<int>((ref) => 0);

final locationPermissionProvider =
    StateProvider<PermissionCardState>((ref) => PermissionCardState.pending);

final notificationPermissionProvider =
    StateProvider<PermissionCardState>((ref) => PermissionCardState.pending);

final onboardingSlidesProvider = Provider<List<OnboardingSlide>>(
  (ref) => OnboardingSlide.slides,
);
