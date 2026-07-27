import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationMessages {
  static const List<_NotificationPair> morning = [
    _NotificationPair('Time to hydrate', 'Your body needs water!'),
    _NotificationPair('Drink up', 'Hey, your body needs water :\'('),
    _NotificationPair('Water break', 'Time to hydrate! Your cells are waiting'),
    _NotificationPair('Stay hydrated', 'Don\'t forget your water break'),
    _NotificationPair('Morning splash', 'Start your day with a glass of water'),
  ];

  static const List<_NotificationPair> evening = [
    _NotificationPair('Evening check-in', 'How is your hydration today?'),
    _NotificationPair('You\'re doing great', 'Keep that water flowing!'),
    _NotificationPair('Almost there', 'Finish the day strong - drink up!'),
    _NotificationPair('Hydration check', 'Don\'t let your water game slip this evening'),
    _NotificationPair('Wind down', 'Sip some water before you call it a night'),
  ];

  static ({String title, String body}) pickPair(List<_NotificationPair> list) {
    final pair = list[Random().nextInt(list.length)];
    return (title: pair.title, body: pair.body);
  }
}

class _NotificationPair {
  final String title;
  final String body;
  const _NotificationPair(this.title, this.body);
}

class NotificationService {
  final FlutterLocalNotificationsPlugin? _plugin = kIsWeb
      ? null
      : FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    try {
      tz_data.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final plugin = _plugin!;
      await plugin.initialize(settings, onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      });

      await plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
        const AndroidNotificationChannel(
          'hydration_reminder',
          'Hydration Reminders',
          description: 'Daily reminders to drink water',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      _initialized = true;
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb || _plugin == null) return;
    try {
      final plugin = _plugin;
      final android = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
      }
      final iosPlugin = plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  Future<void> scheduleDailyReminder({
    int hour = 9,
    int minute = 0,
    int id = 1,
  }) async {
    if (kIsWeb || _plugin == null) return;
    try {
      final plugin = _plugin;
      await plugin.cancel(id);

      final now = DateTime.now();
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final pair = NotificationMessages.pickPair(NotificationMessages.morning);
      await plugin.zonedSchedule(
        id,
        pair.title,
        pair.body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hydration_reminder',
            'Hydration Reminders',
            channelDescription: 'Daily reminders to drink water',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule morning error: $e');
    }
  }

  Future<void> scheduleMotivationalReminder({
    int hour = 18,
    int minute = 0,
    int id = 2,
  }) async {
    if (kIsWeb || _plugin == null) return;
    try {
      final plugin = _plugin;
      await plugin.cancel(id);

      final now = DateTime.now();
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final pair = NotificationMessages.pickPair(NotificationMessages.evening);
      await plugin.zonedSchedule(
        id,
        pair.title,
        pair.body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hydration_reminder',
            'Hydration Reminders',
            channelDescription: 'Daily reminders to drink water',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule evening error: $e');
    }
  }

  Future<void> sendTestNotification() async {
    if (kIsWeb || _plugin == null) return;
    try {
      final plugin = _plugin;
      await plugin.show(
        999,
        'Rain Drop is working!',
        'Notifications are set up and ready.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hydration_reminder',
            'Hydration Reminders',
            channelDescription: 'Daily reminders to drink water',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Test notification error: $e');
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb || _plugin == null) return;
    final plugin = _plugin;
    await plugin.cancelAll();
  }
}
