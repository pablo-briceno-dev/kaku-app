import 'package:flutter/material.dart';
import 'package:kaku/core/l10n/category_l10n.dart';
import 'package:kaku/core/l10n/default_category.dart';
import 'package:kaku/l10n/app_localizations.dart';

/// Un segmento de la gráfica de dona.
/// Se construye combinando Category + monto gastado + porcentaje
class CategorySlice {
  final int categoryId;
  final String name;
  final String emoji;
  final Color color;
  final double amount; // monto gastado
  final double percentage; // porcentaje
  final String? systemKey;

  CategorySlice({
    required this.categoryId,
    required this.name,
    required this.emoji,
    required this.color,
    required this.amount,
    required this.percentage,
    this.systemKey,
  });
}

/// Un punto en la gráfica de línea de tendencia mensual
class MonthPoint {
  final int month;
  final int year;
  final double totalExpenses;

  MonthPoint({
    required this.month,
    required this.year,
    required this.totalExpenses,
  });
}

extension CategorySliceX on CategorySlice {
  String localizedName(BuildContext context) {
    final key = systemKey;
    if (key == null) return name;
    final match = DefaultCategory.values.where((c) => c.name == key);
    if (match.isEmpty) return name;
    return match.first.label(AppLocalizations.of(context)!);
  }
}
