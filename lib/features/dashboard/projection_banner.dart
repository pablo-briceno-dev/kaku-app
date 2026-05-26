import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class ProjectionBanner extends ConsumerWidget {
  const ProjectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);

    // Solo tiene sentido mostrar el banner en el mes actual.
    // En meses pasados ya sabemos lo que pasó — no hay proyección.
    if (!BudgetCalculator.isCurrentMonth(
      selectedMonth.year,
      selectedMonth.month,
    )) {
      return const SizedBox.shrink();
    }

    final txAsync = ref.watch(monthTransactionsProvider(selectedMonth));
    final budgetAsync = ref.watch(budgetProgressProvider(selectedMonth));

    // Si alguno de los dos providers está cargando o falló, no mostramos nada.
    // El banner es secundario — no vale la pena mostrar un error aquí.
    final transactions = txAsync.value;
    final budgets = budgetAsync.value;
    if (transactions == null || budgets == null) return const SizedBox.shrink();

    // ── Cálculos ──
    final now = DateTime.now();
    final daysElapsed = BudgetCalculator.daysElapsed(now);
    final daysInMonth = BudgetCalculator.daysInMonth(
      selectedMonth.year,
      selectedMonth.month,
    );

    // Total gastado en el mes (solo gastos, no ingresos)
    final totalSpent = transactions
        .where((t) => t.transaction.type == TransactionType.expense.name)
        .fold(0.0, (sum, t) => sum + t.transaction.amount);

    // Si no hay gastos todavía no hay nada que proyectar
    if (totalSpent == 0 || daysElapsed == 0) return const SizedBox.shrink();

    // Promedio diario y proyección al final del mes
    final dailyAvg = BudgetCalculator.dailyAverage(totalSpent, daysElapsed);
    final projection = BudgetCalculator.monthProjection(dailyAvg, daysInMonth);

    // Presupuesto total configurado (suma de todos los límites del mes)
    final totalBudget = budgets.fold(
      0.0,
      (sum, b) => sum + b.budget.limitAmount,
    );

    // Si no hay presupuesto configurado tampoco mostramos nada
    if (totalBudget == 0) return const SizedBox.shrink();

    // ── Decidir qué estado mostrar ──
    final _BannerState bannerState = _resolveBannerState(
      totalSpent: totalSpent,
      totalBudget: totalBudget,
      projection: projection,
      daysElapsed: daysElapsed,
      daysInMonth: daysInMonth,
    );

    // Estado ok con margen amplio: no mostrar nada para no saturar el Dashboard
    if (bannerState == _BannerState.safe) return const SizedBox.shrink();

    return _BannerContent(
      state: bannerState,
      totalSpent: totalSpent,
      totalBudget: totalBudget,
      projection: projection,
      dailyAvg: dailyAvg,
      daysElapsed: daysElapsed,
      daysInMonth: daysInMonth,
    );
  }

  // Determina el estado del banner según los números
  _BannerState _resolveBannerState({
    required double totalSpent,
    required double totalBudget,
    required double projection,
    required int daysElapsed,
    required int daysInMonth,
  }) {
    // Ya se pasó del presupuesto este mes
    if (totalSpent >= totalBudget) return _BannerState.exceeded;

    // La proyección supera el presupuesto
    if (BudgetCalculator.willExceedBudget(projection, totalBudget)) {
      // ¿Qué tan grave es? Si la proyección supera en más del 20% es crítico
      final overRatio = (projection - totalBudget) / totalBudget;
      return overRatio >= 0.20 ? _BannerState.critical : _BannerState.warning;
    }

    // Va bien pero queda poco del mes (últimos 5 días) y ya gastó más del 85%
    final daysLeft = daysInMonth - daysElapsed;
    final spentRatio = totalSpent / totalBudget;
    if (daysLeft <= 5 && spentRatio >= 0.85) return _BannerState.nearEnd;

    return _BannerState.safe;
  }
}

