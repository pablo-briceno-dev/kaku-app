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
    return _buildTransactionsQuery(
      year: year,
      month: month,
    ).watch().map((rows) => rows.map(_toTransactionWithCategory).toList());
    // final start = DateTime(year, month);
    // final nextMonth = DateTime(year, month + 1);

    // final query =
    //     (select(transactionsTable)..where(
    //         (t) =>
    //             t.date.isBiggerOrEqualValue(start) &
    //             t.date.isSmallerThanValue(nextMonth),
    //       ))
    //       ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    // return query
    //     .join([
    //       leftOuterJoin(
    //         categoriesTable,
    //         categoriesTable.id.equalsExp(transactionsTable.categoryId),
    //       ),
    //     ])
    //     .watch()
    //     .map(
    //       (rows) => rows
    //           .map(
    //             (row) => TransactionWithCategory(
    //               transaction: row.readTable(transactionsTable),
    //               category: row.readTableOrNull(categoriesTable),
    //             ),
    //           )
    //           .toList(),
    //     );
  }

  // TOTAL de gastos por categoría en un mes (Stream)
  Stream<Map<int, double>> watchExpensesByCategory(int month, int year) {
    return _buildTransactionsQuery(
      year: year,
      month: month,
      transactionType: 'expense',
    ).watch().map((rows) => rows.map(_toTransactionWithCategory).toList()).map((
      rows,
    ) {
      final Map<int, double> result = {};
      for (final tx in rows) {
        final key = tx.category?.id ?? 0;
        result[key] = (result[key] ?? 0) + tx.transaction.amount;
      }
      return result;
    });

    // final start = DateTime(year, month);
    // final nextMonth = DateTime(year, month + 1);

    // return (select(transactionsTable)..where(
    //       (t) =>
    //           t.type.equals('expense') &
    //           t.date.isBiggerOrEqualValue(start) &
    //           t.date.isSmallerThanValue(nextMonth),
    //     ))
    //     .watch()
    //     .map((rows) {
    //       final Map<int, double> result = {};
    //       for (final tx in rows) {
    //         final key = tx.categoryId ?? 0;
    //         result[key] = (result[key] ?? 0) + tx.amount;
    //       }
    //       return result;
    //     });
  }

  // INSERTAR transacción
  Future<int> insertTransaction(TransactionsTableCompanion tx) =>
      into(transactionsTable).insert(tx);

  // ELIMINAR transacción
  Future<int> deleteTransaction(int id) =>
      (delete(transactionsTable)..where((t) => t.id.equals(id))).go();

  // SUMA de ingresos del mes
  Future<double> getTotalIncome(int month, int year) async {
    final start = DateTime(year, month);
    final nextMonth = DateTime(year, month + 1);

    final result =
        await (selectOnly(transactionsTable)
              ..addColumns([transactionsTable.amount.sum()])
              ..where(
                transactionsTable.type.equals('income') &
                    transactionsTable.date.isBiggerOrEqualValue(start) &
                    transactionsTable.date.isSmallerThanValue(nextMonth),
              ))
            .getSingleOrNull();

    return result?.read(transactionsTable.amount.sum()) ?? 0.0;
  }

  // Stream de transacciones por cuenta
  Stream<List<TransactionWithCategory>> watchTransactionsByAccount(
    int accountId,
  ) {
    return _buildTransactionsQuery(
      accountId: accountId,
    ).watch().map((rows) => rows.map(_toTransactionWithCategory).toList());
    // final query =
    //     (select(transactionsTable)..where((t) => t.accountId.equals(accountId)))
    //       ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    // return query
    //     .join([
    //       leftOuterJoin(
    //         categoriesTable,
    //         categoriesTable.id.equalsExp(transactionsTable.categoryId),
    //       ),
    //     ])
    //     .watch()
    //     .map(
    //       (rows) => rows
    //           .map(
    //             (row) => TransactionWithCategory(
    //               transaction: row.readTable(transactionsTable),
    //               category: row.readTableOrNull(categoriesTable),
    //             ),
    //           )
    //           .toList(),
    //     );
  }

  Stream<Transaction?> watchTransactionById(int id) => (select(
    transactionsTable,
  )..where((a) => a.id.equals(id))).watchSingleOrNull();

  Future<bool> updateTransaction(Transaction transaction) =>
      update(transactionsTable).replace(transaction);

  Future<double> getTotalExpenses(int month, int year) async {
    final start = DateTime(year, month);
    final nextMonth = DateTime(year, month + 1);

    final rows =
        await (select(transactionsTable)..where(
              (t) =>
                  t.type.equals('expense') &
                  t.date.isBiggerOrEqualValue(start) &
                  t.date.isSmallerThanValue(nextMonth),
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
              ..where(
                (t) =>
                    t.date.isBiggerOrEqualValue(start) &
                    t.date.isSmallerThanValue(end),
              )
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
    final start = DateTime(year, month);
    final nextMonth = DateTime(year, month + 1);
    final rows =
        await (select(transactionsTable)..where(
              (t) =>
                  t.categoryId.equals(categoryId) &
                  t.type.equals('expense') &
                  t.date.isBiggerOrEqualValue(start) &
                  t.date.isSmallerThanValue(nextMonth),
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

  /// Consulta base reutilizable: todos los filtros son opcionales
  JoinedSelectStatement<HasResultSet, dynamic> _buildTransactionsQuery({
    int? accountId,
    int? categoryId,
    int? year,
    int? month,
    String? transactionType,
    int? limit,
    int offset = 0,
  }) {
    assert(
      (year == null) == (month == null),
      'year y month deben enviarse juntos o ninguno (year=$year, month=$month)',
    );
    // assert((limit == null) == (offset == 0), 'Offset requiere limit');
    assert(
      limit != null || offset == 0,
      'Offset requiere limit (limit=$limit, offset=$offset)',
    );

    final query = select(transactionsTable).join([
      leftOuterJoin(
        categoriesTable,
        categoriesTable.id.equalsExp(transactionsTable.categoryId),
      ),
    ]);

    final filters = <Expression<bool>>[];

    if (categoryId != null) {
      filters.add(transactionsTable.categoryId.equals(categoryId));
    }

    if (year != null && month != null) {
      final start = DateTime(year, month);
      final nextMonth = DateTime(year, month + 1);
      filters.add(
        transactionsTable.date.isBiggerOrEqualValue(start) &
            transactionsTable.date.isSmallerThanValue(nextMonth),
      );
    }

    if (accountId != null) {
      filters.add(transactionsTable.accountId.equals(accountId));
    }

    if (transactionType != null) {
      filters.add(transactionsTable.type.equals(transactionType));
    }

    if (filters.isNotEmpty) {
      query.where(filters.reduce((a, b) => a & b));
    }

    query.orderBy([
      OrderingTerm.desc(transactionsTable.date),
      OrderingTerm.desc(transactionsTable.id),
    ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query;
  }

  TransactionWithCategory _toTransactionWithCategory(TypedResult row) =>
      TransactionWithCategory(
        transaction: row.readTable(transactionsTable),
        category: row.readTableOrNull(categoriesTable),
      );

  // Una sola vez: scroll infinito, exportaciones, etc.
  Future<List<TransactionWithCategory>> getTransactions({
    int? categoryId,
    int? year,
    int? month,
    int? limit,
    int offset = 0,
  }) async {
    final rows = await _buildTransactionsQuery(
      categoryId: categoryId,
      year: year,
      month: month,
      limit: limit,
      offset: offset,
    ).get();
    return rows.map(_toTransactionWithCategory).toList();
  }

  // Reactivo: Dashboard (se actualiza solo al agregar o borrar)
  Stream<List<TransactionWithCategory>> watchTransactions({
    int? categoryId,
    int? year,
    int? month,
    int? limit,
    int offset = 0,
  }) {
    return _buildTransactionsQuery(
      categoryId: categoryId,
      year: year,
      month: month,
      limit: limit,
      offset: offset,
    ).watch().map((rows) => rows.map(_toTransactionWithCategory).toList());
  }

  // Totales de ingresos y gastos por mes, de los últimos [months] meses (reactivo)
  Stream<List<MonthFlow>> watchMonthlyFlow({
    required int months,
    required int year,
    required int month,
  }) {
    final now = DateTime(year, month);
    final start = DateTime(now.year, now.month - (months - 1));
    final end = DateTime(now.year, now.month + 1);

    final query = select(transactionsTable)
      ..where(
        (t) =>
            t.type.isIn(['income', 'expense']) &
            t.date.isBiggerOrEqualValue(start) &
            t.date.isSmallerThanValue(end),
      );

    return query.watch().map((rows) {
      final income = <DateTime, double>{};
      final expense = <DateTime, double>{};
      for (final t in rows) {
        final key = DateTime(t.date.year, t.date.month);
        final bucket = t.type == 'income' ? income : expense;
        bucket[key] = (bucket[key] ?? 0) + t.amount;
      }

      final result = <MonthFlow>[];
      for (var i = 0; i < months; i++) {
        final m = DateTime(start.year, start.month + i);
        result.add(
          MonthFlow(month: m, income: income[m] ?? 0, expense: expense[m] ?? 0),
        );
      }

      return result;
    });
  }
}

// Clase de resultado typesafe para JOIN ──
class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;
  const TransactionWithCategory({required this.transaction, this.category});
}

class MonthFlow {
  final DateTime month;
  final double income;
  final double expense;

  const MonthFlow({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}
