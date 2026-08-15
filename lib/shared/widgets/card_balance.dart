import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/shared/widgets/chip_item.dart';

class ChipItemConfig {
  final String title;
  final String description;
  final Color colorDescription;

  const ChipItemConfig({
    required this.title,
    required this.description,
    required this.colorDescription,
  });
}

class CardBalance extends StatelessWidget {
  final String title;
  final double amount;
  final String? subtitle;
  final List<ChipItemConfig> chipItems;

  const CardBalance({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    required this.chipItems,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: textScheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              CurrencyFormatter.format(amount),
              style: textScheme.titleLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w800,
                fontSize: (textScheme.titleLarge?.fontSize ?? 12) * 2,
              ),
            ),
            const SizedBox(height: 4),
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: textScheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < chipItems.length; i++) ...[
                  Expanded(
                    child: ChipItem(
                      title: chipItems[i].title.toUpperCase(),
                      subtitle: chipItems[i].description,
                      color: chipItems[i].colorDescription,
                    ),
                  ),
                  if (i != chipItems.length - 1) const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
