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

  static const int _waterBaseId = 1000;
  static const int _maxWaterSlots = 48;

  static bool _initialized = false;

  // ─── Initialization ────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {}

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

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
    return true;
  }

  static Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await impl?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  // ─── Scheduling ────────────────────────────────────────────────

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

    if (intervalMinutes <= 0) return;

    const androidDetails = AndroidNotificationDetails(
      _waterChannelId,
      _waterChannelName,
      channelDescription: _waterChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
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

        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      currentMinutes += intervalMinutes;
      slotIndex++;
    }
  }

  static Future<void> cancelWaterReminders() async {
    for (int i = 0; i < _maxWaterSlots; i++) {
      await _plugin.cancel(_waterBaseId + i);
    }
  }

  // ─── Private helpers ───────────────────────────────────────────

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
