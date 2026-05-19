import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class MonthNavigator extends ConsumerStatefulWidget {
  const MonthNavigator({super.key});

  @override
  ConsumerState<MonthNavigator> createState() => _MonthNavigatorState();
}

class _MonthNavigatorState extends ConsumerState<MonthNavigator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);

    final isCurrentMonth = ref.watch(
      selectedMonthProvider.select(
        (m) => BudgetCalculator.isCurrentMonth(m.year, m.month),
      ),
    );
    final monthName = DateFormat(
      'MMMM yyyy',
      'es',
    ).format(DateTime(selectedMonth.year, selectedMonth.month));

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: IconButton(
            onPressed: () =>
                ref.read(selectedMonthProvider.notifier).toPrevious(),
            icon: const Icon(Icons.chevron_left),
          ),
        ),
        Expanded(
          child: Text(
            capitalize(monthName),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: IconButton(
            onPressed: isCurrentMonth
                ? null
                : () => ref.read(selectedMonthProvider.notifier).toNext(),
            icon: Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }
}
