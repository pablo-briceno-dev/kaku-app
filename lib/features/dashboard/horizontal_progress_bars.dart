import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/dashboard/widgets/progress_bar_item.dart';
import 'package:kaku/features/dashboard/widgets/budget_bar_skeleton.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/notification_service.dart';

class HorizontalProgressBars extends ConsumerWidget {
  const HorizontalProgressBars({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final budgetAsync = ref.watch(budgetProgressProvider(selectedMonth));

    return budgetAsync.when(
      loading: () => SizedBox(
        height: ProgressBarItem.fixedHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: 3,
          itemBuilder: (context, _) => const Padding(
            padding: EdgeInsets.only(right: 12),
            child: BudgetBarSkeleton(height: ProgressBarItem.fixedHeight),
          ),
        ),
      ),
      error: (e, _) => SizedBox(
        height: ProgressBarItem.fixedHeight,
        child: Center(
          child: Text(
            'Error al cargar presupuestos',
            style: TextStyle(fontSize: 12, color: cs.error),
          ),
        ),
      ),
      data: (budgetProgress) {
        if (budgetProgress.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: ProgressBarItem.fixedHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: budgetProgress.length,
            itemBuilder: (context, index) {
              final budget = budgetProgress[index];
              if (budget.progress >= 0.8) {
                NotificationService.showBudgetAlert(
                  categoryName: budget.category.name,
                  categoryEmoji: budget.category.emoji,
                  percentage: budget.progress,
                  spent: CurrencyFormatter.compact(budget.spent),
                  limit: CurrencyFormatter.compact(budget.effectiveLimit),
                );
              }
              return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ProgressBarItem(
                      emoji: budget.category.emoji,
                      title: budget.category.name,
                      progress: budget.progress,
                      status: budget.status,
                      onTap: () => context.push(
                        AppRoutes.toCategory(
                          budget.category.id,
                          selectedMonth.month,
                          selectedMonth.year,
                        ),
                      ),
                    ),
                  )
                  .animate(delay: Duration(milliseconds: index * 50))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.04, end: 0, duration: 300.ms);
            },
          ),
        );
      },
    );

    /* 
    BudgetProgress(
            budget: Budget(
              id: 1,
              categoryId: 1,
              limitAmount: 2000,
              month: 5,
              rollover: false,
              year: 2026,
            ),
            category: Category(
              id: 1,
              emoji: '💰',
              name: 'Saldo',
              colorHex: '#FF0000',
              isDefault: true,
              isIncome: false,
            ),
            spent: 100,
          ),
     */
  }
}
