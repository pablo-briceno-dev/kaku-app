import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/account_type.dart';
import 'package:kaku/core/models/currency_type.dart';

class CardAccountItem extends StatelessWidget {
  final String emoji;
  final String name;
  final AccountType type;
  final Color color;
  final double balance;
  final CurrencyType currencyType;
  final bool isActive;
  final VoidCallback? onTap;
  final Function(LongPressStartDetails)? onLongPressStart;

  const CardAccountItem({
    super.key,
    required this.emoji,
    required this.name,
    required this.type,
    required this.color,
    required this.balance,
    required this.currencyType,
    this.isActive = true,
    this.onTap,
    this.onLongPressStart,
  });

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      child: Container(
        width: 120,
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surfaceContainer,
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.15),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 65,
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: color.withValues(alpha: 0.15),
                border: Border.all(
                  color: color.withValues(alpha: 0.1),
                  width: 5,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: ts.titleLarge?.copyWith(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${type.label} ${isActive ? '' : '  ·  Archivada'}',
                    style: ts.titleSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(balance, currencyType),
                    style: ts.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyType.label,
                    style: ts.titleSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
