import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin;

  ReminderService(this._plugin);

  static const _channelId = 'calendar_reminders';
  static const _idBase =
      100000; // evita choques con otras notificaciones de Kaku
  static const _idLimit = 1100000;
  static const _maxScheduled = 60;

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
    required AppLocalizations l10n,
    required String locale,
    required CurrencyType currency,
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

    final date = DateFormatter.dayMonthYear(entry.date, locale);
    final amount = entry.amount;

    await _plugin.zonedSchedule(
      id: _idBase + entry.id,
      title: entry.title,
      body: amount != null
          ? l10n.calendarReminderBody(
              CurrencyFormatter.format(amount, currency),
              date,
            )
          : l10n.calendarReminderBodyNote(date),
      scheduledDate: when,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          l10n.calendarReminderChannel,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload:
          '/personal?tab=calendar&date=${entry.date.toIso8601String().substring(0, 10)}',
    );
  }

  /// Cancela todo lo del calendario y reprograma los próximos recordatorios
  Future<void> rescheduleAll({
    required List<CalendarEntry> upcoming,
    required AppLocalizations l10n,
    required String locale,
    required CurrencyType currency,
  }) async {
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (p.id >= _idBase && p.id < _idLimit) await _plugin.cancel(id: p.id);
    }
    for (final e in upcoming.take(_maxScheduled)) {
      await schedule(entry: e, l10n: l10n, locale: locale, currency: currency);
    }
  }

  Future<void> cancel(int entryId) => _plugin.cancel(id: _idBase + entryId);
}