// ── Estados posibles del banner ──
enum _BannerState {
  safe, // Todo bien — no se muestra
  nearEnd, // Quedan pocos días y ya gastaste casi todo el presupuesto
  warning, // La proyección supera el presupuesto (margen < 20%)
  critical, // La proyección supera el presupuesto en más del 20%
  exceeded, // Ya se pasó del presupuesto este mes
}

// ── Widget visual del banner ──
class _BannerContent extends StatelessWidget {
  final _BannerState state;
  final double totalSpent;
  final double totalBudget;
  final double projection;
  final double dailyAvg;
  final int daysElapsed;
  final int daysInMonth;

  const _BannerContent({
    required this.state,
    required this.totalSpent,
    required this.totalBudget,
    required this.projection,
    required this.dailyAvg,
    required this.daysElapsed,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final config = _configFor(state, cs);
    final daysLeft = daysInMonth - daysElapsed;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: config.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: config.borderColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Text(config.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: config.textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _buildMessage(daysLeft),
                    style: TextStyle(
                      fontSize: 12,
                      color: config.textColor.withAlpha(75),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildMessage(int daysLeft) {
    final projStr = CurrencyFormatter.compact(projection);
    final budgStr = CurrencyFormatter.compact(totalBudget);
    final avgStr = CurrencyFormatter.compact(dailyAvg);
    final spentStr = CurrencyFormatter.compact(totalSpent);
    final overStr = CurrencyFormatter.compact(totalSpent - totalBudget);

    return switch (state) {
      _BannerState.exceeded =>
        'Llevas $spentStr gastados y tu límite era $budgStr. '
            'Te pasaste por $overStr este mes.',

      _BannerState.critical =>
        'A este ritmo ($avgStr/día) gastarás $projStr este mes, '
            '${CurrencyFormatter.compact(projection - totalBudget)} más de tu presupuesto.',

      _BannerState.warning =>
        'Al ritmo actual podrías llegar a $projStr este mes '
            'vs tu presupuesto de $budgStr.',

      _BannerState.nearEnd =>
        'Quedan $daysLeft días y ya usaste el '
            '${CurrencyFormatter.percentage((totalSpent / totalBudget) * 100)} '
            'de tu presupuesto.',

      _BannerState.safe => '',
    };
  }

  _BannerConfig _configFor(_BannerState state, ColorScheme cs) {
    return switch (state) {
      _BannerState.exceeded => _BannerConfig(
        icon: '🚨',
        title: 'Presupuesto superado',
        bgColor: cs.error.withAlpha(20),
        borderColor: cs.error.withAlpha(60),
        textColor: cs.error,
      ),
      _BannerState.critical => _BannerConfig(
        icon: '⚠️',
        title: 'Vas a pasarte del presupuesto',
        bgColor: Colors.orange.withAlpha(20),
        borderColor: Colors.orange.withAlpha(60),
        textColor: Colors.orange,
      ),
      _BannerState.warning => _BannerConfig(
        icon: '📊',
        title: 'Revisa tu ritmo de gasto',
        bgColor: Colors.amber.withAlpha(15),
        borderColor: Colors.amber.withAlpha(50),
        textColor: Colors.amber,
      ),
      _BannerState.nearEnd => _BannerConfig(
        icon: '⏳',
        title: 'Casi al límite del mes',
        bgColor: Colors.amber.withAlpha(15),
        borderColor: Colors.amber.withAlpha(50),
        textColor: Colors.amber,
      ),
      _BannerState.safe => _BannerConfig(
        icon: '',
        title: '',
        bgColor: Colors.transparent,
        borderColor: Colors.transparent,
        textColor: Colors.transparent,
      ),
    };
  }
}

// Configuración visual de cada estado
class _BannerConfig {
  final String icon;
  final String title;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _BannerConfig({
    required this.icon,
    required this.title,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}
