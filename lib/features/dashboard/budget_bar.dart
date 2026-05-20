import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/budget_progress.dart';

class BudgetBar extends StatelessWidget {
  final String emoji;
  final String title;
  final double progress;
  final BudgetStatus status;

  const BudgetBar({
    super.key,
    required this.emoji,
    required this.title,
    required this.progress,
    this.status = BudgetStatus.ok,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final color = switch (status) {
      BudgetStatus.ok => cs.primary,
      BudgetStatus.warning => Colors.amber,
      BudgetStatus.overBudget => cs.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.primary.withAlpha(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: ts.titleLarge?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(
            title,
            style: ts.titleSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.percentage(progress),
            style: ts.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: (ts.titleMedium?.fontSize ?? 12) * 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
