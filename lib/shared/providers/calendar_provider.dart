import 'dart:ui' show Locale, PlatformDispatcher;
import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/locale_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/notification_service.dart';
import 'package:kaku/shared/services/reminder_service.dart';

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService(FlutterLocalNotificationsPlugin()),
);

final calendarControllerProvider = Provider<CalendarController>(
  CalendarController.new,
);

/// Lo llama AddTransactionScreen al guardar el gasto que viene de una entrada
Future<void> completeEntry(
  WidgetRef ref,
  int entryId,
  int transactionId,
) async {
  await ref
      .read(calendarDaoProvider)
      .setStatus(entryId, EntryStatus.done, transactionId: transactionId);
  await ref.read(reminderServiceProvider).cancel(entryId);
}

Locale effectiveLocale(Locale? chosen) {
  if (chosen != null) return chosen;
  final system = PlatformDispatcher.instance.locale;
  final supported = AppLocalizations.supportedLocales;
  return supported.firstWhere(
    (l) => l.languageCode == system.languageCode,
    orElse: () => supported.first,
  );
}

class CalendarController {
  final Ref _ref;

  CalendarController(this._ref);

  // Se ejecutan de una en una para que no se pisen
  Future<void> _queue = Future.value();

  // [chosen] es el idioma elegido en Configuration (null = el del dispositivo)
  Future<void> rescheduleAll(Locale? chosen) {
    _queue = _queue.then((_) => _rescheduleAll(chosen)).onError((_, _) {});
    return _queue;
  }

  Future<void> _rescheduleAll(Locale? chosen) async {
    final dao = _ref.read(calendarDaoProvider);
    final service = _ref.read(reminderServiceProvider);
    final currency = _ref.read(currencyProvider);
    if (!await NotificationService.hasPermission()) return;

    final locale = effectiveLocale(chosen);
    await service.rescheduleAll(
      upcoming: await dao.getUpcomingReminders(),
      l10n: lookupAppLocalizations(locale),
      locale: locale.languageCode,
      currency: currency,
    );
  }

  Future<void> deleteSeriesFrom(CalendarEntry entry) async {
    await _ref.read(calendarDaoProvider).deleteSeriesFrom(entry);
    await rescheduleAll(_ref.read(localeProvider));
  }

  /// Al abrir la app: completa las series recurrentes y reprograma
  Future<void> startupSync() async {
    try {
      await _ref.read(calendarDaoProvider).extendSeries();
      await rescheduleAll(_ref.read(localeProvider));
    } catch (e, s) {
      developer.log('startupSync falló: $e\n$s');
    }
  }
}
