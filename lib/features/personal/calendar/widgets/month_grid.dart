import 'package:flutter/material.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/features/personal/calendar/widgets/day_cell.dart';

class DayMarkers {
  final bool spent, planned, note;

  const DayMarkers({
    this.spent = false,
    this.planned = false,
    this.note = false,
  });

  DayMarkers merge({
    bool spent = false,
    bool planned = false,
    bool note = false,
  }) => DayMarkers(
    spent: this.spent || spent,
    planned: this.planned || planned,
    note: this.note || note,
  );
}

class MonthGrid extends StatelessWidget {
  final DateTime month; // primer día del mes visible
  final DateTime selected; // día seleccionado, sin hora
  final Map<DateTime, DayMarkers> markers; // clave: día sin hora
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.markers,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  void _shift(int delta) =>
      onMonthChanged(DateTime(month.year, month.month + delta));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ml = MaterialLocalizations.of(context);
    final firstDow = ml.firstDayOfWeekIndex;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final offset =
        (DateTime(month.year, month.month).weekday % 7 - firstDow + 7) % 7;
    final rows = ((offset + daysInMonth) / 7).ceil();
    final today = DateUtils.dateOnly(DateTime.now());

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -300) _shift(1);
        if (v > 300) _shift(-1);
      },
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: ml.previousMonthTooltip,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shift(-1),
              ),
              Expanded(
                child: Text(
                  context.dates.monthYear(month.year, month.month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: ml.nextMonthTooltip,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shift(1),
              ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      context.dates.calendarDayLabel(
                        DateTime(2024, 1, 7 + firstDow + i),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var r = 0; r < rows; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: _cell(r * 7 + c - offset + 1, daysInMonth, today),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(int day, int daysInMonth, DateTime today) {
    if (day < 1 || day > daysInMonth) return const SizedBox(height: 48);
    final date = DateTime(month.year, month.month, day);
    return DayCell(
      date: date,
      isToday: date == today,
      isSelected: date == selected,
      markers: markers[date] ?? const DayMarkers(),
      onTap: () => onDaySelected(date),
    );
  }
}
