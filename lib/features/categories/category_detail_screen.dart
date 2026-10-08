import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/l10n/category_l10n.dart';
import 'package:kaku/core/models/budget_progress.dart';
import 'package:kaku/features/categories/category_form_sheet.dart';
import 'package:kaku/features/categories/mini_stats_by_category.dart';
import 'package:kaku/features/categories/transaction_list_by_category.dart';
import 'package:kaku/features/categories/widgets/card_budget_category.dart';
import 'package:kaku/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: categoryAsync.when(
          data: (category) => Text(
            category != null
                ? '${category.emoji} ${category.displayName(context)}'
                : '${l10n.categoriesTitle(femenine: false)} $id',
          ),
          error: (e, _) => Text('${l10n.categoriesTitle(femenine: false)} $id'),
          loading: () => Text('${l10n.categoriesTitle(femenine: false)}...'),
        ),
        actions: categoryAsync.when(
          data: (category) {
            if (category != null) {
              return [
                IconButton(
                  onPressed: () => AppBottomSheet.show(
                    context,
                    title: l10n.editCategoryTitle,
                    isFullScreen: true,
                    child: CategoryFormSheet(category: category),
                  ),
                  icon: const Icon(Icons.edit),
                ),
              ];
            }
            return [];
          },
          error: (_, _) => [],
          loading: () => [],
        ),
      ),
      body: categoryAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => const SizedBox.shrink(),
        data: (category) {
          if (category == null) {
            return const ContentWidgetEmpty(
              title: l10n.categoriesTitle(femenine: false),
              message: l10n.categoryNotFound,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                const SizedBox(height: 16),
                TransactionListByCategory(categoryId: id),
              ],
            ),
          );
        },
      ),
    );
  }
}
