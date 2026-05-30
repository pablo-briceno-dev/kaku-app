import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/core/models/transaction_type_filter.dart';
import 'package:kaku/features/transactions/card_transactions.dart';
import 'package:kaku/features/transactions/horizontal_transaction_type_filter.dart';
import 'package:kaku/features/transactions/transactions_list_filter.dart';
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
    var monthTransactions = ref
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
        );
    if (selectedFilter == TransactionTypeFilter.income) {
      monthTransactions = monthTransactions?.where(
        (tx) => tx.transaction.type == TransactionType.income.name,
      );
    }
    if (selectedFilter == TransactionTypeFilter.expense) {
      monthTransactions = monthTransactions?.where(
        (tx) => tx.transaction.type == TransactionType.expense.name,
      );
    }
    if (selectedFilter == TransactionTypeFilter.transfer) {
      monthTransactions = monthTransactions?.where(
        (tx) => tx.transaction.type == TransactionType.transfer.name,
      );
    }
    final income =
        monthTransactions
            ?.where((tx) => tx.transaction.type == TransactionType.income.name)
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;
    final expense =
        monthTransactions
            ?.where((tx) => tx.transaction.type == TransactionType.expense.name)
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;

    return Scaffold(
      appBar: CustomAppBar(title: Text('Transacciones')),
      body: SingleChildScrollView(
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
            const SizedBox(height: 16),
            TransactionsListFilter(),
          ],
        ),
      ),
    );
  }
}
