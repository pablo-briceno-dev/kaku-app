import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
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

  // Stream: presupuesto del mes de una categoría
  Stream<BudgetWithCategory?> watchBudgetForMonthByCategory(
    int month,
    int year,
    int categoryId,
  ) {
    final query = select(budgetsTable)
      ..where(
        (b) =>
            b.month.equals(month) &
            b.year.equals(year) &
            b.categoryId.equals(categoryId),
      );

    return query
        .join([
          innerJoin(
            categoriesTable,
            categoriesTable.id.equalsExp(budgetsTable.categoryId),
          ),
        ])
        .watchSingleOrNull()
        .map(
          (row) => row == null
              ? null
              : BudgetWithCategory(
                  budget: row.readTable(budgetsTable),
                  category: row.readTable(categoriesTable),
                ),
        );
  }

  // Insertar o actualizar (upsert): si ya existe el presupuesto de esa categoría+mes lo reemplaza
  Future<void> upsertBudget(BudgetsTableCompanion budget) =>
      into(budgetsTable).insertOnConflictUpdate(budget);

  // Eliminar presupuesto
  Future<int> deleteBudget(int id) =>
      (delete(budgetsTable)..where((b) => b.id.equals(id))).go();

  Future<double> getEffectiveLimit({
    required int categoryId,
    required int month,
    required int year,
    required double baseLimit,
    required bool rollover,
    required TransactionsDao txDao,
  }) async {
    if (!rollover) return baseLimit;

    // Busca el presupuesto del mes anterior
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;

    final prevBudget =
        await (select(budgetsTable)..where(
              (b) =>
                  b.categoryId.equals(categoryId) &
                  b.month.equals(prevMonth) &
                  b.year.equals(prevYear),
            ))
            .getSingleOrNull();

    if (prevBudget == null) return baseLimit;

    // Calcula lo gastado el mes anterior
    final prevSpent = await txDao.getTotalExpensesByCategory(
      categoryId: categoryId,
      month: prevMonth,
      year: prevYear,
    );

    // Sobrante = límite anterior - gastado anterior
    // Puede ser positivo (sobró) o negativo (se pasó)
    final leftover = prevBudget.limitAmount - prevSpent;

    // El nuevo límite efectivo nunca puede ser menor a 0
    return (baseLimit + leftover).clamp(0, double.infinity);
  }
}

class BudgetWithCategory {
  final Budget budget;
  final Category category;
  const BudgetWithCategory({required this.budget, required this.category});
}
