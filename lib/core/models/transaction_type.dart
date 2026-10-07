import 'package:flutter/material.dart';
import 'package:kaku/l10n/app_localizations.dart';

enum TransactionType {
  expense,
  income,
  transfer;

  Color get color {
    switch (this) {
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.income:
        return Color(0xFF6ADF9A);
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  String get prefix {
    switch (this) {
      case TransactionType.expense:
        return '-';
      case TransactionType.income:
        return '+';
      case TransactionType.transfer:
        return '';
    }
  }
}

extension TransactionTypeL10n on TransactionType {
  String label(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case TransactionType.expense:
        return l10n.transactionTypeExpense(count: count);
      case TransactionType.income:
        return l10n.transactionTypeIncome(count: count);
      case TransactionType.transfer:
        return l10n.transactionTypeTransfer(count: count);
    }
  }
}
