import 'package:flutter/material.dart';

/// Un segmento de la gráfica de dona.
/// Se construye combinando Category + monto gastado + porcentaje
class CategorySlice {
  final int categoryId;
  final String name;
  final String emoji;
  final Color color;
  final double amount; // monto gastado
  final double percentage; // porcentaje

  CategorySlice({
    required this.categoryId,
    required this.name,
    required this.emoji,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

/// Un punto en la gráfica de línea de tendencia mensual
class MonthPoint {
  final int month;
  final int year;
  final double totalExpenses;
  final String label; // 'Ene', 'Feb', etc

  MonthPoint({
    required this.month,
    required this.year,
    required this.totalExpenses,
    required this.label,
  });
}
