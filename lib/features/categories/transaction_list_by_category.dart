import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/features/dashboard/widgets/transactions_list_skeleton.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/transaction_item.dart';

class TransactionListByCategory extends ConsumerWidget {
  final int categoryId;

  const TransactionListByCategory({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final txAsync = ref.watch(monthTransactionsProvider(selectedMonth));

    return txAsync.when(
      loading: () => const TransactionsListSkeleton(),
      error: (e, _) => const SizedBox.shrink(),
      data: (transactions) {
        if (transactions.isEmpty) {
          return const ContentWidgetEmpty(
            title: '🫙',
            message: 'Sin transacciones',
          );
        }
        // Agrupar por día usando groupKey como clave
        final Map<String, List<TransactionWithCategory>> grouped = {};
        for (final tx in transactions) {
          if (tx.category == null) continue;
          if (tx.category?.id != categoryId) continue;
          final key = DateFormatter.groupKey(tx.transaction.date);
          grouped.putIfAbsent(key, () => []).add(tx);
        }

        if (grouped.isEmpty) {
          return const ContentWidgetEmpty(
            title: '🫙',
            message: 'Sin transacciones',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transacciones',
                    style: ts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Un grupo por día
            ...grouped.entries.map((entry) {
              final date = DateTime.parse(entry.key);
              final dayTxs = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del día
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      DateFormatter.relative(date),
                      style: ts.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Items del día
                  ...dayTxs.map(
                    (txWithCat) => TransactionItem(txWithCat: txWithCat),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}
