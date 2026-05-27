import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/models/stats_models.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/shared/providers/database_provider.dart';

/// Lista de CategorySlice para la dona.
/// Combina los gastos por categoría con los datos de la categoría (color, nombre)
final categorySlicesProvider = FutureProvider.autoDispose
    .family<List<CategorySlice>, ({int month, int year})>((ref, params) async {
      final txDao = ref.watch(transactionsDaoProvider);
      final catDao = ref.watch(categoriesDaoProvider);

      // Gastos por categoría del mes
      final expenseMap = await txDao.getExpensesByCategory(
        params.month,
        params.year,
      );
      if (expenseMap.isEmpty) return [];

      // Porcentajes calculados
      final percentages = BudgetCalculator.categoryPercentages(expenseMap);

      // Categorías para obtener nombre, emoji y color
      final categories = await catDao.getExpenseCategories();
      final catMap = {for (final c in categories) c.id: c};

      return expenseMap.entries.where((e) => catMap.containsKey(e.key)).map(
        (e) {
          final cat = catMap[e.key]!;
          return CategorySlice(
            categoryId: cat.id,
            name: cat.name,
            emoji: cat.emoji,
            color: hexToColor(cat.colorHex),
            amount: e.value,
            percentage: percentages[e.key] ?? 0,
          );
        },
      ).toList()..sort((a, b) => a.amount.compareTo(b.amount)); // mayor a menor
    });

/// Datos diarios para el BarChart
final dailyExpensesProvider = FutureProvider.autoDispose
    .family<Map<int, double>, ({int month, int year})>((ref, params) async {
      final txDao = ref.watch(transactionsDaoProvider);
      final txs = await txDao
          .watchMonthTransactions(params.month, params.year)
          .first;
      final expenses = txs
          .where((t) => t.transaction.type == TransactionType.expense.name)
          .map((t) => (date: t.transaction.date, amount: t.transaction.amount))
          .toList();
      return BudgetCalculator.dailyExpensesMap(expenses);
    });

/// Tendencia de los últimos 6 meses para el LineChart
final sixMonthTrendProvider = FutureProvider.autoDispose
    .family<List<MonthPoint>, ({int month, int year})>((ref, params) async {
      final txDao = ref.watch(transactionsDaoProvider);
      final monthLabels = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      final points = <MonthPoint>[];
      var current = (month: params.month, year: params.year);

      for (var i = 0; i < 6; i++) {
        final total = await txDao.getTotalExpenses(current.month, current.year);
        points.insert(
          0,
          MonthPoint(
            month: current.month,
            year: current.year,
            totalExpenses: total,
            label: monthLabels[current.month - 1],
          ),
        );
        current = BudgetCalculator.previousMonth(current.year, current.month);
      }

      return points;
    });
