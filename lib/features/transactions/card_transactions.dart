import 'package:flutter/material.dart';
import 'package:kaku/core/models/transaction_type.dart';

class CardTransactions extends StatelessWidget {
  final String expenses;
  final String incomes;
  final String total;

  const CardTransactions({
    super.key,
    required this.expenses,
    required this.incomes,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return Container(
      height: 100,
      // width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                TransactionType.expense.labelPlural.toUpperCase(),
                style: ts.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                expenses,
                style: ts.titleLarge?.copyWith(
                  color: TransactionType.expense.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                TransactionType.income.labelPlural.toUpperCase(),
                style: ts.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                incomes,
                style: ts.titleLarge?.copyWith(
                  color: TransactionType.income.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'total'.toUpperCase(),
                style: ts.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '$total txs',
                style: ts.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
