import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/budget_progress.dart';
import 'package:kaku/features/categories/category_form_sheet.dart';
import 'package:kaku/features/categories/mini_stats_by_category.dart';
import 'package:kaku/features/categories/widgets/card_budget_category.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final int id;
  final int month;
  final int year;

  const CategoryDetailScreen({
    super.key,
    required this.id,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryByIdProvider(id));
    final selectedMonth = ref.watch(selectedMonthProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: categoryAsync.when(
          data: (category) => Text(
            category != null
                ? '${category.emoji} ${category.name}'
                : 'Categoría $id',
          ),
          error: (e, _) => Text('Categoría $id'),
          loading: () => const Text('Categoría...'),
        ),
        actions: categoryAsync.when(
          data: (category) {
            if (category != null) {
              return [
                IconButton(
                  onPressed: () => AppBottomSheet.show(
                    context,
                    title: 'Editar categoría',
                    isFullScreen: true,
                    child: CategoryFormSheet(category: category),
                  ),
                  icon: const Icon(Icons.edit),
                ),
              ];
            }
            return [];
          },
          error: (_, __) => [],
          loading: () => [],
        ),
      ),
      body: categoryAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => const SizedBox.shrink(),
        data: (category) {
          if (category == null) {
            return const ContentWidgetEmpty(
              title: 'Categoría',
              message: 'Categoría no encontrada',
            );
          }
          final budgetProgress = ref.watch(
            budgetProgressProviderByCategory((
              categoryId: id,
              month: selectedMonth.month,
              year: selectedMonth.year,
            )),
          );
          var limit = 0.0;
          var spent = 0.0;
          var budgetStatus = BudgetStatus.ok;
          budgetProgress.whenData((budget) {
            limit = budget?.budget != null ? budget!.budget.limitAmount : 0.0;
            spent = budget?.spent ?? 0.0;
            if (budget != null) budgetStatus = budget.status;
          });

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CardBudgetCategory(
                  limit: limit,
                  spent: spent,
                  month: selectedMonth.month,
                  currency: currency,
                  status: budgetStatus,
                ),
                const SizedBox(height: 16),
                MiniStatsByCategory(categoryId: id),
              ],
            ),
          );
        },
      ),
    );
  }
}
