import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class ToggleAppBar extends ConsumerWidget {
  const ToggleAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final selectedType = ref.watch(addTransactionTypeProvider);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ToggleButtons(
        fillColor: selectedType == TransactionType.expense
            ? Colors.red.withValues(alpha: 0.15)
            : Colors.green.withValues(alpha: 0.15),
        isSelected: [
          selectedType == TransactionType.expense,
          selectedType == TransactionType.income,
        ],
        onPressed: (index) {
          ref.read(addTransactionTypeProvider.notifier).state = index == 0
              ? TransactionType.expense
              : TransactionType.income;
        },
        borderRadius: BorderRadius.circular(18),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Gasto',
              style: ts.titleMedium?.copyWith(
                color: selectedType == TransactionType.expense
                    ? Colors.red
                    : cs.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Ingreso',
              style: ts.titleMedium?.copyWith(
                color: selectedType == TransactionType.expense
                    ? cs.onSurfaceVariant
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
