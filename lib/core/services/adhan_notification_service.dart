import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Notification IDs reserved for prayer events (today: 100–106, tomorrow: 110–116).
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

// Sound file names per source (without extension — used for raw resource on Android)
const _kSoundFiles = {
  'makkah': (fajr: 'adhan_fajr',         regular: 'adhan_regular'),
  'egypt':  (fajr: 'adhan_egypt_fajr',   regular: 'adhan_egypt_regular'),
};

enum AdhanNotificationMode { fullSound, silent, disabled }

enum AdhanSoundSource { makkah, egypt }

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
  ///
  /// [dayOffset] shifts the notification IDs by `dayOffset * 10` so today's
  /// prayers use IDs 100–106 and tomorrow's use 110–116.
  /// Skips nulls and past times automatically.
  static List<PrayerEntry> buildEntries({
    required DateTime? fajr,
    required DateTime? sunrise,
    required DateTime? dhuhr,
    required DateTime? asr,
    required DateTime? maghrib,
    required DateTime? isha,
    DateTime? qiyam,
    int dayOffset = 0,
  }) {
    final now = DateTime.now();
    final idOffset = dayOffset * 10;
    final raw = [
      (id: _kFajrId    + idOffset, nameAr: 'الفجر',      dt: fajr),
      (id: _kSunriseId + idOffset, nameAr: 'الشروق',     dt: sunrise),
      (id: _kDhuhrId   + idOffset, nameAr: 'الظهر',      dt: dhuhr),
      (id: _kAsrId     + idOffset, nameAr: 'العصر',      dt: asr),
      (id: _kMaghribId + idOffset, nameAr: 'المغرب',     dt: maghrib),
      (id: _kIshaId    + idOffset, nameAr: 'العشاء',     dt: isha),
      (id: _kQiyamId   + idOffset, nameAr: 'قيام الليل', dt: qiyam),
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
    AdhanNotificationMode mode, {
    AdhanSoundSource source = AdhanSoundSource.makkah,
  }) async {
    await cancelAll();
    if (mode == AdhanNotificationMode.disabled) return;

    for (final e in entries) {
      await _schedule(id: e.id, nameAr: e.nameAr, dt: e.dt, mode: mode, source: source);
    }
  }

  /// Fire a test notification in [delaySeconds] seconds (default 10).
  static Future<void> testNow({
    int delaySeconds = 10,
    bool isFajr = false,
    AdhanSoundSource source = AdhanSoundSource.makkah,
  }) async {
    final dt = DateTime.now().add(Duration(seconds: delaySeconds));
    await _schedule(
      id: isFajr ? _kFajrId : _kDhuhrId,
      nameAr: isFajr ? 'الفجر' : 'الظهر',
      dt: dt,
      mode: AdhanNotificationMode.fullSound,
      source: source,
    );
  }

  /// Cancel all prayer notifications — both today's (100–106) and tomorrow's (110–116).
  static Future<void> cancelAll() async {
    for (final id in [
      _kFajrId, _kSunriseId, _kDhuhrId, _kAsrId,
      _kMaghribId, _kIshaId, _kQiyamId,
      _kFajrId + 10, _kSunriseId + 10, _kDhuhrId + 10, _kAsrId + 10,
      _kMaghribId + 10, _kIshaId + 10, _kQiyamId + 10,
    ]) {
      await _plugin.cancel(id);
    }
  }

  /// Cancel a single prayer's notification for both today and tomorrow.
  static Future<void> cancelPrayer(int todayId) async {
    await _plugin.cancel(todayId);
    await _plugin.cancel(todayId + 10);
  }

  static Future<void> _schedule({
    required int id,
    required String nameAr,
    required DateTime dt,
    required AdhanNotificationMode mode,
    AdhanSoundSource source = AdhanSoundSource.makkah,
  }) async {
    final tzDt = tz.TZDateTime.from(dt, tz.local);
    // Fajr IDs are 100 and 110 (tomorrow offset).
    final isFajr = (id % 10) == (_kFajrId % 10) && id < 200;
    final key = source == AdhanSoundSource.egypt ? 'egypt' : 'makkah';
    final soundFile = isFajr ? _kSoundFiles[key]!.fajr : _kSoundFiles[key]!.regular;
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
