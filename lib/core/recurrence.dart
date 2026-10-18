enum Recurrence { none, weekly, monthly }

DateTime _nth(DateTime first, Recurrence r, int i) {
  if (r == Recurrence.weekly) {
    return DateTime(first.year, first.month, first.day + i * 7);
  }
  // Mensual: el día 31 cae el último día de los meses más cortos
  final lastDay = DateTime(first.year, first.month + i + 1, 0).day;
  return DateTime(
    first.year,
    first.month + 1,
    first.day > lastDay ? lastDay : first.day,
  );
}

/// Fechas de la serie desde [start] hasta [until], ambas inclusive
List<DateTime> recurrenceDates(DateTime start, Recurrence r, DateTime until) {
  final first = DateTime(start.year, start.month, start.day);
  if (r == Recurrence.none) return [first];
  final dates = <DateTime>[];
  for (var i = 0; ; i++) {
    final d = _nth(first, r, i);
    if (d.isAfter(until)) break;
    dates.add(d);
  }

  return dates;
}

/// Mantiene el mismo "N días antes" y la misma hora en cada ocurrencia
DateTime? shiftReminder(
  DateTime baseDate,
  DateTime? baseRemindAt,
  DateTime newDate,
) {
  final r = baseRemindAt;
  if (r == null) return null;
  final daysBefore = DateTime.utc(
    baseDate.year,
    baseDate.month,
    baseDate.day,
  ).difference(DateTime.utc(r.year, r.month, r.day)).inDays;
  return DateTime(
    newDate.year,
    newDate.month,
    newDate.day - daysBefore,
    r.hour,
    r.minute,
  );
}
