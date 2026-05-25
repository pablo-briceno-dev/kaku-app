import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/core/models/transaction_type_filter.dart';
import 'package:kaku/features/transactions/card_transactions.dart';
import 'package:kaku/features/transactions/horizontal_transaction_type_filter.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categorySelected = ref.watch(selectedCategoryProvider);
    final selectedFilter = ref.watch(transactionTypeFilterProvider);
    final monthTransactions = ref
        .watch(
          monthTransactionsProvider((
            month: selectedMonth.month,
            year: selectedMonth.year,
          )),
        )
        .value
        ?.where(
          (tx) =>
              selectedFilter != TransactionTypeFilter.byCategory ||
              (selectedFilter == TransactionTypeFilter.byCategory &&
                  tx.category?.id == categorySelected),
        )
        .where((tx) {
          if (selectedFilter == TransactionTypeFilter.all) {
            return true;
          }
          if (selectedFilter == TransactionTypeFilter.income &&
              tx.transaction.type == 'income') {
            return true;
          }
          if (selectedFilter == TransactionTypeFilter.expense &&
              tx.transaction.type == 'expense') {
            return true;
          }
          if (selectedFilter == TransactionTypeFilter.transfer &&
              tx.transaction.type == 'transfer') {
            return true;
          }
          return false;
        });
    final income =
        monthTransactions
            ?.where((tx) => tx.transaction.type == 'income')
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;
    final expense =
        monthTransactions
            ?.where((tx) => tx.transaction.type == 'expense')
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;

    return Scaffold(
      appBar: CustomAppBar(title: Text('Transacciones')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            HorizontalTransactionTypeFilter(),
            const SizedBox(height: 16),
            CardTransactions(
              expenses: CurrencyFormatter.withSign(
                expense,
                compact: true,
                type: TransactionType.expense,
              ),
              incomes: CurrencyFormatter.withSign(
                income,
                compact: true,
                type: TransactionType.income,
              ),
              total: monthTransactions?.length.toString() ?? '0',
            ),
          ],
        ),
      ),
    );
  }
}
