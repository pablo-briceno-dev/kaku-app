import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/features/dashboard/card_balance_dashboard.dart';
import 'package:kaku/features/dashboard/horizontal_progress_bars.dart';
// import 'package:kaku/features/dashboard/month_navigator.dart';
import 'package:kaku/features/dashboard/projection_banner.dart';
import 'package:kaku/features/dashboard/transactions_list.dart';
import 'package:kaku/features/dashboard/upcoming_events.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/profile_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/month_navigator.dart';
import 'package:upgrader/upgrader.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final budgetAsync = ref.watch(budgetProgressProvider(selectedMonth)).value;
    final entriesAsync = ref.watch(calendarMonthProvider(selectedMonth)).value;

    final isCurrentMonth = ref.watch(
      selectedMonthProvider.select(
        (m) => BudgetCalculator.isCurrentMonth(m.year, m.month),
      ),
    );

    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(seconds: 10),
        // debugLogging: true,
        // debugDisplayAlways: true,
      ),
      child: Scaffold(
        appBar: CustomAppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName(l10n) == l10n.userDisplayName
                    ? l10n.welcomeToKaku
                    : l10n.welcomeToKakuName(profile.displayName(l10n)),
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.welcomeToKakuSubtitle,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          defaultActions: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: MonthNavigator(
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
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              CardBalanceDashboard(), // Tarjeta de balance
              if (entriesAsync != null &&
                  BudgetCalculator.isCurrentMonth(
                    selectedMonth.year,
                    selectedMonth.month,
                  )) ...[
                const SizedBox(height: 16),
                UpcomingEvents(), // Próximos eventos
              ],
              if (budgetAsync != null) ...[
                const SizedBox(height: 16),
                HorizontalProgressBars(), // Barras de progreso horizontales
              ],
              const SizedBox(height: 16),
              ProjectionBanner(),
              const SizedBox(height: 16),
              TransactionsList(),
            ],
          ),
        ),
      ),
    );
  }
}
