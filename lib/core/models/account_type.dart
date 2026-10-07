import 'package:flutter/material.dart';
import 'package:kaku/l10n/app_localizations.dart';

enum AccountType {
  cash,
  debit,
  credit,
  savings;

  String get icon {
    switch (this) {
      case AccountType.cash:
        return '💵';
      case AccountType.debit:
        return '💳';
      case AccountType.credit:
        return '🏦';
      case AccountType.savings:
        return '💰';
    }
  }
}

extension AccountTypeL10n on AccountType {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      AccountType.cash => l10n.accountTypeCash,
      AccountType.debit => l10n.accountTypeDebit,
      AccountType.credit => l10n.accountTypeCredit,
      AccountType.savings => l10n.accountTypeSavings,
    };
  }
}
