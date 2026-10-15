import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/stats_models.dart';
import 'package:kaku/features/stats/category_donut_chart.dart';
import 'package:kaku/features/stats/daily_bar_chart.dart';
import 'package:kaku/features/stats/month_comparison_card.dart';
import 'package:kaku/features/stats/spending_line_chart.dart';
import 'package:kaku/features/stats/widgets/chart_skeleton.dart';
import 'package:kaku/features/stats/widgets/section_title.dart';
import 'package:kaku/features/stats/widgets/stats_empty_state.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/premium_provider.dart';
import 'package:kaku/shared/providers/stats_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/month_navigator.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';

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

    final monthName = context.dates
        .monthYear(selectedMonth.year, selectedMonth.month)
        .toUpperCase();

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
              overflow: TextOverflow.ellipsis, maxLines: 1,
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
            onPreviousMonth: () => ref.read(selectedMonthProvider.notifier).toPrevious(),
            onNextMonth: () => ref.read(selectedMonthProvider.notifier).toNext(),
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
                isPremium.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (isPrem) {
                    if (!isPrem) {
                      // Muestra un teaser bloqueado
                      return _PremiumStatsTeaser();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 28),
                        SectionTitle(
                          title: l10n.statsTrendTitle,
                          subtitle: l10n.statsTrendSubtitle,
                        ),
                        trendAsync.when(
                          data: (trend) => SpendingLineChart(
                            points: trend,
                            currency: currency,
                          ),
                          error: (e, _) => Text('Error: $e'),
                          loading: () => const ChartSkeleton(height: 160),
                        ),
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
                          prevAsync,
                          currency,
                        ),
                      ],
                    );
                  },
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
    AsyncValue<Map<int, double>> prevAsync,
    CurrencyType currency,
  ) {
    return prevAsync.when(
      loading: () => const ChartSkeleton(height: 110),
      error: (e, _) => Text('Error: $e'),
      data: (prevDaily) {
        final prevTotal = prevDaily.values.fold(0.0, (a, b) => a + b);
        final currentLabel = context.dates.justMonth(
          DateTime(current.year, current.month),
        );
        final prevLabel = context.dates.justMonth(
          DateTime(prev.year, prev.month),
        );
        return MonthComparisonCard(
          currentAmount: 0,
          previousAmount: prevTotal,
          currentLabel: currentLabel,
          previousLabel: prevLabel,
          currency: currency,
        );
      },
    );
  }
}

// ── Teaser para usuarios free ─────────────────────────────────
class _PremiumStatsTeaser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: PremiumGate(
        feature: PremiumFeature.viewHistory,
        showLockBadge: true,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📈 ${l10n.statsTrend6MonthsTitle}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              // Gráfica simulada borrosa
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageFiltered(
                  imageFilter: ColorFilter.matrix(const [
                    0.2,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0.2,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0.2,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: const ChartSkeleton(height: 130),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.statsTrend6MonthsSubtitle,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
