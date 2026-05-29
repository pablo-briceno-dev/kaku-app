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

  // TOTAL de gastos por categoría en un mes
  Future<Map<int, double>> getExpensesByCategory(int month, int year) async {
    final query = customSelect(
      '''SELECT category_id, SUM(amount) as total
        FROM transactions_table
        WHERE type = 'expense'
          AND strftime('%m', date) = ?
          AND strftime('%Y', date) = ?
        GROUP BY category_id''',
      variables: [
        Variable(month.toString().padLeft(2, '0')),
        Variable(year.toString()),
      ],
      readsFrom: {transactionsTable},
    );
    final rows = await query.get();
    return {
      for (final row in rows)
        row.read<int?>('category_id') ?? 0: row.read<double>('total'),
    };
  }

  // INSERTAR transacción
  Future<int> insertTransaction(TransactionsTableCompanion tx) =>
      into(transactionsTable).insert(tx);

  // ELIMINAR transacción
  Future<int> deleteTransaction(int id) =>
      (delete(transactionsTable)..where((t) => t.id.equals(id))).go();

  // SUMA de ingresos del mes
  Future<double> getTotalIncome(int month, int year) async {
    final result =
        await (selectOnly(transactionsTable)
              ..addColumns([transactionsTable.amount.sum()])
              ..where(transactionsTable.type.equals('income')))
            .getSingleOrNull();

    return result?.read(transactionsTable.amount.sum()) ?? 0.0;
  }

  // Stream de transacciones por cuenta
  Stream<List<TransactionWithCategory>> watchTransactionsByAccount(
    int accountId,
  ) {
    final query =
        (select(transactionsTable)..where((t) => t.accountId.equals(accountId)))
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

  Stream<Transaction?> watchTransactionById(int id) => (select(
    transactionsTable,
  )..where((a) => a.id.equals(id))).watchSingleOrNull();

  Future<bool> updateTransaction(Transaction transaction) =>
      update(transactionsTable).replace(transaction);

  Future<double> getTotalExpenses(int month, int year) async {
    final result = await customSelect(
      '''SELECT COALESCE(SUM(amount), 0) as total
        FROM transactions_table
        WHERE type = 'expense'
          AND strftime('%m', date) = ?
          AND strftime('%Y', date) = ?''',
      variables: [
        Variable(month.toString().padLeft(2, '0')),
        Variable(year.toString()),
      ],
      readsFrom: {transactionsTable},
    ).getSingle();
    return result.read<double>('total');
  }

  Future<int> countByCategory(int categoryId) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM transactions_table '
      'WHERE category_id = ?',
      variables: [Variable(categoryId)],
      readsFrom: {transactionsTable},
    ).getSingle();
    return result.read<int>('count');
  }
}

// Clase de resultado typesafe para JOIN ──
class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;
  const TransactionWithCategory({required this.transaction, this.category});
}
