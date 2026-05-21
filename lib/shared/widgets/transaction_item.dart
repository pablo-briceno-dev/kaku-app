import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/date_formatter.dart';

class TransactionItem extends StatelessWidget {
  final TransactionWithCategory txWithCat; // TransactionWithCategory
  final VoidCallback? onTap;

  const TransactionItem({super.key, required this.txWithCat, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tx = txWithCat.transaction;
    final cat = txWithCat.category;

    final isExpense = tx.type == 'expense';
    final amountColor = isExpense ? cs.error : const Color(0xFF6ADF9A);
    final amountPrefix = isExpense ? '-' : '+';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withAlpha(60),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat?.emoji ?? '💸',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description ?? cat?.name ?? 'Sin descripción',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        // color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (cat != null) cat.name,
                        DateFormatter.relativeShort(tx.date),
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$amountPrefix${CurrencyFormatter.compact(tx.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
