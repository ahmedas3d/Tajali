import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Notification IDs 100-105 reserved for the 5 fard prayers + sunrise.
const _kFajrId    = 100;
const _kSunriseId = 101;
const _kDhuhrId   = 102;
const _kAsrId     = 103;
const _kMaghribId = 104;
const _kIshaId    = 105;

const _kChannelId   = 'adhan_channel';
const _kChannelName = 'أذان الصلاة';
const _kSoundFile   = 'adhan'; // android/app/src/main/res/raw/adhan.wav

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

  /// Build the standard list of prayer entries from raw DateTime values.
  /// Pass only the 5 fard prayers + sunrise; skip nulls and past times.
  static List<PrayerEntry> buildEntries({
    required DateTime? fajr,
    required DateTime? sunrise,
    required DateTime? dhuhr,
    required DateTime? asr,
    required DateTime? maghrib,
    required DateTime? isha,
  }) {
    final now = DateTime.now();
    final raw = [
      (id: _kFajrId,    nameAr: 'الفجر',  dt: fajr),
      (id: _kSunriseId, nameAr: 'الشروق', dt: sunrise),
      (id: _kDhuhrId,   nameAr: 'الظهر',  dt: dhuhr),
      (id: _kAsrId,     nameAr: 'العصر',  dt: asr),
      (id: _kMaghribId, nameAr: 'المغرب', dt: maghrib),
      (id: _kIshaId,    nameAr: 'العشاء', dt: isha),
    ];
    return [
      for (final p in raw)
        if (p.dt != null && p.dt!.isAfter(now))
          (id: p.id, nameAr: p.nameAr, dt: p.dt!),
    ];
  }

  /// Cancel then reschedule adhan notifications for the given prayer list.
  static Future<void> schedulePrayerNotifications(
      List<PrayerEntry> entries) async {
    await cancelAll();
    for (final e in entries) {
      await _schedule(id: e.id, nameAr: e.nameAr, dt: e.dt);
    }
  }

  static Future<void> cancelAll() async {
    for (final id in [
      _kFajrId, _kSunriseId, _kDhuhrId, _kAsrId, _kMaghribId, _kIshaId,
    ]) {
      await _plugin.cancel(id);
    }
  }

  static Future<void> _schedule({
    required int id,
    required String nameAr,
    required DateTime dt,
  }) async {
    final tzDt = tz.TZDateTime.from(dt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: 'إشعارات أوقات الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(_kSoundFile),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      sound: '$_kSoundFile.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id,
      'حان وقت $nameAr',
      'تجلّي',
      tzDt,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
