import 'package:kaku/core/database/app_database.dart';

// Combina un presupuesto, su categoría y el gasto real del mes.
// Se construye en el provider combinando BudgetsDao + TransactionsDao
class BudgetProgress {
  final Budget budget; // límite y mes - de BudgetsTable
  final Category category; // emoji, nombre, color - de CategoriesTable
  final double spent; // gasto real calculado desde TransactionsTable

  const BudgetProgress({
    required this.budget,
    required this.category,
    required this.spent,
  });

  // Getters de conveniencia (úsalos directo en el widget)

  // Cuánto queda disponible (puede ser negativo si pasó el límite)
  double get remaining => budget.limitAmount - spent;

  // Progreso entre 0.0 y 1.0 (1.0 = 100%, puede superar 1.0 si se excedió)
  double get progress {
    if (budget.limitAmount <= 0) return 0.0;
    return spent / budget.limitAmount;
  }

  // Porcentaje legible: "72%" o "105%" si se excedió
  String get percentageLabel => '${(progress * 100).toStringAsFixed(0)}%';

  // Estado semáforo para colorear la barra en el widget
  BudgetStatus get status {
    if (progress >= 1.0) return BudgetStatus.overBudget;
    if (progress >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.ok;
  }
}

enum BudgetStatus {
  ok, // <= 80% -> color normal (verde/acento)
  warning, // 80-99% -> amarillo
  overBudget, // >= 100% -> rojo
}
