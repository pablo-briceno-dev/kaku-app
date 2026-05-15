import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/accounts_table.dart';
import 'package:kaku/core/database/tables/categories_table.dart';
import 'package:kaku/core/database/tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [TransactionsTable, CategoriesTable, AccountsTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  // WATCH: stream reactivo de transacciones del mes
  Stream<List<TransactionWithCategory>> watchMonthTransactions(
    int month,
    int year,
  ) {
    final query =
        (select(transactionsTable)..where(
            (t) => t.date.isBetweenValues(
              DateTime(year, month, 1),
              DateTime(year, month + 1, 0, 23, 59),
            ),
          ))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query
        .join([
          leftOuterJoin(
            categoriesTable,
            categoriesTable.id.equalsExp(transactionsTable.categoryId),
          ),
        ])
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => TransactionWithCategory(
                  transaction: row.readTable(transactionsTable),
                  category: row.readTableOrNull(categoriesTable),
                ),
              )
              .toList(),
        );
  }
}

// Clase de resultado typesafe para JOIN ──
class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;
  const TransactionWithCategory({required this.transaction, this.category});
}