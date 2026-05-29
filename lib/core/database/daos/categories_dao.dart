import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/categories_table.dart';
import 'package:kaku/core/database/tables/transactions_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable, TransactionsTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // Stream de todas las categorías (para pickers y listas)
  Stream<List<Category>> watchAllCategories() => (select(
    categoriesTable,
  )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).watch();

  // Solo categorías de gasto (isIncome = false)
  Stream<List<Category>> watchExpenseCategories() =>
      (select(categoriesTable)
            ..where((c) => c.isIncome.equals(false))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .watch();

  Future<List<Category>> getExpenseCategories() =>
      (select(categoriesTable)
            ..where((c) => c.isIncome.equals(false))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();

  // Solo categorías de ingreso (isIncome = true)
  Stream<List<Category>> watchIncomeCategories() =>
      (select(categoriesTable)
            ..where((c) => c.isIncome.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .watch();

  Future<List<Category>> getIncomeCategories() =>
      (select(categoriesTable)
            ..where((c) => c.isIncome.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();

  // Crear categoría personalizada
  Future<int> insertCategory(CategoriesTableCompanion category) =>
      into(categoriesTable).insert(category);

  // Editar nombre, emoji o color
  Future<bool> updateCategory(Category category) =>
      update(categoriesTable).replace(category);

  // Eliminar solo si no tiene transacciones asociadas (verificar antes en el UI)
  Future<int> deleteCategory(int id) async {
    final count = await (select(
      transactionsTable,
    )..where((t) => t.categoryId.equals(id))).get().then((list) => list.length);

    if (count > 0) return 0;
    return await (delete(categoriesTable)..where((c) => c.id.equals(id))).go();
  }

  Stream<Category?> watchCategoryById(int id) => (select(
    categoriesTable,
  )..where((c) => c.id.equals(id))).watchSingleOrNull();

  Future<void> toggleActive(int id, bool active) =>
      (update(categoriesTable)..where((c) => c.id.equals(id))).write(
        CategoriesTableCompanion(isActive: Value(active)),
      );

  Future<void> reorderCategories(List<int> orderedIds) async {
    await transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(categoriesTable)
              ..where((c) => c.id.equals(orderedIds[i])))
            .write(CategoriesTableCompanion(sortOrder: Value(i)));
      }
    });
  }
}
