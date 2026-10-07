import 'package:flutter/material.dart';
import 'package:kaku/l10n/app_localizations.dart';

enum TransactionTypeFilter { all, income, expense, transfer, byCategory }

extension TransactionTypeFilterL10n on TransactionTypeFilter {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      TransactionTypeFilter.all => l10n.transactionTypeFilterAll,
      TransactionTypeFilter.income => l10n.transactionTypeIncome(count: 2),
      TransactionTypeFilter.expense => l10n.transactionTypeExpense(count: 2),
      TransactionTypeFilter.transfer => l10n.transactionTypeTransfer(count: 2),
      TransactionTypeFilter.byCategory => l10n.transactionTypeFilterByCategory,
    };
  }
}
