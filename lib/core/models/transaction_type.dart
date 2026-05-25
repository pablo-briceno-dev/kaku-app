import 'package:flutter/material.dart';

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

  Color get color {
    switch (this) {
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.income:
        return Colors.green;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }
}
