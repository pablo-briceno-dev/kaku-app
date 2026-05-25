enum TransactionTypeFilter {
  all,
  income,
  expense,
  transfer,
  byCategory;

  String get label {
    switch (this) {
      case TransactionTypeFilter.all:
        return 'Todos';
      case TransactionTypeFilter.income:
        return 'Ingresos';
      case TransactionTypeFilter.expense:
        return 'Gastos';
      case TransactionTypeFilter.transfer:
        return 'Transferencias';
      case TransactionTypeFilter.byCategory:
        return 'Por categoría';
    }
  }
}