import 'package:flutter/material.dart';
import 'package:kaku/core/models/transaction_type.dart';

class ToggleIsIncomeCategory extends StatelessWidget {
  final TransactionType selectedType;
  final Function(int) onPressed;

  const ToggleIsIncomeCategory({
    super.key,
    required this.onPressed,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return Container(
      // width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ToggleButtons(
        fillColor: selectedType.color.withValues(alpha: 0.15),
        isSelected: [
          selectedType == TransactionType.expense,
          selectedType == TransactionType.income,
        ],
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(18),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              TransactionType.expense.label,
              style: ts.titleMedium?.copyWith(
                color: selectedType == TransactionType.expense
                    ? selectedType.color
                    : cs.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              TransactionType.income.label,
              style: ts.titleMedium?.copyWith(
                color: selectedType == TransactionType.expense
                    ? cs.onSurfaceVariant
                    : selectedType.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
