import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/features/stats/widgets/locked_content.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

const _months = 6;
const _incomeColor = Color(0xFF27AE60);

class IncomeExpenseChart extends ConsumerWidget {
  final bool isPremium;

  const IncomeExpenseChart({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.statsIncomeExpenseTitle,
                overflow: TextOverflow.ellipsis,
                style: ts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              l10n.statsIncomeExpenseSubtitle(_months),
              style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!isPremium) LockedContent(child: _FlowBars(data: _sampleFlows())),
        if (isPremium) _PremiumContent(),
      ],
    );
  }
}

// Contenido real (solo premium) ===============================
class _PremiumContent extends ConsumerWidget {
  const _PremiumContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compact(locale: locale);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthlyFlowAsync = ref.watch(
      monthlyFlowProvider((
        months: _months,
        year: selectedMonth.year,
        month: selectedMonth.month,
      )),
    );

    return monthlyFlowAsync.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (flows) {
        final hasData = flows.any((f) => f.income > 0 || f.expense > 0);
        if (!hasData) {
          return SizedBox(
            height: 120,
            child: Center(child: Text(l10n.statsEmptyThisMonth)),
          );
        }

        final net = flows.fold<double>(0, (s, f) => s + f.net);

        return Column(
          children: [
            SizedBox(height: 200, child: _FlowBars(data: flows)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                  color: _incomeColor,
                  label: l10n.transactionTypeIncome(2),
                ),
                const SizedBox(width: 16),
                _LegendDot(
                  color: cs.error,
                  label: l10n.transactionTypeExpense(2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.statsIncomeExpenseNet(compact.format(net)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

List<MonthFlow> _sampleFlows() {
  final now = DateTime.now();
  const income = <double>[900, 950, 900, 1000, 980, 1050];
  const expense = <double>[700, 820, 640, 910, 760, 830];
  return [
    for (var i = 0; i < _months; i++)
      MonthFlow(
        month: DateTime(now.year, now.month - (_months - 1 - i)),
        income: income[i],
        expense: expense[i],
      ),
  ];
}

// La gráfica de barras agrupadas ==================================
class _FlowBars extends StatelessWidget {
  final List<MonthFlow> data;

  const _FlowBars({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compact(locale: locale);

    final maxValue = data.fold<double>(
      0,
      (m, f) => max(m, max(f.income, f.expense)),
    );

    const radius = BorderRadius.vertical(top: Radius.circular(4));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue == 0 ? 1 : maxValue * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    context.dates.monthLabelShort(
                      data[i].month.year,
                      data[i].month.month,
                    ),
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => cs.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  compact.format(
                    rod.toY,
                  ), // ← cámbialo por tu formateador de moneda
                  TextStyle(
                    color: cs.onInverseSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: data[i].income,
                  color: _incomeColor,
                  width: 10,
                  borderRadius: radius,
                ),
                BarChartRodData(
                  toY: data[i].expense,
                  color: cs.error,
                  width: 10,
                  borderRadius: radius,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
