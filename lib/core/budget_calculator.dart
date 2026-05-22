import 'package:kaku/core/models/budget_progress.dart';
import 'package:kaku/core/models/transaction_type.dart';

class BudgetCalculator {
  // ════════════════════════════════════════════════════
  //  SECCIÓN 1 — BALANCE Y CUENTAS
  //  Usadas en: DashboardScreen, AccountsScreen, AccountsDao
  // ════════════════════════════════════════════════════

  /// Calcula el balance neto de una cuenta en un período.
  /// Usado en AccountsDao.updateBalance() cada vez que se inserta
  /// una transacción. También para mostrar el saldo en AccountsScreen.
  ///
  /// [initialBalance] : saldo guardado en AccountsTable.balance
  /// [totalIncome]    : suma de transacciones tipo 'income' del período
  /// [totalExpenses]  : suma de transacciones tipo 'expense' del período
  ///
  /// Ejemplo: balance(500_000, 4_200_000, 1_719_500) → 2_980_500
  static double balance({
    required double initialBalance,
    required double totalIncome,
    required double totalExpenses,
  }) => initialBalance + totalIncome - totalExpenses;

  /// Balance total consolidado de múltiples cuentas.
  /// Usado en watchTotalBalance() del AccountsDao y en la
  /// tarjeta principal del DashboardScreen y AccountsScreen.
  ///
  /// Ejemplo: totalBalance([340_500, 1_820_000, 320_000]) → 2_480_500
  static double totalBalance(List<double> accountBalances) =>
      accountBalances.fold(0.0, (sum, b) => sum + b);

