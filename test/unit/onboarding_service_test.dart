import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajali/features/splash/data/services/onboarding_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingService', () {
    test('isFirstLaunch returns true when key is absent', () async {
      final service = OnboardingService();
      expect(await service.isFirstLaunch(), isTrue);
    });

    test('isFirstLaunch returns false after markOnboardingComplete', () async {
      final service = OnboardingService();
      await service.markOnboardingComplete();
      expect(await service.isFirstLaunch(), isFalse);
    });

    test('markOnboardingComplete persists across separate service instances',
        () async {
      await OnboardingService().markOnboardingComplete();
      expect(await OnboardingService().isFirstLaunch(), isFalse);
    });
  });
}
