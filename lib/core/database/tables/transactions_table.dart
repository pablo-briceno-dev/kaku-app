import 'package:drift/drift.dart';
import 'package:kaku/core/database/tables/accounts_table.dart';
import 'package:kaku/core/database/tables/categories_table.dart';

class TransactionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()(); // siempre positivo
  TextColumn get type => text()(); // expense, income, transfer
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get accountId => integer().references(AccountsTable, #id)();
  IntColumn get categoryId => integer().references(CategoriesTable, #id)();
  TextColumn get receiptPath => text().nullable()(); // path local de la foto
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get tags =>
      text().nullable()(); // JSON: '["vacaciones","trabajo"]'
  DateTimeColumn get cr4eatedAt => dateTime().withDefault(currentDateAndTime)();
}
