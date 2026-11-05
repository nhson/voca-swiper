import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/reminders/reminder_planner.dart';

/// Puts planned reminders on the device's notification schedule.
abstract class ReminderNotifier {
  /// Asks the OS for permission to show notifications.
  Future<bool> requestPermission();

  /// Replaces every scheduled reminder with [plan].
  Future<void> replace(List<PlannedReminder> plan);
}

class LocalReminderNotifier implements ReminderNotifier {
  LocalReminderNotifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  static const _baseId = 100;
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminder',
      'Daily reminder',
      channelDescription: 'One friendly nudge a day when words are due',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
    ),
  );

  Future<void> _init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Asked only when a parent turns reminders on.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await (_ready ??= _init());
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          ) ??
          false;
    } catch (e) {
      debugPrint('notification permission failed: $e');
      return false;
    }
  }

  @override
  Future<void> replace(List<PlannedReminder> plan) async {
    try {
      await (_ready ??= _init());
      await _plugin.cancelAll();
      for (final (i, r) in plan.indexed) {
        await _plugin.zonedSchedule(
          id: _baseId + i,
          // An absolute instant: local wall time was resolved by the planner.
          scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
          notificationDetails: _details,
          // Inexact: no exact-alarm permission; a few minutes late is fine.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: r.title,
          body: r.body,
        );
      }
    } catch (e) {
      // Reminders are a nice-to-have; never break the app over them.
      debugPrint('scheduling reminders failed: $e');
    }
  }
}

final reminderNotifierProvider = Provider<ReminderNotifier>(
  (ref) => LocalReminderNotifier(),
);
