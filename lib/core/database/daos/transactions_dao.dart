import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/accounts_table.dart';
import 'package:kaku/core/database/tables/categories_table.dart';
import 'package:kaku/core/database/tables/transactions_table.dart';
import 'package:kaku/core/models/transaction_type.dart';

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
    final range = _monthRange(year, month);
    final query =
        (select(transactionsTable)
            ..where((t) => t.date.isBetweenValues(range.start, range.end)))
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

  // TOTAL de gastos por categoría en un mes (Stream)
  Stream<Map<int, double>> watchExpensesByCategory(int month, int year) {
    final range = _monthRange(year, month);

    return (select(transactionsTable)..where(
          (t) =>
              t.type.equals('expense') &
              t.date.isBetweenValues(range.start, range.end),
        ))
        .watch()
        .map((rows) {
          final Map<int, double> result = {};
          for (final tx in rows) {
            final key = tx.categoryId ?? 0;
            result[key] = (result[key] ?? 0) + tx.amount;
          }
          return result;
        });
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
    final range = _monthRange(year, month);

    final rows =
        await (select(transactionsTable)..where(
              (t) =>
                  t.type.equals('expense') &
                  t.date.isBetweenValues(range.start, range.end),
            ))
            .get();

    return rows.fold(0.0, (sum, tx) => sum + tx.amount).toDouble();
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

  Future<List<TransactionWithCategory>> getTransactionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final query =
        (select(transactionsTable)
              ..where((t) => t.date.isBetweenValues(start, end))
              ..orderBy([(t) => OrderingTerm.desc(t.date)]))
            .join([
              leftOuterJoin(
                categoriesTable,
                categoriesTable.id.equalsExp(transactionsTable.categoryId),
              ),
            ]);

    final rows = await query.get();
    return rows
        .map(
          (row) => TransactionWithCategory(
            transaction: row.readTable(transactionsTable),
            category: row.readTableOrNull(categoriesTable),
          ),
        )
        .toList();
  }

  Future<double> getTotalExpensesByCategory({
    required int categoryId,
    required int month,
    required int year,
  }) async {
    final range = _monthRange(year, month);
    final rows =
        await (select(transactionsTable)..where(
              (t) =>
                  t.categoryId.equals(categoryId) &
                  t.type.equals('expense') &
                  t.date.isBetweenValues(range.start, range.end),
            ))
            .get();
    return rows.fold(0.0, (sum, tx) => sum + tx.amount).toDouble();
  }

  Future<void> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required double fromBalance,
    required double toBalance,
    String? description,
    DateTime? date,
  }) async {
    await transaction(() async {
      final now = date ?? DateTime.now();
      final transferId = now.millisecondsSinceEpoch; // id único compartido

      // 1. Gasto en la cuenta origen
      await into(transactionsTable).insert(
        TransactionsTableCompanion.insert(
          amount: amount,
          type: TransactionType.transfer.name,
          accountId: fromAccountId,
          categoryId: const Value(
            null,
          ), // las transferencias no tienen categoría
          description: Value(description ?? 'Transferencia'),
          date: now,
          transferId: Value(transferId),
        ),
      );

      // 2. Ingreso en la cuenta destino
      await into(transactionsTable).insert(
        TransactionsTableCompanion.insert(
          amount: amount,
          type: TransactionType.transfer.name,
          accountId: toAccountId,
          categoryId: const Value(null),
          description: Value(description ?? 'Transferencia'),
          date: now,
          transferId: Value(transferId),
        ),
      );

      // 3. Actualizar balances
      await (update(accountsTable)..where((a) => a.id.equals(fromAccountId)))
          .write(AccountsTableCompanion(balance: Value(fromBalance - amount)));

      await (update(accountsTable)..where((a) => a.id.equals(toAccountId)))
          .write(AccountsTableCompanion(balance: Value(toBalance + amount)));
    });
  }

  MonthRange _monthRange(int year, int month) => MonthRange(
    start: DateTime(year, month, 1),
    end: DateTime(year, month + 1, 0, 23, 59),
  );
}

// Clase de resultado typesafe para JOIN ──
class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;
  const TransactionWithCategory({required this.transaction, this.category});
}

class MonthRange {
  final DateTime start;
  final DateTime end;
  const MonthRange({required this.start, required this.end});
}
