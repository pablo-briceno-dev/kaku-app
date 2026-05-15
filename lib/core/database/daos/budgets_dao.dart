import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/budgets_table.dart';
import 'package:kaku/core/database/tables/categories_table.dart';

@DriftAccessor(tables: [BudgetsTable, CategoriesTable])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);
}