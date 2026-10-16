import 'package:flutter/material.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/shared/widgets/month_year_picker_sheet.dart';

class MonthNavigator extends StatelessWidget {
  final ({int year, int month}) selectedMonth;
  final bool isCurrentMonth;
  final bool isViewLabelMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime>? onMonthSelected;
  final DateTime? firstMonth;
  final bool compact;

  const MonthNavigator({
    super.key,
    required this.selectedMonth,
    required this.isCurrentMonth,
    this.isViewLabelMonth = true,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onMonthSelected,
    this.firstMonth,
    this.compact = false,
  });

  Future<void> _openMonthPicker(BuildContext context) async {
    final picked = await MonthYearPickerSheet.show(
      context,
      initialYear: selectedMonth.year,
      initialMonth: selectedMonth.month,
      firstYear: 2000,
    );
    if (picked != null) onMonthSelected?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canOpenPicker = onMonthSelected != null;

    final monthLabel = compact
        ? context.dates.monthLabelShort(selectedMonth.year, selectedMonth.month)
        : context.dates.monthYearLabel(selectedMonth.year, selectedMonth.month);
    final displayLabel = capitalize(monthLabel);

    final prevBtn = IconButton(
      onPressed: onPreviousMonth,
      icon: const Icon(Icons.chevron_left),
      iconSize: compact ? 20 : null,
      padding: compact ? EdgeInsets.zero : null,
      visualDensity: compact ? VisualDensity.compact : null,
      constraints: compact
          ? const BoxConstraints(minWidth: 32, minHeight: 32)
          : null,
      tooltip: null,
    );

    final nextBtn = IconButton(
      onPressed: isCurrentMonth ? null : onNextMonth,
      icon: const Icon(Icons.chevron_right),
      iconSize: compact ? 20 : null,
      padding: compact ? EdgeInsets.zero : null,
      visualDensity: compact ? VisualDensity.compact : null,
      constraints: compact
          ? const BoxConstraints(minWidth: 32, minHeight: 32)
          : null,
      tooltip: null,
    );

    final centerWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canOpenPicker ? () => _openMonthPicker(context) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? 4 : 8,
            horizontal: compact ? 6 : 4,
          ),
          child: isViewLabelMonth
              ? Text(
                  displayLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 13 : null,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                )
              : Icon(
                  Icons.calendar_month,
                  size: compact ? 20 : 24,
                  color: cs.onSurface,
                ),
        ),
      ),
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [prevBtn, centerWidget, nextBtn],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(flex: 1, child: prevBtn),
        Expanded(flex: 2, child: centerWidget),
        Expanded(flex: 1, child: nextBtn),
      ],
    );
  }

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }
}
