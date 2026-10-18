import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/stats_models.dart';
import 'package:kaku/features/stats/category_donut_chart.dart';
import 'package:kaku/features/stats/daily_bar_chart.dart';
import 'package:kaku/features/stats/income_expense_chart.dart';
import 'package:kaku/features/stats/month_comparison_card.dart';
import 'package:kaku/features/stats/spending_line_chart.dart';
import 'package:kaku/features/stats/widgets/chart_skeleton.dart';
import 'package:kaku/features/stats/widgets/locked_content.dart';
import 'package:kaku/features/stats/widgets/section_title.dart';
import 'package:kaku/features/stats/widgets/stats_empty_state.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/premium_provider.dart';
import 'package:kaku/shared/providers/stats_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/month_navigator.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final isPremium = ref.watch(isPremiumProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final currency = ref.watch(currencyProvider);

    // ✅ Ahora sí se lee el período seleccionado
    final period = ref.watch(statsPeriodProvider);

    final prevParams = BudgetCalculator.previousMonth(
      selectedMonth.year,
      selectedMonth.month,
    );

    final slicesAsync = ref.watch(categorySlicesProvider(selectedMonth));
    final dailyAsync = ref.watch(dailyExpensesProvider(selectedMonth));
    final trendAsync = ref.watch(sixMonthTrendProvider(selectedMonth));
    final prevAsync = ref.watch(dailyExpensesProvider(prevParams));

    // ✅ Provider nuevo — trimestre (3) o año (12) según el período
    final quarterAsync = ref.watch(
      multiMonthExpensesProvider((
        month: selectedMonth.month,
        year: selectedMonth.year,
        count: 3,
      )),
    );
    final yearAsync = ref.watch(
      multiMonthExpensesProvider((
        month: selectedMonth.month,
        year: selectedMonth.year,
        count: 12,
      )),
    );

    final monthName = context.dates.monthYear(
      selectedMonth.year,
      selectedMonth.month,
    );

    final isCurrentMonth = ref.watch(
      selectedMonthProvider.select(
        (m) => BudgetCalculator.isCurrentMonth(m.year, m.month),
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsTitle, overflow: TextOverflow.ellipsis, maxLines: 1),
            Text(
              monthName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        defaultActions: true,
        actions: [
          MonthNavigator(
            compact: true,
            isViewLabelMonth: false,
            selectedMonth: selectedMonth,
            isCurrentMonth: isCurrentMonth,
            onPreviousMonth: () =>
                ref.read(selectedMonthProvider.notifier).toPrevious(),
            onNextMonth: () =>
                ref.read(selectedMonthProvider.notifier).toNext(),
            onMonthSelected: (date) {
              ref
                  .read(selectedMonthProvider.notifier)
                  .setMonth(year: date.year, month: date.month);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Selector de período ──────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SegmentedButton<StatsPeriod>(
                  segments: [
                    ButtonSegment(
                      value: StatsPeriod.month,
                      label: Text(l10n.statsMonthLabel),
                    ),
                    ButtonSegment(
                      value: StatsPeriod.quarter,
                      label: Text(l10n.statsQuarterLabel),
                    ),
                    ButtonSegment(
                      value: StatsPeriod.year,
                      label: Text(l10n.statsYearLabel),
                    ),
                  ],
                  selected: {period},
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
                // ── Dona de categorías ── siempre del mes actual
                SectionTitle(
                  title: l10n.statsDonutTitle,
                  subtitle: l10n.statsDonutSubtitle(monthName),
                ),
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

                // ── Gráfica principal — cambia según el período ──
                // ✅ Aquí es donde el SegmentedButton ahora SÍ tiene efecto
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildMainChart(
                    key: ValueKey(period),
                    context: context,
                    period: period,
                    params: selectedMonth,
                    currency: currency,
                    dailyAsync: dailyAsync,
                    quarterAsync: quarterAsync,
                    yearAsync: yearAsync,
                  ),
                ),

                // ── Secciones premium ────────────────────────
                const SizedBox(height: 28),
                SectionTitle(
                  title: l10n.statsTrendTitle,
                  subtitle: l10n.statsTrendSubtitle,
                ),
                trendAsync.when(
                  data: (trend) {
                    if (!isPremium) {
                      return LockedContent(
                        child: SpendingLineChart(
                          points: [
                            MonthPoint(
                              month: 1,
                              year: 2022,
                              totalExpenses: 50000,
                            ),
                            MonthPoint(
                              month: 2,
                              year: 2022,
                              totalExpenses: 100000,
                            ),
                            MonthPoint(
                              month: 3,
                              year: 2022,
                              totalExpenses: 30000,
                            ),
                            MonthPoint(
                              month: 4,
                              year: 2022,
                              totalExpenses: 200000,
                            ),
                            MonthPoint(
                              month: 5,
                              year: 2022,
                              totalExpenses: 10000,
                            ),
                            MonthPoint(
                              month: 6,
                              year: 2022,
                              totalExpenses: 60000,
                            ),
                          ],
                          currency: currency,
                        ),
                      );
                    }

                    return SpendingLineChart(points: trend, currency: currency);
                  },
                  error: (e, _) => Text('Error: $e'),
                  loading: () => const ChartSkeleton(height: 160),
                ),
                const SizedBox(height: 28),
                IncomeExpenseChart(isPremium: isPremium),
                const SizedBox(height: 28),
                SectionTitle(
                  title: l10n.statsTrendMonthVsPreviousTitle,
                  subtitle: context.dates.justMonth(
                    DateTime(prevParams.year, prevParams.month),
                  ),
                ),
                _buildComparison(
                  context,
                  selectedMonth,
                  prevParams,
                  dailyAsync,
                  prevAsync,
                  currency,
                  isPremium,
                ),
                
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gráfica principal según el período ──────────────────────
  Widget _buildMainChart({
    required Key key,
    required BuildContext context,
    required StatsPeriod period,
    required ({int month, int year}) params,
    required CurrencyType currency,
    required AsyncValue<Map<int, double>> dailyAsync,
    required AsyncValue<List<MonthPoint>> quarterAsync,
    required AsyncValue<List<MonthPoint>> yearAsync,
  }) {
    final l10n = AppLocalizations.of(context)!;
    switch (period) {
      // ── MES: barras diarias ──────────────────────────────
      case StatsPeriod.month:
        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: l10n.statsExpensesDiaryTitle,
              subtitle: l10n.statsExpensesDiarySubtitle(
                BudgetCalculator.daysInMonth(params.year, params.month),
              ),
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
          ],
        );

      // ── TRIMESTRE: barras por mes (3 meses) ──────────────
      case StatsPeriod.quarter:
        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: l10n.statsLast3MonthsTitle,
              subtitle: l10n.statsLast3MonthsSubtitle,
            ),
            quarterAsync.when(
              loading: () => const ChartSkeleton(height: 160),
              error: (e, _) => Text('Error: $e'),
              data: (points) =>
                  SpendingLineChart(points: points, currency: currency),
            ),
          ],
        );

      // ── AÑO: barras por mes (12 meses) ───────────────────
      case StatsPeriod.year:
        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: l10n.statsLastYearTitle,
              subtitle: l10n.statsLast3MonthsSubtitle,
            ),
            yearAsync.when(
              loading: () => const ChartSkeleton(height: 160),
              error: (e, _) => Text('Error: $e'),
              data: (points) =>
                  SpendingLineChart(points: points, currency: currency),
            ),
          ],
        );
    }
  }

  Widget _buildComparison(
    BuildContext context,
    ({int month, int year}) current,
    ({int month, int year}) prev,
    AsyncValue<Map<int, double>> currentAsync,
    AsyncValue<Map<int, double>> prevAsync,
    CurrencyType currency,
    bool isPremium,
  ) {
    return currentAsync.when(
      loading: () => const ChartSkeleton(height: 110),
      error: (e, _) => Text('Error: $e'),
      data: (currentDaily) {
        return prevAsync.when(
          loading: () => const ChartSkeleton(height: 110),
          error: (e, _) => Text('Error: $e'),
          data: (prevDaily) {
            final currentLabel = context.dates.justMonth(
              DateTime(current.year, current.month),
            );
            final prevLabel = context.dates.justMonth(
              DateTime(prev.year, prev.month),
            );

            // Bloqueado para usuarios free
            if (!isPremium) {
              return LockedContent(
                child: MonthComparisonCard(
                  currentAmount: 0,
                  previousAmount: 100000,
                  currentLabel: currentLabel,
                  previousLabel: prevLabel,
                  currency: currency,
                ),
              );
            }

            // ✅ Cálculo real de totales
            final currentTotal = currentDaily.values.fold(0.0, (a, b) => a + b);
            final prevTotal = prevDaily.values.fold(0.0, (a, b) => a + b);

            return MonthComparisonCard(
              currentAmount: currentTotal, // ← ahora sí
              previousAmount: prevTotal,
              currentLabel: currentLabel,
              previousLabel: prevLabel,
              currency: currency,
            );
          },
        );
      },
    );
  }
}