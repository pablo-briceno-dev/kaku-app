import 'package:flutter/material.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/l10n/app_localizations.dart';

class MonthYearPickerSheet extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int firstYear;
  final int? lastYear;
  final int? lastMonth;

  const MonthYearPickerSheet({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.firstYear,
    this.lastYear,
    this.lastMonth,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required int initialYear,
    required int initialMonth,
    int firstYear = 2000,
  }) {
    final now = DateTime.now();
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthYearPickerSheet(
        initialYear: initialYear,
        initialMonth: initialMonth,
        firstYear: firstYear,
        lastYear: now.year,
        lastMonth: now.month,
      ),
    );
  }

  @override
  State<MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<MonthYearPickerSheet> {
  late int _selectedMonth;
  late int _selectedYear;
  late final List<int> _years;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;

    final lastYear = widget.lastYear ?? DateTime.now().year;
    _years = List.generate(
      lastYear - widget.firstYear + 1,
      (i) => widget.firstYear + i,
    );

    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );

    final yearIndex = _years.indexOf(_selectedYear);
    _yearController = FixedExtentScrollController(
      initialItem: yearIndex >= 0 ? yearIndex : _years.length - 1,
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  /// Verifica si un mes esta "bloqueado" porque está en el futuro
  bool _isFuture(int year, int month) {
    final now = DateTime.now();
    if (year > now.year) return true;
    if (year == now.year && month > now.month) return true;
    return false;
  }

  void _onConfirm() {
    // si el usuario intenta confirmar un mes futuro, lo corregimos
    if (_isFuture(_selectedYear, _selectedMonth)) {
      final now = DateTime.now();
      _selectedYear = now.year;
      _selectedMonth = now.month;
    }
    Navigator.pop(context, DateTime(_selectedYear, _selectedMonth, 1));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                l10n.selectMonthYear,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),

            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ListWheelScrollView.useDelegate(
                      controller: _monthController,
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.4,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (i) {
                        setState(() => _selectedMonth = i + 1);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == _selectedMonth;
                          final isBlocked = _isFuture(_selectedYear, month);
                          return Center(
                            child: Text(
                              context.dates.monthOnlyCapitalized(
                                month,
                                _selectedYear,
                              ),
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 17,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isBlocked
                                    ? cs.onSurface.withValues(alpha: 0.25)
                                    : isSelected
                                    ? cs.primary
                                    : cs.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Año ──
                  Expanded(
                    flex: 2,
                    child: ListWheelScrollView.useDelegate(
                      controller: _yearController,
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.4,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (i) {
                        setState(() => _selectedYear = _years[i]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _years.length,
                        builder: (context, index) {
                          final year = _years[index];
                          final isSelected = year == _selectedYear;
                          return Center(
                            child: Text(
                              '$year',
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 17,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected ? cs.primary : cs.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botones
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.btnCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _onConfirm,
                      child: Text(l10n.btnConfirm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
