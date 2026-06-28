import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Notification IDs reserved for prayer events.
const _kFajrId    = 100;
const _kSunriseId = 101;
const _kDhuhrId   = 102;
const _kAsrId     = 103;
const _kMaghribId = 104;
const _kIshaId    = 105;
const _kQiyamId   = 106;

const _kFajrChannelId    = 'adhan_fajr_channel';
const _kChannelId        = 'adhan_channel';
const _kChannelName      = 'أذان الصلاة';
const _kSilentChannelId  = 'adhan_silent_channel';
const _kFajrSoundFile    = 'adhan_fajr';    // res/raw/adhan_fajr.mp3
const _kRegularSoundFile = 'adhan_regular'; // res/raw/adhan_regular.mp3

enum AdhanNotificationMode { fullSound, silent, disabled }

/// A single prayer slot to schedule.
typedef PrayerEntry = ({int id, String nameAr, DateTime dt});

class AdhanNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Request notification permission (call after onboarding grant).
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;
    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  /// Build prayer entries from raw DateTime values.
  /// Skips nulls and past times automatically.
  static List<PrayerEntry> buildEntries({
    required DateTime? fajr,
    required DateTime? sunrise,
    required DateTime? dhuhr,
    required DateTime? asr,
    required DateTime? maghrib,
    required DateTime? isha,
    DateTime? qiyam,
  }) {
    final now = DateTime.now();
    final raw = [
      (id: _kFajrId,    nameAr: 'الفجر',         dt: fajr),
      (id: _kSunriseId, nameAr: 'الشروق',         dt: sunrise),
      (id: _kDhuhrId,   nameAr: 'الظهر',          dt: dhuhr),
      (id: _kAsrId,     nameAr: 'العصر',          dt: asr),
      (id: _kMaghribId, nameAr: 'المغرب',         dt: maghrib),
      (id: _kIshaId,    nameAr: 'العشاء',         dt: isha),
      (id: _kQiyamId,   nameAr: 'قيام الليل',    dt: qiyam),
    ];
    return [
      for (final p in raw)
        if (p.dt != null && p.dt!.isAfter(now))
          (id: p.id, nameAr: p.nameAr, dt: p.dt!),
    ];
  }

  /// Cancel then reschedule notifications based on the current mode.
  static Future<void> schedulePrayerNotifications(
    List<PrayerEntry> entries,
    AdhanNotificationMode mode,
  ) async {
    await cancelAll();
    if (mode == AdhanNotificationMode.disabled) return;

    for (final e in entries) {
      await _schedule(id: e.id, nameAr: e.nameAr, dt: e.dt, mode: mode);
    }
  }

  /// Fire a test notification in [delaySeconds] seconds (default 5).
  static Future<void> testNow({int delaySeconds = 5, bool isFajr = false}) async {
    final dt = DateTime.now().add(Duration(seconds: delaySeconds));
    await _schedule(
      id: 999,
      nameAr: isFajr ? 'الفجر' : 'الظهر',
      dt: dt,
      mode: AdhanNotificationMode.fullSound,
    );
  }

  static Future<void> cancelAll() async {
    for (final id in [
      _kFajrId, _kSunriseId, _kDhuhrId, _kAsrId,
      _kMaghribId, _kIshaId, _kQiyamId,
    ]) {
      await _plugin.cancel(id);
    }
  }

  static Future<void> _schedule({
    required int id,
    required String nameAr,
    required DateTime dt,
    required AdhanNotificationMode mode,
  }) async {
    final tzDt = tz.TZDateTime.from(dt, tz.local);
    final isFajr = id == _kFajrId;
    final soundFile = isFajr ? _kFajrSoundFile : _kRegularSoundFile;
    final channelId = isFajr ? _kFajrChannelId : _kChannelId;

    final androidDetails = mode == AdhanNotificationMode.fullSound
        ? AndroidNotificationDetails(
            channelId,
            _kChannelName,
            channelDescription: 'إشعارات أوقات الصلاة مع صوت الأذان',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound(soundFile),
            playSound: true,
            enableVibration: true,
          )
        : const AndroidNotificationDetails(
            _kSilentChannelId,
            'إشعار الصلاة (صامت)',
            channelDescription: 'إشعارات أوقات الصلاة بدون صوت',
            importance: Importance.high,
            priority: Priority.high,
            playSound: false,
            enableVibration: true,
          );

    final iosDetails = mode == AdhanNotificationMode.fullSound
        ? DarwinNotificationDetails(
            sound: '$soundFile.mp3',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          )
        : const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          );

    await _plugin.zonedSchedule(
      id,
      'حان وقت $nameAr',
      'تجلّي',
      tzDt,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
