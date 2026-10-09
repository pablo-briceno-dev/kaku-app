import 'package:intl/intl.dart';

class DateFormatter {
  // Cache de formatters por "patrón|locale" - evita recrearlos en cada llamada
  static final Map<String, DateFormat> _formatters = {};

  static DateFormat _skeleton(
    DateFormat Function(String locale) builder,
    String localeCode,
    String cacheKey,
  ) => _formatters.putIfAbsent(
    '$cacheKey|$localeCode',
    () => builder(localeCode),
  );

  /// "20 de mayo" (es) / "May 20" (en)
  static String dayMonth(DateTime date, String localeCode) {
    final f = _skeleton(DateFormat.MMMMd, localeCode, 'dayMonth');
    return f.format(date);
  }

  /// "20 de mayo de 2026" (es) / "May 20, 2026" (en)
  static String dayMonthYear(DateTime date, String localeCode) {
    final f = _skeleton(DateFormat.yMMMMd, localeCode, 'dayMonthYear');
    return f.format(date);
  }

  /// "mayo 2026" (es) / "May 2026" (en)
  static String monthYear(int year, int month, String localeCode) {
    final f = _skeleton(DateFormat.yMMMM, localeCode, 'monthYear');
    final raw = f.format(DateTime(year, month));
    // La mayúscula inicial solo hace falta en español (el inglés ya la trae)
    return localeCode == 'es' ? raw[0].toUpperCase() + raw.substring(1) : raw;
  }

  /// "20 may" (es) / "May 20" (en)
  static String shortDate(DateTime date, String localeCode) {
    final f = _skeleton(DateFormat.MMMd, localeCode, 'shortDate');
    return f.format(date);
  }

  /// "3:45 PM" — formato de hora según el locale (algunos usan 24h por defecto)
  static String time(DateTime date, String localeCode) {
    final f = _skeleton(DateFormat.jm, localeCode, 'time');
    return f.format(date);
  }

  /// Fecha y hora completas
  static String fullDateTime(DateTime date, String localeCode) {
    final datePart = dayMonthYear(date, localeCode);
    final timePart = time(date, localeCode);
    return '$datePart, $timePart';
  }

  /// "20-may-2026" — usado para nombres de archivo, no se traduce al usuario
  static String abbrMonthDayYear(DateTime date, String localeCode) {
    final f = _skeleton(DateFormat.yMMMd, localeCode, 'abbr');
    return f.format(date).replaceAll('/', '-'); // normaliza separador
  }

  static String fileFriendlyDate(DateTime date, String localeCode) {
    return abbrMonthDayYear(date, localeCode).replaceAll(' ', '_');
  }

  /// Relativo: necesita las palabras "Hoy"/"Ayer" traducidas
  static String relative(
    DateTime date,
    String localeCode, {
    required String todayLabel,
    required String yesterdayLabel,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return todayLabel;
    if (diff == 1) return yesterdayLabel;
    if (date.year == now.year) return dayMonth(date, localeCode);

    return dayMonthYear(date, localeCode);
  }

  /// Relativo: necesita las palabras "Hoy"/"Ayer" traducidas y cortas
  static String relativeShort(
    DateTime date,
    String localeCode, {
    required String todayLabel,
    required String yesterdayLabel,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return todayLabel;
    if (diff == 1) return yesterdayLabel;

    final short = shortDate(date, localeCode);
    if (date.year != now.year) return '$short ${date.year}';
    return short;
  }

  /// Mes corto (3 letras) "Ene"/"Feb"/"Mar"
  static String monthLabelShort(int year, int month, String localeCode) {
    final f = _skeleton(DateFormat.MMM, localeCode, 'monthLabelShort');
    return f.format(DateTime(year, month));
  }

  /// Mes y año (es) "Enero 2026" / "January 2026" (en)
  static String monthYearLabel(int year, int month, String localeCode) {
    final f = _skeleton(DateFormat.yMMMM, localeCode, 'monthYearLabel');
    return f.format(DateTime(year, month));
  }

  /// Estos no cambian — no dependen del idioma
  static String groupKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// "20/05/2026" - usado para la presentación de fechas personalizadas
  static String rangeCustomDate(DateTime date, String localeCode) {
    final f = _skeleton(
      ((locale) => DateFormat('dd/MM/yyyy', locale)),
      localeCode,
      'rangeCustom',
    );
    return f.format(date);
  }
}
