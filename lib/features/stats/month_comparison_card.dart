import 'package:flutter/material.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';

class MonthComparisonCard extends StatelessWidget {
  final double currentAmount;
  final double previousAmount;
  final String currentLabel;
  final String previousLabel;
  final CurrencyType currency;

  const MonthComparisonCard({
    super.key,
    required this.currentAmount,
    required this.previousAmount,
    required this.currentLabel,
    required this.previousLabel,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final variation = BudgetCalculator.monthVariation(
      currentAmount,
      previousAmount,
    );
    final isImproved = variation <= 0;
    final goodColor = const Color(0xFF6ADF9A);
    final badColor = const Color(0xFFFF7C7C);
    final varColor = isImproved ? goodColor : badColor;
    final arrow = isImproved ? '↑' : '↓';
    final maxAmount = currentAmount > previousAmount
        ? currentAmount
        : previousAmount;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MonthColumn(
                label: previousLabel,
                amount: previousAmount,
                maxAmount: maxAmount,
                color: Colors.white.withValues(alpha: 0.3),
                currency: currency,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white.withValues(alpha: 0.15),
                size: 18,
              ),
            ),
            Expanded(
              child: _MonthColumn(
                label: currentLabel,
                amount: currentAmount,
                maxAmount: maxAmount,
                color: varColor,
                currency: currency,
                isActive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: varColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: varColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastaste',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '$arrow ${variation.abs().toStringAsFixed(1)}% ${isImproved ? 'menos' : 'más'}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: varColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthColumn extends StatelessWidget {
  final String label;
  final double amount, maxAmount;
  final Color color;
  final bool isActive;
  final CurrencyType currency;

  const _MonthColumn({
    required this.label,
    required this.amount,
    required this.maxAmount,
    required this.color,
    required this.currency,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount > 0 ? (amount / maxAmount) : 0.0;
    return Column(
      crossAxisAlignment: isActive
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.compact(amount, currency),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isActive ? color : Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
