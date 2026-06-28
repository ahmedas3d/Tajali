import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/services/adhan_notification_service.dart';
import 'features/prayer_times/data/models/hijri_date_model.dart';
import 'features/prayer_times/data/models/prayer_times_model.dart';
import 'features/prayer_times/data/services/prayer_cache_service.dart';
import 'features/prayer_times/providers/prayer_times_providers.dart';
import 'features/quran/data/models/ayah_bookmark.dart';
import 'features/quran/data/models/ayah_model.dart';
import 'features/quran/data/models/surah_model.dart';
import 'features/quran/data/services/bookmark_service.dart';
import 'features/quran/data/services/quran_service.dart';
import 'shared/local_storage/storage_service.dart';

const _hijriBoxName = 'hijriDateBox';

final storageService = StorageService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await storageService.initialize();
  await AdhanNotificationService.initialize();

  await Hive.initFlutter();
  Hive.registerAdapter(PrayerTimesModelAdapter());
  Hive.registerAdapter(HijriDateModelAdapter());
  Hive.registerAdapter(SurahModelAdapter());
  Hive.registerAdapter(AyahModelAdapter());
  Hive.registerAdapter(AyahBookmarkAdapter());
  await Hive.openBox<PrayerTimesModel>(PrayerCacheService.boxName);
  await Hive.openBox<HijriDateModel>(_hijriBoxName);
  await Hive.openBox<SurahModel>(QuranService.boxName);
  await Hive.openBox(BookmarkService.boxName);
  await Hive.openBox('ayahTextBox');
  await Hive.openBox<AyahBookmark>('ayahBookmarksBox');

  final savedMethodId = await loadSavedMethodId();
  final savedCity = await loadSavedCity();
  final savedNotifMode = await loadSavedNotificationMode();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ProviderScope(
      overrides: [
        calculationMethodProvider.overrideWith((ref) => savedMethodId),
        manualCityProvider.overrideWith((ref) => savedCity),
        notificationModeProvider.overrideWith((ref) => savedNotifMode),
      ],
      child: const TajaliApp(),
    ),
  );
}
