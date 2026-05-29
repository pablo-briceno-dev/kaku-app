import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/features/categories/categories_list.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

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

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Categorías'),
        defaultActions: false,
        actions: [
          TextButton(onPressed: _openCreateForm, child: const Text('+ Nueva')),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gastos'),
            Tab(text: 'Ingresos'),
          ],
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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

  void _openCreateForm() {
    AppBottomSheet.show(
      context,
      title: 'Nueva categoría',
      isFullScreen: true,
      child: const SizedBox(), // TODO: CategoryFormSheet()
    );
  }
}
