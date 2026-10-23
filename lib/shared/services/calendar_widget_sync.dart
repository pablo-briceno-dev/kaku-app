import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/calendar_provider.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/locale_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetPrefs {
  static const _key = 'widget_show_amounts';

  static Future<bool> showAmounts() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  static Future<void> setShowAmounts(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_key, v);
}

final calendarWidgetSyncProvider = Provider<CalendarWidgetSync>(
  CalendarWidgetSync.new,
);

/// Actualiza el widget solo cuando cambian entradas o transactiones,
/// el idioma o la moneda. Se activa con ref.watch en MyApp
final calendarWidgetAutoSyncProvider = Provider<void>((ref) {
  final db = ref.watch(databaseProvider);
  final sub = db
      .tableUpdates(
        TableUpdateQuery.onAllTables([
          db.calendarEntriesTable,
          db.transactionsTable,
        ]),
      )
      .debounceTime(const Duration(milliseconds: 600))
      .listen((_) => ref.read(calendarWidgetSyncProvider).push());
  ref.onDispose(sub.cancel);
  ref.listen(
    localeProvider,
    (_, _) => ref.read(calendarWidgetSyncProvider).push(),
  );
  ref.listen(
    currencyProvider,
    (_, _) => ref.read(calendarWidgetSyncProvider).push(),
  );
});

class CalendarWidgetSync {
  final Ref _ref;

  CalendarWidgetSync(this._ref);

  static const _qualifiedName = 'com.pablobricenodev.kaku.KakuCalendarWidget';
  static const _monthsBack = 2;
  static const _monthsAhead = 12;

  static String _2(int n) => n.toString().padLeft(2, '0');
  static String _day(DateTime d) => '${d.year}-${_2(d.month)}-${_2(d.day)}';
  static String _ym(DateTime d) => '${d.year}-${_2(d.month)}';

  Future<void> push() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month - _monthsBack);
      final end = DateTime(now.year, now.month + _monthsAhead + 1);

      final locale = effectiveLocale(_ref.read(localeProvider));
      final l10n = lookupAppLocalizations(locale);
      final currency = _ref.read(currencyProvider);
      final showAmounts = await WidgetPrefs.showAmounts();

      final entries = await _ref
          .read(calendarDaoProvider)
          .getEntriesInRange(start, end);
      final expenseDays = await _ref
          .read(transactionsDaoProvider)
          .getExpenseDaysInRange(start, end);

      final days = <String, Map<String, Object>>{};
      for (final d in expenseDays) {
        days.putIfAbsent(_day(d), () => {})['s'] = 1;
      }
      for (final e in entries) {
        final amount = e.amount;
        final kind = amount == null
            ? 'n'
            : switch (e.status) {
                'done' => 'd',
                'skipped' => 'x',
                _ => 'p',
              };
        final day = days.putIfAbsent(_day(e.date), () => {});
        (day.putIfAbsent('e', () => <Map<String, String>>[])
                as List<Map<String, String>>)
            .add({
              't': e.title,
              'a': showAmounts && amount != null
                  ? CurrencyFormatter.format(amount, currency)
                  : '',
              'k': kind,
            });
      }

      final firstDow =
          (DateFormat.yMd(locale.languageCode).dateSymbols.FIRSTDAYOFWEEK + 1) %
          7;

      await HomeWidget.saveWidgetData<String>(
        'calw_data',
        jsonEncode({
          'v': 1,
          'lang': locale.languageCode,
          'firstDow': firstDow,
          'min': _ym(start),
          'max': _ym(DateTime(now.year, now.month + _monthsAhead)),
          'empty': l10n.widgetCalendarNoEvents,
          'days': days,
        }),
      );
      await HomeWidget.updateWidget(qualifiedAndroidName: _qualifiedName);
    } catch (e, s) {
      debugPrint('Widget sync falló: $e\n$s');
    }
  }
}
