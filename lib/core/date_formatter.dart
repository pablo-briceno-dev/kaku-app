import 'package:intl/intl.dart';

class DateFormatter {
  // Formateadores reutilizables (instanciarlos es costoso)
  static final _dayMonth = DateFormat('d \'de\' MMMM', 'es');
  static final _dayMonthYear = DateFormat('d \'de\' MMMM \'de\' y', 'es');
  static final _monthYear = DateFormat('MMMM y', 'es'); // "mayo 2026"
  static final _shortDate = DateFormat('d MMM', 'es'); // "20 may"
  static final _time = DateFormat('h:mm a', 'es'); // "3:45 PM"
  static final _fullDateTime = DateFormat("d 'de' MMMM 'de' y, h:mm a", 'es');
  static final _abbrMonthDayYear = DateFormat('d-MMM-y', 'es'); // "20-may-26"

  // "Hoy", "Ayer" o la fecha completa
  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);

    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (date.year == now.year) return _dayMonth.format(date);

    return _dayMonthYear.format(date);
  }

  // Versión compacta para espacios reducidos
  static String relativeShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);

    final diff = today.difference(day).inDays;

    if (diff == 0) return 'hoy';
    if (diff == 1) return 'ayer';

    final short = _shortDate.format(date);
    if (date.year != now.year) return '$short ${date.year}';

    return short;
  }

  // Día y Mes sin año
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  // Mes y año para el selector del Dashboard
  static String monthYear(int year, int month) {
    final raw = _monthYear.format(DateTime(year, month));
    return raw[0].toUpperCase() + raw.substring(1);
  }

  // Solo la hora
  static String time(DateTime date) => _time.format(date);

  // Fecha y hora completas
  static String fullDateTime(DateTime date) => _fullDateTime.format(date);

  // Clave para agrupar transacciones por día
  static String groupKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // Compara dos fechas ignorando la hora
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Devuelve la fecha en formato "20-Ago-2026" (mes abreviado en español)
  static String abbrMonthDayYear(DateTime date) => _abbrMonthDayYear.format(date);

  /// Versión segura para nombres de archivo (sin espacios ni caracteres especiales)
  static String fileFriendlyDate(DateTime date) {
    // Usamos el mismo formato pero reemplazamos espacios por "_" (aunque no los tiene)
    // y aseguramos que sea válido para nombres de archivo
    return abbrMonthDayYear(date).replaceAll(' ', '_');
  }
}
