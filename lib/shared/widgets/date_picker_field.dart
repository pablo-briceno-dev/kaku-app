import 'package:flutter/material.dart';
import 'package:kaku/core/date_formatter.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final String? label;
  final ValueChanged<DateTime> onChanged;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    this.label,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      // locale: const Locale('es'),
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
