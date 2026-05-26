import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/core/models/transaction_type_filter.dart';
import 'package:kaku/core/receipt_storage.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/utils/undo_delete.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/transaction_item.dart';

class TransactionsListFilter extends ConsumerWidget {
  const TransactionsListFilter({super.key});

  Future<void> _onDelete(
    WidgetRef ref,
    Transaction transaction,
    double balance,
  ) async {
    await ReceiptStorage.delete(transaction.receiptPath);
    ref.read(transactionsDaoProvider).deleteTransaction(transaction.id);
    final reversedDelta = BudgetCalculator.balanceDelta(
      TransactionType.values.firstWhere((e) => e.name == transaction.type),
      transaction.amount,
    );
    ref
        .read(accountsDaoProvider)
        .updateBalance(transaction.accountId, balance + (reversedDelta * -1));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categorySelected = ref.watch(selectedCategoryProvider);
    final selectedFilter = ref.watch(transactionTypeFilterProvider);
    final monthTransactionsAsync = ref.watch(
      monthTransactionsProvider((
        month: selectedMonth.month,
        year: selectedMonth.year,
      )),
    );

    return monthTransactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const ContentWidgetEmpty(
            title: '🫙',
            message: 'Sin transacciones',
          );
        }
        var transactionsFiltered = transactions.where(
          (tx) =>
              selectedFilter != TransactionTypeFilter.byCategory ||
              (selectedFilter == TransactionTypeFilter.byCategory &&
                  tx.category?.id == categorySelected),
        );
        if (selectedFilter == TransactionTypeFilter.income) {
          transactionsFiltered = transactionsFiltered.where(
            (tx) => tx.transaction.type == 'income',
          );
        }
        if (selectedFilter == TransactionTypeFilter.expense) {
          transactionsFiltered = transactionsFiltered.where(
            (tx) => tx.transaction.type == 'expense',
          );
        }
        if (selectedFilter == TransactionTypeFilter.transfer) {
          transactionsFiltered = transactionsFiltered.where(
            (tx) => tx.transaction.type == 'transfer',
          );
        }

        // Agrupar por día usando groupKey como clave
        final Map<String, List<TransactionWithCategory>> grouped = {};
        for (final tx in transactionsFiltered) {
          final key = DateFormatter.groupKey(tx.transaction.date);
          grouped.putIfAbsent(key, () => []).add(tx);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  ...dayTxs.map((txWithCat) {
                    final account = ref
                        .watch(
                          accountByIdProvider(txWithCat.transaction.accountId),
                        )
                        .value;
                    return TransactionItem(
                      txWithCat: txWithCat,
                      onTap: () => context.push(
                        AppRoutes.toTransaction(txWithCat.transaction.id),
                      ),
                      slideActions: [
                        SlideAction(
                          icon: Icons.delete_outline_rounded,
                          label: 'Eliminar',
                          color: Theme.of(context).colorScheme.error,
                          onTap: () => showUndoDelete(
                            context: context,
                            label: 'Transacción eliminandose',
                            onDelete: () => _onDelete(
                              ref,
                              txWithCat.transaction,
                              account?.balance ?? 0.0,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Center(child: Text('Error')),
    );
  }
}
