import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin;

  ReminderService(this._plugin);

  static const _channelId = 'calendar_reminders';
  static const _idBase =
      100000; // evita choques con otras notificaciones de Kaku

  static Future<void> initTimezone() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Programa el recordatorio de la entrada, o lo cancela si ya no aplica
  Future<void> schedule({
    required CalendarEntry entry,
    required String title,
    required String body,
    required String channelName,
  }) async {
    final remindAt = entry.remindAt;
    final when = remindAt == null
        ? null
        : tz.TZDateTime.from(remindAt, tz.local);
    if (when == null ||
        entry.status != EntryStatus.pending.name ||
        when.isBefore(tz.TZDateTime.now(tz.local))) {
      await cancel(entry.id);
      return;
    }

    await _plugin.zonedSchedule(
      id: _idBase + entry.id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '/personal?tab=calendar',
    );
  }

  Future<void> cancel(int entryId) => _plugin.cancel(id: _idBase + entryId);
}
