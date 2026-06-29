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
import 'features/adhkar/data/models/tasbih_history_entry.dart';
import 'features/adhkar/data/models/tasbih_session_model.dart';
import 'features/adhkar/data/services/dhikr_counter_service.dart';
import 'features/adhkar/data/services/tasbih_service.dart';
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
  Hive.registerAdapter(TasbihSessionModelAdapter());
  Hive.registerAdapter(TasbihHistoryEntryAdapter());
  await Hive.openBox<PrayerTimesModel>(PrayerCacheService.boxName);
  await Hive.openBox<HijriDateModel>(_hijriBoxName);
  await Hive.openBox<SurahModel>(QuranService.boxName);
  await Hive.openBox(BookmarkService.boxName);
  await Hive.openBox('ayahTextBox');
  await Hive.openBox<AyahBookmark>('ayahBookmarksBox');
  await Hive.openBox<int>(DhikrCounterService.boxName);
  await Hive.openBox<TasbihSessionModel>(TasbihService.sessionBoxName);
  await Hive.openBox<TasbihHistoryEntry>(TasbihService.historyBoxName);

  final savedMethodId = await loadSavedMethodId();
  final savedCity = await loadSavedCity();
  final savedNotifMode = await loadSavedNotificationMode();
  final savedAdhanSound = await loadSavedAdhanSound();
  final savedFiqhSchool = await loadSavedFiqhSchool();
  final savedNotifFajr = await loadSavedPrayerNotif('fajr');
  final savedNotifDhuhr = await loadSavedPrayerNotif('dhuhr');
  final savedNotifAsr = await loadSavedPrayerNotif('asr');
  final savedNotifMaghrib = await loadSavedPrayerNotif('maghrib');
  final savedNotifIsha = await loadSavedPrayerNotif('isha');

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
        adhanSoundProvider.overrideWith((ref) => savedAdhanSound),
        fiqhSchoolProvider.overrideWith((ref) => savedFiqhSchool),
        prayerNotifFajrProvider.overrideWith((ref) => savedNotifFajr),
        prayerNotifDhuhrProvider.overrideWith((ref) => savedNotifDhuhr),
        prayerNotifAsrProvider.overrideWith((ref) => savedNotifAsr),
        prayerNotifMaghribProvider.overrideWith((ref) => savedNotifMaghrib),
        prayerNotifIshaProvider.overrideWith((ref) => savedNotifIsha),
      ],
      child: const TajaliApp(),
    ),
  );
}
