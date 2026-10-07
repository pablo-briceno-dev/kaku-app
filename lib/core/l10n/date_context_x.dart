import 'package:flutter/material.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/l10n/app_localizations.dart';

class ContextDates {
  final BuildContext _context;
  final String _localeCode;
  final AppLocalizations _l10n;

  ContextDates(this._context)
    : _localeCode = Localizations.localeOf(_context).languageCode,
      _l10n = AppLocalizations.of(_context)!;

  String dayMonth(DateTime date) => DateFormatter.dayMonth(date, _localeCode);

  String dayMonthYear(DateTime date) =>
      DateFormatter.dayMonthYear(date, _localeCode);

  String monthYear(int year, int month) =>
      DateFormatter.monthYear(year, month, _localeCode);

  String shortDate(DateTime date) => DateFormatter.shortDate(date, _localeCode);

  String time(DateTime date) => DateFormatter.time(date, _localeCode);

  String fullDateTime(DateTime date) =>
      DateFormatter.fullDateTime(date, _localeCode);

  String abbrMonthDayYear(DateTime date) =>
      DateFormatter.abbrMonthDayYear(date, _localeCode);

  String fileFriendlyDate(DateTime date) =>
      DateFormatter.fileFriendlyDate(date, _localeCode);

  String relative(DateTime date) => DateFormatter.relative(
    date,
    _localeCode,
    todayLabel: _l10n.today,
    yesterdayLabel: _l10n.yesterday,
  );

  String relativeShort(DateTime date) => DateFormatter.relativeShort(
    date,
    _localeCode,
    todayLabel: _l10n.today,
    yesterdayLabel: _l10n.yesterday,
  );

  String monthLabelShort(int year, int month) =>
      DateFormatter.monthLabelShort(year, month, _localeCode);
}

extension DateContextX on BuildContext {
  ContextDates get dates => ContextDates(this);
}