  /// Delta de balance al aplicar una transacción.
  /// Útil para calcular cuánto cambiar AccountsTable.balance
  /// sin tener que recalcular todo desde cero.
  ///
  /// [type]   : 'income' | 'expense' | 'transfer'
  /// [amount] : siempre positivo (la dirección la da el type)
  ///
  /// Ejemplo: balanceDelta('expense', 32_000) → -32_000
  /// Ejemplo: balanceDelta('income',  4_200_000) → +4_200_000
  static double balanceDelta(TransactionType type, double amount) {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        return 0; // transfer: se maneja en los dos lados por separado
    }
  }

  // ════════════════════════════════════════════════════
  //  SECCIÓN 2 — PRESUPUESTO POR CATEGORÍA
  //  Usadas en: DashboardScreen (barras), BudgetProgress model,
  //             StatsScreen (dona), CategoryDetailScreen
  // ════════════════════════════════════════════════════

  /// Progreso de un presupuesto como valor entre 0.0 y 1.5.
  /// 1.0 = 100% (límite justo), > 1.0 = pasó el límite.
  /// Se clampea en 1.5 para que la barra no se desborde visualmente.
  ///
  /// Usado en BudgetProgress.progress y en las barras del Dashboard.
  ///
  /// Ejemplo: budgetProgress(720, 1_000) → 0.72  (72%)
  /// Ejemplo: budgetProgress(1_200, 1_000) → 1.2  (120%, over budget)
  static double budgetProgress(double spent, double limit) {
    if (limit <= 0) return 0.0;
    return (spent / limit).clamp(0.0, 1.5);
  }

  /// Estado semáforo de un presupuesto según su progreso.
  /// Usado para colorear la barra: verde / amarillo / rojo.
  ///
  /// [progress] : resultado de budgetProgress() (0.0 – 1.5)
  ///
  /// Ejemplo: statusForProgress(0.72)  → BudgetStatus.ok
  /// Ejemplo: statusForProgress(0.85)  → BudgetStatus.warning
  /// Ejemplo: statusForProgress(1.05)  → BudgetStatus.overBudget
  static BudgetStatus statusForProgress(double progress) {
    if (progress >= 1.0) return BudgetStatus.overBudget;
    if (progress >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.ok;
  }

  /// Dinero restante antes de llegar al límite.
  /// Puede ser negativo si se superó el presupuesto.
  /// Usado en CategoryDetailScreen ("Te quedan $120.000").
  ///
  /// Ejemplo: remainingBudget(720_000, 1_000_000) →  280_000
  /// Ejemplo: remainingBudget(1_200_000, 1_000_000) → -200_000 (excedido)
  static double remainingBudget(double spent, double limit) => limit - spent;

  /// Porcentaje formateado como String para mostrar en la UI.
  /// Usado en las etiquetas de las barras del Dashboard y en BudgetProgress.
  ///
  /// Ejemplo: percentageLabel(0.72) → "72%"
  /// Ejemplo: percentageLabel(1.05) → "105%"
  static String percentageLabel(double progress) =>
      '${(progress * 100).toStringAsFixed(0)}%';

  // ════════════════════════════════════════════════════
  //  SECCIÓN 3 — ANÁLISIS MENSUAL
  //  Usadas en: StatsScreen, DashboardScreen (tarjeta de balance)
  // ════════════════════════════════════════════════════

  /// Tasa de ahorro del mes como porcentaje.
  /// Responde: "¿Qué porcentaje de lo que gané guardé?"
  /// Usado en StatsScreen y en el chip del DashboardScreen.
  ///
  /// Resultado negativo = gasté más de lo que gané.
  /// La regla de oro personal finance es ≥ 20%.
  ///
  /// Ejemplo: savingsRate(4_200_000, 1_719_500) → 59.06%
  /// Ejemplo: savingsRate(1_000_000, 1_200_000) → -20.0% (déficit)
  static double savingsRate(double income, double expenses) {
    if (income <= 0) return 0.0;
    return ((income - expenses) / income) * 100;
  }

  /// Etiqueta de texto para la tasa de ahorro.
  /// Usado debajo del porcentaje en StatsScreen.
  ///
  /// Ejemplo: savingsRateLabel(59.0) → "Buen mes 🎉"
  /// Ejemplo: savingsRateLabel(12.0) → "Puedes mejorar"
  /// Ejemplo: savingsRateLabel(-5.0) → "Gastaste más de lo que ganaste"
  static String savingsRateLabel(double rate) {
    if (rate < 0) return 'Gastaste más de lo que ganaste';
    if (rate < 20) return 'Puedes mejorar';
    if (rate < 50) return 'Vas bien 👍';
    return 'Buen mes 🎉';
  }

  /// Variación porcentual entre el gasto de este mes y el anterior.
  /// Resultado positivo = gasté más este mes (malo → rojo en UI).
  /// Resultado negativo = gasté menos este mes (bueno → verde en UI).
  /// Usado en StatsScreen, sección "Mes vs anterior".
  ///
  /// Ejemplo: monthVariation(1_719_500, 1_950_000) → -11.82%  (gastaste menos ↓)
  /// Ejemplo: monthVariation(2_100_000, 1_950_000) →  +7.69%  (gastaste más ↑)
  static double monthVariation(double current, double previous) {
    if (previous <= 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  /// Suma de gastos agrupados por día del mes.
  /// Devuelve un Map donde la clave es el día (1–31) y el valor es el total gastado.
  /// Usado en el BarChart de gastos diarios en StatsScreen.
  ///
  /// [transactions] : lista de transacciones del mes (solo 'expense')
  ///
  /// Ejemplo: dailyExpensesMap([tx(día:1, 32k), tx(día:1, 15k), tx(día:3, 89k)])
  ///          → {1: 47_000, 3: 89_000}
  static Map<int, double> dailyExpensesMap(
    List<({DateTime date, double amount})> transactions,
  ) {
    final Map<int, double> result = {};
    for (final tx in transactions) {
      final day = tx.date.day;
      result[day] = (result[day] ?? 0.0) + tx.amount;
    }
    return result;
  }

  /// Porcentaje de cada categoría sobre el total de gastos del mes.
  /// Devuelve un Map {categoryId → porcentaje}.
  /// Usado para pintar la gráfica de dona en StatsScreen.
  ///
  /// Ejemplo: categoryPercentages({1: 650_000, 2: 430_000, 3: 290_000})
  ///          → {1: 47.1, 2: 31.2, 3: 21.0} (suman ~100)
  static Map<int, double> categoryPercentages(
    Map<int, double> expensesByCategory,
  ) {
    final total = expensesByCategory.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return {};
    return expensesByCategory.map(
      (id, amount) => MapEntry(id, (amount / total) * 100),
    );
  }

  // ════════════════════════════════════════════════════
  //  SECCIÓN 4 — PROYECCIONES Y ALERTAS
  //  Usadas en: DashboardScreen (alerta de proyección),
  //             StatsScreen (insight de gasto diario)
  // ════════════════════════════════════════════════════

  /// Gasto diario promedio hasta hoy en el mes.
  /// Usado para mostrar "Promedio: $57.300/día" en StatsScreen
  /// y para calcular la proyección del mes.
  ///
  /// Ejemplo: dailyAverage(1_146_000, 20) → 57_300.0
  static double dailyAverage(double totalExpenses, int daysElapsed) {
    if (daysElapsed <= 0) return 0.0;
    return totalExpenses / daysElapsed;
  }

  /// Proyección de gasto total al finalizar el mes,
  /// asumiendo que el ritmo actual se mantiene.
  /// Usado en DashboardScreen para el banner de alerta:
  /// "A este ritmo gastarás $1.770.300 este mes".
  ///
  /// Ejemplo: monthProjection(57_300, 31) → 1_776_300.0
  static double monthProjection(double dailyAvg, int daysInMonth) =>
      dailyAvg * daysInMonth;

  /// ¿La proyección supera el presupuesto total del mes?
  /// Devuelve true si se espera exceder el límite.
  /// Usado para mostrar u ocultar el banner de alerta en el Dashboard.
  ///
  /// [projection]    : resultado de monthProjection()
  /// [totalBudget]   : suma de todos los BudgetsTable.limitAmount del mes
  ///
  /// Ejemplo: willExceedBudget(1_776_300, 1_500_000) → true  ⚠️
  /// Ejemplo: willExceedBudget(1_200_000, 1_500_000) → false ✅
  static bool willExceedBudget(double projection, double totalBudget) =>
      projection > totalBudget;

  /// Cuántos días del mes han transcurrido hasta hoy.
  /// Usado como parámetro de dailyAverage() y monthProjection().
  ///
  /// Ejemplo: daysElapsed(DateTime(2026, 5, 20)) → 20
  static int daysElapsed(DateTime now) => now.day;

  /// Total de días del mes dado.
  /// Considera años bisiestos automáticamente (DateTime lo maneja).
  ///
  /// Ejemplo: daysInMonth(2026, 5)  → 31
  /// Ejemplo: daysInMonth(2024, 2)  → 29 (bisiesto)
  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  // ════════════════════════════════════════════════════
  //  SECCIÓN 5 — METAS DE AHORRO
  //  Usadas en: GoalsScreen (tarjetas de progreso y estimación)
  // ════════════════════════════════════════════════════

  /// Progreso de una meta de ahorro como valor entre 0.0 y 1.0.
  /// Se clampea en 1.0 porque savedAmount no puede superar targetAmount.
  /// Usado en la barra de progreso de cada tarjeta en GoalsScreen.
  ///
  /// Ejemplo: goalProgress(780_000, 1_200_000) → 0.65  (65%)
  static double goalProgress(double saved, double target) {
    if (target <= 0) return 0.0;
    return (saved / target).clamp(0.0, 1.0);
  }

  /// Dinero que aún falta para completar la meta.
  /// Usado en el subtítulo de las tarjetas: "Faltan $420.000".
  ///
  /// Ejemplo: goalRemaining(780_000, 1_200_000) → 420_000.0
  static double goalRemaining(double saved, double target) =>
      (target - saved).clamp(0.0, target);

  /// Estimación de meses para completar la meta al ritmo de ahorro actual.
  /// Devuelve null si no hay historial de ahorro (no se puede estimar).
  /// Usado en GoalsScreen para mostrar "Estimado: 5 meses".
  ///
  /// [remaining]          : resultado de goalRemaining()
  /// [avgMonthlySavings]  : promedio de (ingresos - gastos) de los últimos 3 meses
  ///
  /// Ejemplo: estimatedMonths(420_000, 140_000) → 3.0 meses
  /// Ejemplo: estimatedMonths(420_000, 0)       → null (no hay ahorro)
  static double? estimatedMonths(double remaining, double avgMonthlySavings) {
    if (avgMonthlySavings <= 0) return null;
    return remaining / avgMonthlySavings;
  }

  /// Fecha estimada de completar la meta.
  /// Devuelve null si estimatedMonths() devuelve null.
  /// Usado en GoalsScreen para mostrar "Meta: enero 2027".
  ///
  /// Ejemplo: estimatedDate(DateTime(2026,5,1), 3.0) → DateTime(2026, 8, 1)
  static DateTime? estimatedDate(DateTime from, double? months) {
    if (months == null) return null;
    final totalMonths = from.month + months.ceil();
    final years = from.year + (totalMonths / 12).floor();
    final month = totalMonths % 12 == 0 ? 12 : totalMonths % 12;
    return DateTime(years, month, 1);
  }

  /// Promedio de ahorro mensual de los últimos N meses.
  /// Se usa como entrada de estimatedMonths().
  /// Usado en GoalsScreen para calcular la estimación de todas las metas.
  ///
  /// [monthlySurpluses] : lista de (ingresos - gastos) de cada mes pasado
  ///
  /// Ejemplo: avgMonthlySavings([500_000, 600_000, 400_000]) → 500_000.0
  static double avgMonthlySavings(List<double> monthlySurpluses) {
    if (monthlySurpluses.isEmpty) return 0.0;
    final positiveSurpluses = monthlySurpluses.where((s) => s > 0).toList();
    if (positiveSurpluses.isEmpty) return 0.0;
    return positiveSurpluses.reduce((a, b) => a + b) / positiveSurpluses.length;
  }

  // ════════════════════════════════════════════════════
  //  SECCIÓN 6 — UTILIDADES DE FECHA
  //  Usadas en: todos los providers que filtran por mes/año,
  //             TransactionsDao, BudgetsDao
  // ════════════════════════════════════════════════════

  /// Primer instante del mes (para queries de rango en Drift).
  /// Ejemplo: startOfMonth(2026, 5) → DateTime(2026, 5, 1, 0, 0, 0)
  static DateTime startOfMonth(int year, int month) => DateTime(year, month, 1);

  /// Último instante del mes (para queries de rango en Drift).
  /// El truco DateTime(year, month+1, 0) devuelve el último día del mes actual.
  /// Ejemplo: endOfMonth(2026, 5) → DateTime(2026, 5, 31, 23, 59, 59)
  static DateTime endOfMonth(int year, int month) =>
      DateTime(year, month + 1, 0, 23, 59, 59);

  /// Mes y año del mes anterior al dado.
  /// Devuelve un record ({month, year}) para pasar a los providers.
  /// Usado en StatsScreen para comparar con el mes anterior.
  ///
  /// Ejemplo: previousMonth(2026, 1) → (month: 12, year: 2025)
  /// Ejemplo: previousMonth(2026, 5) → (month:  4, year: 2026)
  static ({int month, int year}) previousMonth(int year, int month) {
    if (month == 1) return (month: 12, year: year - 1);
    return (month: month - 1, year: year);
  }

  /// Mes y año del mes siguiente al dado.
  /// Usado para el selector ← Mayo → del Dashboard.
  ///
  /// Ejemplo: nextMonth(2025, 12) → (month: 1, year: 2026)
  /// Ejemplo: nextMonth(2026, 5)  → (month: 6, year: 2026)
  static ({int month, int year}) nextMonth(int year, int month) {
    if (month == 12) return (month: 1, year: year + 1);
    return (month: month + 1, year: year);
  }

  /// ¿El par mes/año es el mes actual?
  /// Usado en el Dashboard para deshabilitar el botón "→" si ya estás en el mes actual.
  ///
  /// Ejemplo: isCurrentMonth(2026, 5) → true  (si hoy es mayo 2026)
  static bool isCurrentMonth(int year, int month) {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}
