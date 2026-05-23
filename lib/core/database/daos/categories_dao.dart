import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // Stream de todas las categorías (para pickers y listas)
  Stream<List<Category>> watchAllCategories() => // Category ✅
      select(categoriesTable).watch();

  // Solo categorías de gasto (isIncome = false)
  Future<List<Category>> getExpenseCategories() =>
      (select(categoriesTable)..where((c) => c.isIncome.equals(false))).get();

  // Solo categorías de ingreso (isIncome = true)
  Future<List<Category>> getIncomeCategories() =>
      (select(categoriesTable)..where((c) => c.isIncome.equals(true))).get();

  // Crear categoría personalizada
  Future<int> insertCategory(CategoriesTableCompanion category) =>
      into(categoriesTable).insert(category);

  // Editar nombre, emoji o color
  Future<bool> updateCategory(Category category) =>
      update(categoriesTable).replace(category);

  // Eliminar solo si no tiene transacciones asociadas (verificar antes en el UI)
  Future<int> deleteCategory(int id) =>
      (delete(categoriesTable)..where((c) => c.id.equals(id))).go();

  Stream<Category?> watchCategoryById(int id) => (select(
    categoriesTable,
  )..where((c) => c.id.equals(id))).watchSingleOrNull();
}
