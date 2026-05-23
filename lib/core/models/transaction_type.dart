enum TransactionType {
  expense,
  income,
  transfer;

  String get label {
    switch (this) {
      case TransactionType.expense:
        return 'Gasto';
      case TransactionType.income:
        return 'Ingreso';
      case TransactionType.transfer:
        return 'Transferencia';
    }
  }
}
