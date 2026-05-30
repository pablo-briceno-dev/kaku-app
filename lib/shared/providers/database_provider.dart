import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/daos/accounts_dao.dart';
import 'package:kaku/core/database/daos/budgets_dao.dart';
import 'package:kaku/core/database/daos/categories_dao.dart';
import 'package:kaku/core/database/daos/goals_dao.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/models/budget_progress.dart';
import 'package:rxdart/rxdart.dart';

// Provider singleton de la base de datos
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// Providers de DAOs (acceso rápido desde cualquier widget)
final transactionsDaoProvider = Provider<TransactionsDao>(
  (ref) => ref.watch(databaseProvider).transactionsDao,
);

final budgetsDaoProvider = Provider<BudgetsDao>(
  (ref) => ref.watch(databaseProvider).budgetsDao,
);

final accountsDaoProvider = Provider<AccountsDao>(
  (ref) => ref.watch(databaseProvider).accountsDao,
);

final goalsDaoProvider = Provider<GoalsDao>(
  (ref) => ref.watch(databaseProvider).goalsDao,
);

final categoriesDaoProvider = Provider<CategoriesDao>(
  (ref) => ref.watch(databaseProvider).categoriesDao,
);

// Stream de transacciones del mes - se actualiza en tiempo real
final monthTransactionsProvider =
    StreamProvider.family<
      List<TransactionWithCategory>,
      ({int month, int year})
    >(
      (ref, params) => ref
          .watch(transactionsDaoProvider)
          .watchMonthTransactions(params.month, params.year),
    );

// Progreso de presupuestos - StreamProvider para que sea reactivo
// Combina el stream de budgets con el cálculo de gastos reales
final budgetProgressProvider =
    StreamProvider.family<List<BudgetProgress>, ({int month, int year})>((
      ref,
      params,
    ) {
      final txDao = ref.watch(transactionsDaoProvider);
      final budgetsDao = ref.watch(budgetsDaoProvider);

      // Stream 1: presupuestos del mes con su categoría
      final budgetsStream = budgetsDao.watchBudgetsForMonth(
        params.month,
        params.year,
      );

      // Stream 2: gastos por categoría del mes
      // Ahora es reactivo — emite cada vez que cambia una transacción
      final expensesStream = txDao.watchExpensesByCategory(
        params.month,
        params.year,
      );

      // Combina los dos streams:
      // Emite cuando CUALQUIERA de los dos cambia.
      // switchMap garantiza que siempre usamos el último valor
      // del stream de gastos cuando llega un nuevo budget.
      return budgetsStream.switchMap((budgets) {
        return expensesStream.map((expensesByCategory) {
          return budgets
              .map(
                (bwc) => BudgetProgress(
                  budget: bwc.budget,
                  category: bwc.category,
                  spent: expensesByCategory[bwc.budget.categoryId] ?? 0.0,
                ),
              )
              .toList();
        });
      });
    });

// Balance total de cuentas (reactivo)
final totalBalanceProvider = StreamProvider<double>(
  (ref) => ref.watch(accountsDaoProvider).watchTotalBalance(),
);

// Metas activas (reactivo)
final activeGoalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalsDaoProvider).watchActiveGoals(),
);

// Metas completadas (reactivo)
final completedGoalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalsDaoProvider).watchCompletedGoals(),
);

// Accounts (reactivo)
final activeAccountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(accountsDaoProvider).watchActiveAccounts(),
);

// Para la pantalla de detalle de una cuenta específica
final accountByIdProvider = StreamProvider.family<Account?, int>(
  (ref, id) => ref.watch(accountsDaoProvider).watchAccountById(id),
);

// Transacciones por accountId
final transactionsByAccountProvider =
    StreamProvider.family<List<TransactionWithCategory>, int>(
      (ref, accountId) => ref
          .watch(transactionsDaoProvider)
          .watchTransactionsByAccount(accountId),
    );

final transactionByIdProvider = StreamProvider.family<Transaction?, int>(
  (ref, id) => ref.watch(transactionsDaoProvider).watchTransactionById(id),
);

// Categorías
final allCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoriesDaoProvider).watchAllCategories(),
);

final expenseCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoriesDaoProvider).watchExpenseCategories(),
);

final incomeCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoriesDaoProvider).watchIncomeCategories(),
);

final categoryByIdProvider = StreamProvider.family<Category?, int?>((ref, id) {
  if (id == null) return Stream.value(null);
  return ref.watch(categoriesDaoProvider).watchCategoryById(id);
});

// Metas
final allGoalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalsDaoProvider).watchAllGoals(),
);

// Presupuestos
final budgetProgressProviderByCategory =
    StreamProvider.family<
      BudgetProgress?,
      ({int month, int year, int categoryId})
    >((ref, params) {
      final txDao = ref.watch(transactionsDaoProvider);
      final budgetsDao = ref.watch(budgetsDaoProvider);

      // Stream 1: presupuestos del mes con su categoría
      final budgetsStream = budgetsDao.watchBudgetForMonthByCategory(
        params.month,
        params.year,
        params.categoryId,
      );

      // Stream 2: gastos por categoría del mes
      // Ahora es reactivo — emite cada vez que cambia una transacción
      final expensesStream = txDao.watchExpensesByCategory(
        params.month,
        params.year,
      );

      // Combina los dos streams:
      // Emite cuando CUALQUIERA de los dos cambia.
      // switchMap garantiza que siempre usamos el último valor
      // del stream de gastos cuando llega un nuevo budget.
      return budgetsStream.switchMap((bwc) {
        return expensesStream.map((expensesByCategory) {
          if (bwc == null) return null;

          return BudgetProgress(
            budget: bwc.budget,
            category: bwc.category,
            spent: expensesByCategory[bwc.budget.categoryId] ?? 0.0,
          );
        });
      });
    });
