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

  /// "20 de mayo" (es) / "May 20" (en)
  String dayMonth(DateTime date) => DateFormatter.dayMonth(date, _localeCode);

  /// "20 de mayo de 2026" (es) / "May 20, 2026" (en)
  String dayMonthYear(DateTime date) =>
      DateFormatter.dayMonthYear(date, _localeCode);

  /// "mayo 2026" (es) / "May 2026" (en)
  String monthYear(int year, int month) =>
      DateFormatter.monthYear(year, month, _localeCode);

  /// "20 may" (es) / "May 20" (en)
  String shortDate(DateTime date) => DateFormatter.shortDate(date, _localeCode);

  /// "3:45 PM" — formato de hora según el locale (algunos usan 24h por defecto)
  String time(DateTime date) => DateFormatter.time(date, _localeCode);

  /// Fecha y hora completas
  String fullDateTime(DateTime date) =>
      DateFormatter.fullDateTime(date, _localeCode);

  /// "20-may-2026" — usado para nombres de archivo, no se traduce al usuario
  String abbrMonthDayYear(DateTime date) =>
      DateFormatter.abbrMonthDayYear(date, _localeCode);

  String fileFriendlyDate(DateTime date) =>
      DateFormatter.fileFriendlyDate(date, _localeCode);

  /// Relativo: necesita las palabras "Hoy"/"Ayer" traducidas
  String relative(DateTime date) => DateFormatter.relative(
    date,
    _localeCode,
    todayLabel: _l10n.today,
    yesterdayLabel: _l10n.yesterday,
  );

  /// Relativo: necesita las palabras "Hoy"/"Ayer" traducidas y cortas
  String relativeShort(DateTime date) => DateFormatter.relativeShort(
    date,
    _localeCode,
    todayLabel: _l10n.today,
    yesterdayLabel: _l10n.yesterday,
  );

  /// Mes corto (3 letras) "Ene"/"Feb"/"Mar"
  String monthLabelShort(int year, int month) =>
      DateFormatter.monthLabelShort(year, month, _localeCode);

  /// Mes y año (es) "Enero 2026" / "January 2026" (en)
  String monthYearLabel(int year, int month) =>
      DateFormatter.monthYearLabel(year, month, _localeCode);

  /// "20/05/2026" - usado para la presentación de fechas personalizadas
  String rangeCustomDate(DateTime date) =>
      DateFormatter.rangeCustomDate(date, _localeCode);

  /// Solo el Mes "Enero" (es) / "January" (en)
  String justMonth(DateTime date) => DateFormatter.justMonth(date, _localeCode);
}

extension DateContextX on BuildContext {
  ContextDates get dates => ContextDates(this);
}
