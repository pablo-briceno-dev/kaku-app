import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/budget_progress.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';
import 'budget_form_sheet.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final cs = Theme.of(context).colorScheme;

    // Stream de presupuestos del mes actual con su categoría
    final budgetsAsync = ref.watch(budgetProgressProvider(selectedMonth));

    // Todas las categorías de gasto para mostrar las que
    // aún no tienen presupuesto configurado
    final allCatsAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: CustomAppBar(title: const Text('Presupuestos')),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) => allCatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const SizedBox.shrink(),
          data: (allCats) {
            // Mapa categoryId → BudgetProgress para acceso rápido
            final budgetMap = {for (final b in budgets) b.category.id: b};

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // ── Encabezado del mes ──
                _MonthHeader(month: selectedMonth),
                const SizedBox(height: 16),

                // ── Resumen total ──
                if (budgets.isNotEmpty) _BudgetSummaryCard(budgets: budgets),

                const SizedBox(height: 20),

                Text(
                  'CATEGORÍAS',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.12,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Lista de categorías ──
                ...allCats.map((cat) {
                  final budget = budgetMap[cat.id];
                  return _CategoryBudgetTile(
                    category: cat,
                    budgetProgress: budget,
                    month: selectedMonth.month,
                    year: selectedMonth.year,
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Encabezado del mes ───────────────────────────────────────
class _MonthHeader extends StatelessWidget {
  final ({int month, int year}) month;
  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    final months = const [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return Text(
      '${months[month.month - 1]} ${month.year}',
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

// ── Tarjeta resumen total de presupuestos ────────────────────
class _BudgetSummaryCard extends StatelessWidget {
  final List<BudgetProgress> budgets;
  const _BudgetSummaryCard({required this.budgets});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalLimit = budgets.fold(0.0, (s, b) => s + b.budget.limitAmount);
    final totalSpent = budgets.fold(0.0, (s, b) => s + b.spent);
    final remaining = totalLimit - totalSpent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                label: 'Presupuesto total',
                value: CurrencyFormatter.compact(totalLimit),
                color: cs.onSurface,
              ),
              _SummaryItem(
                label: 'Gastado',
                value: CurrencyFormatter.compact(totalSpent),
                color: cs.error,
                align: TextAlign.center,
              ),
              _SummaryItem(
                label: 'Disponible',
                value: CurrencyFormatter.compact(remaining.abs()),
                color: remaining >= 0 ? cs.primary : cs.error,
                align: TextAlign.end,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso total
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (totalSpent / totalLimit).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                totalSpent > totalLimit ? cs.error : cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final TextAlign align;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: align == TextAlign.start
          ? CrossAxisAlignment.start
          : align == TextAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Ítem de categoría con su presupuesto ─────────────────────
class _CategoryBudgetTile extends ConsumerWidget {
  final Category category;
  final BudgetProgress? budgetProgress;
  final int month;
  final int year;

  const _CategoryBudgetTile({
    required this.category,
    required this.month,
    required this.year,
    this.budgetProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final hasBudget = budgetProgress != null;
    final catColor = Color(
      int.parse(category.colorHex.replaceFirst('#', 'FF'), radix: 16),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _openForm(context, ref),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: hasBudget
                  ? catColor.withValues(alpha: 0.25)
                  : cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Ícono
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Límite o "Sin límite"
                  if (hasBudget)
                    Text(
                      CurrencyFormatter.format(
                        budgetProgress!.budget.limitAmount,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: catColor,
                      ),
                    )
                  else
                    Text(
                      'Sin límite',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),

                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 18,
                  ),
                ],
              ),

              // Barra de progreso (solo si tiene presupuesto)
              if (hasBudget) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: budgetProgress!.progress.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      _barColor(budgetProgress!.status, cs),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gastado: ${CurrencyFormatter.compact(budgetProgress!.spent)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      budgetProgress!.remaining >= 0
                          ? 'Quedan ${CurrencyFormatter.compact(budgetProgress!.remaining)}'
                          : 'Excedido ${CurrencyFormatter.compact(budgetProgress!.remaining.abs())}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: budgetProgress!.remaining >= 0
                            ? cs.onSurfaceVariant
                            : cs.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _barColor(BudgetStatus status, ColorScheme cs) => switch (status) {
    BudgetStatus.ok => cs.primary,
    BudgetStatus.warning => Colors.amber,
    BudgetStatus.overBudget => cs.error,
  };

  Future<void> _openForm(BuildContext context, WidgetRef ref) async {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final budgetsAsync = ref.watch(budgetProgressProvider(selectedMonth));
    final blocked = await PremiumLimitChecker.check(
      context: context,
      feature: PremiumFeature.unlimitedBudgets,
      currentCount: budgetsAsync.when(
        data: (budgets) => budgets.length,
        error: (e, _) => 0,
        loading: () => 0,
      ),
      limit: PremiumLimits.maxBudgets,
    );
    if (blocked) return;
    if (context.mounted) {
      final saved = await AppBottomSheet.show<bool>(
        context,
        title: budgetProgress != null
            ? 'Editar presupuesto'
            : 'Nuevo presupuesto',
        subtitle: '${category.emoji} ${category.name}',
        child: BudgetFormSheet(
          category: category,
          month: month,
          year: year,
          existingBudget: budgetProgress?.budget,
        ),
      );

      // El stream de budgetProgressProvider se actualiza solo
      // cuando se guarda — no hay que hacer nada aquí.
      if (saved == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Presupuesto guardado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Provider adicional que necesitas agregar en database_provider.dart
// ─────────────────────────────────────────────────────────────
//
//  // Stream de categorías de gasto para la lista de presupuestos
//  final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
//    return ref.watch(categoriesDaoProvider).watchExpenseCategories();
//  });
//
//  // En CategoriesDao agrega este método si no lo tienes:
//  Stream<List<Category>> watchExpenseCategories() =>
//      (select(categoriesTable)
//        ..where((c) => c.isIncome.equals(false)))
//      .watch();
