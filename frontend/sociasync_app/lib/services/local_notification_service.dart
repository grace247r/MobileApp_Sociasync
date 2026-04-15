import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Gunakan ID channel v5 (Reset total settingan di HP)
  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        'sociasync_v5_channel',
        'Schedule Reminder',
        channelDescription: 'Pengingat jadwal posting konten',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint("Timezone error: $e");
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(initSettings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    _initialized = true;
  }

  static Future<bool> canUseExactScheduling() async {
    if (!_initialized) await initialize();
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await androidImpl?.canScheduleExactNotifications() ?? false;
  }

  static Future<String> scheduleFromEvent({
    required int scheduleId,
    required String title,
    required String caption,
    required String platform,
    required DateTime startTime,
    required String reminderType,
    required bool isDaily,
  }) async {
    if (!_initialized) await initialize();

    final minutesBefore = _minutesBefore(reminderType);
    if (minutesBefore <= 0) {
      if (scheduleId > 0) await _plugin.cancel(scheduleId);
      return 'Reminder Dinonaktifkan (Never).';
    }

    // --- LOGIKA WAKTU ---
    final now = tz.TZDateTime.now(tz.local);
    var remindAt = tz.TZDateTime.from(
      startTime.subtract(Duration(minutes: minutesBefore)),
      tz.local,
    );

    String debugStatus = "";

    if (remindAt.isBefore(now)) {
      if (isDaily) {
        while (remindAt.isBefore(now)) {
          remindAt = remindAt.add(const Duration(days: 1));
        }
        debugStatus = "Daily: Digeser ke Besok";
      } else {
        await showTestNotification(
          title: 'Reminder: $title',
          body: 'Waktunya posting di ${platform.toUpperCase()}',
        );
        return 'WAKTU LEWAT! Notif dikirim instan.\nTarget: ${_formatTime(remindAt)}\nSekarang: ${_formatTime(now)}';
      }
    }

    final id = scheduleId > 0
        ? scheduleId
        : DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final canExact = await canUseExactScheduling();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _plugin.zonedSchedule(
        id,
        'Reminder: ${title.isEmpty ? "Sociasync" : title}',
        caption.isEmpty
            ? 'Waktunya posting di ${platform.toUpperCase()}'
            : caption,
        remindAt,
        const NotificationDetails(android: _androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: isDaily ? DateTimeComponents.time : null,
        payload: 'schedule:$id',
      );

      // Mengembalikan string detail untuk SnackBar
      return 'BERHASIL DIJADWALKAN!\n'
          'Target: ${_formatTime(remindAt)}\n'
          'Sekarang: ${_formatTime(now)}\n'
          'Izin Exact: ${canExact ? "OK" : "MATI"}\n'
          '${debugStatus}';
    } catch (e) {
      return 'GAGAL: $e';
    }
  }

  static int _minutesBefore(String reminderType) {
    final raw = reminderType.trim().toLowerCase();
    if (raw.contains('5')) return 5;
    if (raw.contains('10')) return 10;
    if (raw.contains('1 hour') || raw.contains('60')) return 60;
    return 0;
  }

  static String _formatTime(tz.TZDateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} (${dt.day}/${dt.month})";
  }

  static Future<void> showTestNotification({
    String title = 'Test Sociasync',
    String body = 'Jika muncul, berarti notifikasi dasar AKTIF.',
  }) async {
    if (!_initialized) await initialize();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(android: _androidDetails),
    );
  }

  static Future<void> scheduleReminderNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    if (scheduledDateTime.isBefore(now)) {
      // Jika waktu sudah lewat, kirim notif instan
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(android: _androidDetails),
      );
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final canExact = await canUseExactScheduling();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDateTime,
        const NotificationDetails(android: _androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: scheduleMode,
        payload: 'reminder:$id',
      );
    } catch (e) {
      debugPrint('Error scheduling reminder notification: $e');
    }
  }
}
