import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/enums.dart';
import '../models/health_record.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'pet_health_alerts';
  static const _channelName = 'Pet Health Alerts';
  static const _channelDesc = 'Reminders for pet vaccinations and health';

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> schedule({
    required HealthRecord record,
    required String petName,
    required HealthRecordType type,
    required DateTime date,
    required AppLocalizations l,
  }) async {
    final typeName = type.label(l);
    final title = l.notifTitle(petName, typeName);
    final body = l.notifBodyNow(record.name);

    await _fire(
      id: record.notificationId.hashCode,
      title: title,
      body: body,
      date: date,
    );

    final reminder = date.subtract(const Duration(days: 3));
    if (reminder.isAfter(DateTime.now())) {
      await _fire(
        id: record.reminderNotificationId.hashCode,
        title: l.notifReminderTitle(petName),
        body: l.notifReminderBody(record.name),
        date: reminder,
      );
    }
  }

  Future<void> cancel(HealthRecord record) async {
    await _plugin.cancel(record.notificationId.hashCode);
    await _plugin.cancel(record.reminderNotificationId.hashCode);
  }

  Future<void> cancelAllForRecord(String recordId) async {
    await _plugin.cancel(recordId.hashCode);
    await _plugin.cancel('${recordId}_3d'.hashCode);
  }

  Future<void> _fire({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      9,
    );

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }
}
