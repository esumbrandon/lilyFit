import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _waterChannelId = 'water_reminders';
  static const String _waterChannelName = 'Water Reminders';
  static const String _waterChannelDesc =
      'Periodic reminders to drink water throughout the day';

  // IDs 1000–1047: up to 48 daily slots (30-min intervals over 24 h)
  static const int _waterBaseId = 1000;
  static const int _maxWaterSlots = 48;

  static bool _initialized = false;

  // ─── Initialization ────────────────────────────────────────────

  /// Call once at app start-up (before runApp).
  static Future<void> initialize() async {
    if (_initialized) return;

    // Build timezone database and resolve the device's local timezone.
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      // Fallback: keep UTC-based local – notifications will still fire, just
      // calculated from UTC offset rather than the named zone.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      // Permissions are requested lazily when the user enables reminders.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            _waterChannelId,
            _waterChannelName,
            description: _waterChannelDesc,
            importance: Importance.defaultImportance,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
    }

    _initialized = true;
  }

  // ─── Permission helpers ────────────────────────────────────────

  /// Ask the OS for notification permission.
  /// Returns [true] if the user granted (or already had) permission.
  static Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return true; // other platforms assumed granted
  }

  /// Returns whether notification permission is currently granted.
  static Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await impl?.areNotificationsEnabled() ?? false;
    }
    // On iOS granted status is checked implicitly by the system.
    return true;
  }

  // ─── Scheduling ────────────────────────────────────────────────

  /// Schedule daily water-reminder notifications within the given time window.
  ///
  /// Each slot fires at the same wall-clock time every day. All previous water
  /// reminders are cancelled before new ones are created.
  static Future<void> scheduleWaterReminders({
    required int intervalMinutes,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    await cancelWaterReminders();

    // Guard: interval must be positive to avoid an infinite loop.
    if (intervalMinutes <= 0) return;

    const androidDetails = AndroidNotificationDetails(
      _waterChannelId,
      _waterChannelName,
      channelDescription: _waterChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      // Use the app launcher icon; replace with a dedicated water icon if
      // you add one to the drawables later.
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    int slotIndex = 0;
    int currentMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    while (currentMinutes <= endMinutes && slotIndex < _maxWaterSlots) {
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;

      await _plugin.zonedSchedule(
        _waterBaseId + slotIndex,
        notificationTitle,
        notificationBody,
        _nextInstanceOfTime(hour, minute),
        details,
        // Inexact alarms work without the SCHEDULE_EXACT_ALARM permission
        // on Android 12+ while still delivering within ~15 minutes of the
        // target time. For a hydration reminder this is perfectly fine.
        androidScheduleMode: AndroidScheduleMode.inexact,
        // Repeat daily at this wall-clock time.
        matchDateTimeComponents: DateTimeComponents.time,
        // iOS: interpret the scheduled date as wall-clock (absolute) time.
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      currentMinutes += intervalMinutes;
      slotIndex++;
    }
  }

  /// Cancel every scheduled water reminder.
  static Future<void> cancelWaterReminders() async {
    for (int i = 0; i < _maxWaterSlots; i++) {
      await _plugin.cancel(_waterBaseId + i);
    }
  }

  // ─── Private helpers ───────────────────────────────────────────

  /// Returns the next occurrence of [hour]:[minute] in the device's local
  /// timezone. If that time has already passed today, tomorrow is returned.
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
