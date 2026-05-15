import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/budgets_table.dart';
import 'package:kaku/core/database/tables/categories_table.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [BudgetsTable, CategoriesTable])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  // Stream: presupuestos del mes con su categoría (se actualiza reactivamente)
  Stream<List<BudgetWithCategory>> watchBudgetsForMonth(int month, int year) {
    final query = select(budgetsTable)
      ..where((b) => b.month.equals(month) & b.year.equals(year));

    return query
        .join([
          innerJoin(
            categoriesTable,
            categoriesTable.id.equalsExp(budgetsTable.categoryId),
          ),
        ])
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => BudgetWithCategory(
                  budget: row.readTable(budgetsTable), // Budget ✅
                  category: row.readTable(categoriesTable), // Category ✅
                ),
              )
              .toList(),
        );
  }

  // Insertar o actualizar (upsert): si ya existe el presupuesto de esa categoría+mes lo reemplaza
  Future<void> upsertBudget(BudgetsTableCompanion budget) =>
      into(budgetsTable).insertOnConflictUpdate(budget);

  // Eliminar presupuesto
  Future<int> deleteBudget(int id) =>
      (delete(budgetsTable)..where((b) => b.id.equals(id))).go();
}

class BudgetWithCategory {
  final Budget budget;
  final Category category;
  const BudgetWithCategory({required this.budget, required this.category});
}
