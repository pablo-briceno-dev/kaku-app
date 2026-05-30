import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/budget_progress.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/shared/utils/budget_color.dart';

class CardBudgetCategory extends StatelessWidget {
  final double limit;
  final double spent;
  final int month;
  final CurrencyType currency;
  final BudgetStatus status;

  const CardBudgetCategory({
    super.key,
    required this.limit,
    required this.spent,
    required this.month,
    required this.currency,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final monthLabels = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    if (limit == 0) {
      return Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 30, color: cs.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(
              'Sin presupuesto definido para esta categoría',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    final colorBudget = getBudgetColorForStatus(status, cs);

    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gastado en ${monthLabels[month - 1]}'.toUpperCase()),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(spent, currency),
                    style: TextStyle(fontSize: 22, color: cs.error),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Límite'.toUpperCase()),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(limit, currency),
                    style: TextStyle(fontSize: 22, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: spent / limit,
            backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            valueColor: AlwaysStoppedAnimation<Color>(colorBudget),
            minHeight: 10,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${CurrencyFormatter.percentage((spent / limit) * 100)} usado',
                style: TextStyle(fontSize: 20, color: cs.primary),
              ),
              const Spacer(),
              Text(
                'Quedan ${CurrencyFormatter.format(limit - spent, currency)}',
                style: TextStyle(fontSize: 20, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
