import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class MiniStatsByCategory extends ConsumerWidget {
  final int categoryId;

  const MiniStatsByCategory({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactionsAsync = ref.watch(
      monthTransactionsProvider(selectedMonth),
    );
    final currency = ref.watch(currencyProvider);

    final transactions = transactionsAsync
        .whenData(
          (txs) => txs.where((t) => t.category?.id == categoryId).toList(),
        )
        .value;
    final average = transactions != null && transactions.isNotEmpty
        ? transactions
                  .where((t) => t.category?.id == categoryId)
                  .fold(
                    0.0,
                    (s, t) =>
                        s +
                        BudgetCalculator.balanceDelta(
                          TransactionType.values
                              .where((tx) => tx.name == t.transaction.type)
                              .first,
                          t.transaction.amount,
                        ),
                  ) /
              transactions.length
        : 0.0;
    final higherSpending = transactions != null && transactions.isNotEmpty
        ? transactions
              .map((e) => e.transaction.amount)
              .reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Row(
      children: [
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                'Transacciones'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transactions?.length ?? 0}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                'Promedio'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.compact(average, currency),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                'Mayor gasto'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.compact(higherSpending, currency),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
