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

  String get labelPlural {
    switch (this) {
      case TransactionType.expense:
        return 'Gastos';
      case TransactionType.income:
        return 'Ingresos';
      case TransactionType.transfer:
        return 'Transferencias';
    }
  }

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
