import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/account_type.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/card_balance.dart';

class CardAccountDetail extends ConsumerWidget {
  final Account account;

  const CardAccountDetail({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthTransactions = ref.watch(
      monthTransactionsProvider((
        month: selectedMonth.month,
        year: selectedMonth.year,
      )),
    );
    final income =
        monthTransactions.value
            ?.where(
              (tx) =>
                  tx.transaction.type == 'income' &&
                  tx.transaction.accountId == account.id,
            )
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;
    final expense =
        monthTransactions.value
            ?.where(
              (tx) =>
                  tx.transaction.type == 'expense' &&
                  tx.transaction.accountId == account.id,
            )
            .fold<double>(0, (sum, tx) => sum + tx.transaction.amount) ??
        0;

    return CardBalance(
      title:
          '${account.icon} ${account.name} · ${AccountType.values[account.type].label}',
      amount: account.balance,
      subtitle: 'Saldo actual',
      chipItems: [
        ChipItemConfig(
          title: 'este mes entrada',
          description: CurrencyFormatter.withSign(
            income,
            compact: true,
            type: TransactionType.income,
          ),
          colorDescription: Colors.green,
        ),
        ChipItemConfig(
          title: 'este mes salida',
          description: CurrencyFormatter.withSign(
            expense,
            compact: true,
            type: TransactionType.expense,
          ),
          colorDescription: cs.error,
        ),
      ],
    );
  }
}
