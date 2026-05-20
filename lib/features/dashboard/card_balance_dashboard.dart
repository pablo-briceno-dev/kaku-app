import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/card_balance.dart';

class CardBalanceDashboard extends ConsumerWidget {
  const CardBalanceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
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

    return SizedBox(
          width: double.infinity,
          child: CardBalance(
            title: 'SALDO DISPONIBLE',
            amount: totalBalance.value ?? 0,
            chipItems: [
              ChipItemConfig(
                title: 'INGRESOS',
                description: CurrencyFormatter.withSign(
                  income,
                  compact: true,
                  type: 'income',
                ),
                colorDescription: Colors.green,
              ),
              ChipItemConfig(
                title: 'GASTOS',
                description: CurrencyFormatter.withSign(
                  expense,
                  compact: true,
                  type: 'expense',
                ),
                colorDescription: cs.error,
              ),
              ChipItemConfig(
                title: 'AHORRO',
                description: CurrencyFormatter.percentage(savingsRate),
                colorDescription: cs.primary,
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04, end: 0, duration: 300.ms);
  }
}
