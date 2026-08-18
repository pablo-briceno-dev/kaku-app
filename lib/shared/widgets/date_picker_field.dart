import 'package:flutter/material.dart';
import 'package:kaku/core/date_formatter.dart';

enum DatePickerFieldMode { future, past, unrestricted }

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final String? label;
  final ValueChanged<DateTime> onChanged;
  final DatePickerFieldMode mode;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    this.label,
    this.mode = DatePickerFieldMode.unrestricted,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    late final DateTime firstDate;
    late final DateTime lastDate;

    switch (mode) {
      case DatePickerFieldMode.future:
        // Hoy o cualquier fecha posterior
        firstDate = today;
        lastDate = DateTime(now.year + 5, now.month, now.day);
        break;
      case DatePickerFieldMode.past:
        // Hoy o cualquier fecha anterior
        firstDate = DateTime(now.year - 5, now.month, now.day);
        lastDate = today;
        break;
      case DatePickerFieldMode.unrestricted:
        // Hoy o cualquier fecha
        firstDate = DateTime(now.year - 5, now.month, now.day);
        lastDate = DateTime(now.year + 5, now.month, now.day);
        break;
    }

    final initialDate = selectedDate.isBefore(firstDate)
        ? firstDate
        : selectedDate.isAfter(lastDate)
        ? lastDate
        : DateUtils.dateOnly(selectedDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      //! Usar el idioma local del dispositivo cuando se implemente
      locale: const Locale('es'),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) => child!,
    );

    if (picked != null) {
      onChanged(
        DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDate.hour,
          selectedDate.minute,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label != null &&
                      DateFormatter.isSameDay(selectedDate, DateTime.now())
                  ? label!
                  : DateFormatter.relative(selectedDate),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
