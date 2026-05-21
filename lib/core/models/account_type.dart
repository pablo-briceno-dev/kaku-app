enum AccountType {
  cash,
  debit,
  credit,
  savings;

  String get label {
    switch (this) {
      case AccountType.cash:
        return 'Efectivo';
      case AccountType.debit:
        return 'Débito';
      case AccountType.credit:
        return 'Crédito';
      case AccountType.savings:
        return 'Ahorro';
    }
  }

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
