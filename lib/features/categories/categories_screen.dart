import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/features/categories/categories_list.dart';
import 'package:kaku/features/categories/category_form_sheet.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(l10n.categoriesTitle(femenine: true)),
        defaultActions: false,
        actions: [
          PremiumGate(
            feature: PremiumFeature.unlimitedCategories,
            showLockBadge: false,
            child: TextButton(
              onPressed: () => _openCreateForm(l10n),
              child: Text('+ ${l10n.btnNew(femenine: true)}'),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: TransactionType.expense.label(l10n, 2)),
            Tab(text: TransactionType.income.label(l10n, 2)),
          ],
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorLoadCategories)),
        data: (categories) => TabBarView(
          controller: _tabController,
          children: [
            // Tab Gastos
            CategoriesList(
              categories: categories.where((c) => !c.isIncome).toList(),
              onReorder: _onReorder,
            ),
            // Tab Ingresos
            CategoriesList(
              categories: categories.where((c) => c.isIncome).toList(),
              onReorder: _onReorder,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onReorder(List<Category> reordered) async {
    final ids = reordered.map((c) => c.id).toList();
    await ref.read(categoriesDaoProvider).reorderCategories(ids);
  }

  void _openCreateForm(AppLocalizations l10n) {
    final categories = ref.watch(allCategoriesProvider).value;

    AppBottomSheet.show(
      context,
      title: l10n.newCategoryTitle,
      isFullScreen: true,
      child: CategoryFormSheet(
        totalCategories: categories?.length ?? 0,
        defaultName: l10n.newCategoryTitle,
      ),
    );
  }
}
