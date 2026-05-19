import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/features/dashboard/chip_item.dart';
import 'package:kaku/features/dashboard/month_navigator.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/profile_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;
    final textScheme = Theme.of(context).textTheme;
    final totalBalance = ref.watch(totalBalanceProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthTransactions = ref.watch(
      monthTransactionsProvider((
        month: selectedMonth.month,
        year: selectedMonth.year,
      )),
    );
    final income =
        monthTransactions.value
            ?.where((tx) => tx.transaction.type == 'income')
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;
    final expense =
        monthTransactions.value
            ?.where((tx) => tx.transaction.type == 'expense')
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;
    final savingsRate = BudgetCalculator.savingsRate(income, expense);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Hola, ${profile.displayName} 👋',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonthNavigator(),
            const SizedBox(height: 16),
            // Tarjeta de balance
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'SALDO DISPONIBLE',
                        style: textScheme.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(totalBalance.value ?? 0),
                        style: textScheme.titleLarge?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: (textScheme.titleLarge?.fontSize ?? 12) * 2,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ChipItem(
                              title: 'INGRESOS',
                              subtitle: CurrencyFormatter.withSign(
                                income,
                                compact: true,
                                type: 'income',
                              ),
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ChipItem(
                              title: 'GASTOS',
                              subtitle: CurrencyFormatter.withSign(
                                expense,
                                compact: true,
                                type: 'expense',
                              ),
                              color: cs.error,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ChipItem(
                              title: 'AHORRO',
                              subtitle: CurrencyFormatter.percentage(
                                savingsRate,
                              ),
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
