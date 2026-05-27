import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/features/stats/category_donut_chart.dart';
import 'package:kaku/features/stats/daily_bar_chart.dart';
import 'package:kaku/features/stats/month_comparison_card.dart';
import 'package:kaku/features/stats/spending_line_chart.dart';
import 'package:kaku/features/stats/widgets/chart_skeleton.dart';
import 'package:kaku/features/stats/widgets/section_title.dart';
import 'package:kaku/features/stats/widgets/stats_empty_state.dart';
import 'package:kaku/shared/providers/stats_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final params = ref.watch(selectedMonthProvider);
    final currency = ref.watch(currencyProvider);
    final prevParams = BudgetCalculator.previousMonth(
      params.year,
      params.month,
    );

    final slicesAsync = ref.watch(categorySlicesProvider(params));
    final dailyAsync = ref.watch(dailyExpensesProvider(params));
    final trendAsync = ref.watch(sixMonthTrendProvider(params));
    final prevAsync = ref.watch(dailyExpensesProvider(prevParams));

    final monthName = DateFormat('MMMM yyyy')
        .format(DateTime(params.year, params.month))
        .replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase());

    return Scaffold(
      appBar: CustomAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadísticas'),
            Text(
              monthName,
              style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        defaultActions: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SegmentedButton<StatsPeriod>(
                  segments: [
                    ButtonSegment(value: StatsPeriod.month, label: Text('Mes')),
                    ButtonSegment(
                      value: StatsPeriod.quarter,
                      label: Text('Trimestre'),
                    ),
                    ButtonSegment(value: StatsPeriod.year, label: Text('Año')),
                  ],
                  selected: {ref.watch(statsPeriodProvider)},
                  onSelectionChanged: (value) =>
                      ref.read(statsPeriodProvider.notifier).state =
                          value.first,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionTitle(title: 'Distribución', subtitle: 'Por categoría'),
                slicesAsync.when(
                  data: (slices) => slices.isEmpty
                      ? const StatsEmptyState()
                      : CategoryDonutChart(
                          slices: slices,
                          totalAmount: slices.fold(0, (s, sl) => s + sl.amount),
                        ),
                  error: (e, _) => Text('Error: $e'),
                  loading: () => const ChartSkeleton(height: 280),
                ),
                const SizedBox(height: 28),
                SectionTitle(
                  title: 'Gasto diario',
                  subtitle:
                      '${BudgetCalculator.daysInMonth(params.year, params.month)}',
                ),
                dailyAsync.when(
                  loading: () => const ChartSkeleton(height: 160),
                  error: (e, _) => Text('Error: $e'),
                  data: (daily) => DailyBarChart(
                    dailyData: daily,
                    daysInMonth: BudgetCalculator.daysInMonth(
                      params.year,
                      params.month,
                    ),
                    currency: currency,
                  ),
                ),
                const SizedBox(height: 28),
                const SectionTitle(
                  title: 'Tendencia',
                  subtitle: 'Últimos 6 meses',
                ),
                trendAsync.when(
                  data: (trend) =>
                      SpendingLineChart(points: trend, currency: currency),
                  error: (e, _) => Text('Error: $e'),
                  loading: () => const ChartSkeleton(height: 160),
                ),
                const SizedBox(height: 28),
                SectionTitle(
                  title: 'Mes vs anterior',
                  subtitle: DateFormat(
                    'MMMM',
                  ).format(DateTime(prevParams.year, prevParams.month)),
                ),
                _buildComparison(params, prevParams, prevAsync, currency),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(
    ({int month, int year}) current,
    ({int month, int year}) prev,
    AsyncValue<Map<int, double>> prevAsync,
    CurrencyType currency,
  ) {
    return prevAsync.when(
      loading: () => const ChartSkeleton(height: 110),
      error: (e, _) => Text('Error: $e'),
      data: (prevDaily) {
        final prevTotal = prevDaily.values.fold(0.0, (a, b) => a + b);
        final currentLabel = DateFormat(
          'MMMM',
          'es',
        ).format(DateTime(current.year, current.month));
        final prevLabel = DateFormat(
          'MMMM',
          'es',
        ).format(DateTime(prev.year, prev.month));
        return MonthComparisonCard(
          currentAmount:
              0, // deberías obtenerlo del provider de totales del mes actual
          previousAmount: prevTotal,
          currentLabel: currentLabel,
          previousLabel: prevLabel,
          currency: currency,
        );
      },
    );
  }
}
