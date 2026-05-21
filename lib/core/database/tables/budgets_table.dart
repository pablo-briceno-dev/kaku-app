import 'package:drift/drift.dart';
import 'package:kaku/core/database/tables/categories_table.dart';

// genera: Budget + BudgetsTableCompanion
@DataClassName('Budget')
class BudgetsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(CategoriesTable, #id)();
  RealColumn get limitAmount => real()(); // presupuesto mensual
  IntColumn get month => integer()(); // mes actual '1-12'
  IntColumn get year => integer()(); // año actual '2023'
  // si true: lo no gastado pasa al siguiente mes
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();
}
