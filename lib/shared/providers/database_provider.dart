import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/daos/accounts_dao.dart';
import 'package:kaku/core/database/daos/budgets_dao.dart';
import 'package:kaku/core/database/daos/categories_dao.dart';
import 'package:kaku/core/database/daos/goals_dao.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/models/budget_progress.dart';
import 'package:riverpod/legacy.dart';
import 'package:rxdart/rxdart.dart';

final appRefreshCounterProvider = StateProvider<int>((ref) => 0);
const _pageSize = 10;

// Provider singleton de la base de datos
final databaseProvider = Provider<AppDatabase>((ref) {
  ref.watch(appRefreshCounterProvider);
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Providers de DAOs (acceso rápido desde cualquier widget)
final transactionsDaoProvider = Provider.autoDispose<TransactionsDao>(
  (ref) => ref.watch(databaseProvider).transactionsDao,
);

final budgetsDaoProvider = Provider.autoDispose<BudgetsDao>(
  (ref) => ref.watch(databaseProvider).budgetsDao,
);

final accountsDaoProvider = Provider.autoDispose<AccountsDao>(
  (ref) => ref.watch(databaseProvider).accountsDao,
);

final goalsDaoProvider = Provider.autoDispose<GoalsDao>(
  (ref) => ref.watch(databaseProvider).goalsDao,
);

final categoriesDaoProvider = Provider.autoDispose<CategoriesDao>(
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

final monthTransactionsWithLimitProvider =
    StreamProvider.family<
      List<TransactionWithCategory>,
      ({int month, int year, int limit})
    >((ref, params) {
      debugPrint(
        'monthTransactionsWithLimitProvider params: ${params.toString()}',
      );
      return ref
          .watch(transactionsDaoProvider)
          .watchTransactions(
            month: params.month,
            year: params.year,
            limit: params.limit,
          );
    });

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
        return expensesStream.asyncMap((expensesByCategory) async {
          final List<BudgetProgress> result = [];

          for (final bwc in budgets) {
            final effectiveLimit = await budgetsDao.getEffectiveLimit(
              categoryId: bwc.category.id,
              month: params.month,
              year: params.year,
              baseLimit: bwc.budget.limitAmount,
              rollover: bwc.budget.rollover,
              txDao: txDao,
            );

            result.add(
              BudgetProgress(
                budget: bwc.budget,
                category: bwc.category,
                spent: expensesByCategory[bwc.budget.categoryId] ?? 0.0,
                effectiveLimit: effectiveLimit,
              ),
            );
          }

          return result;
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

class PagedTxState {
  const PagedTxState({
    this.items = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<TransactionWithCategory> items;
  final bool hasMore;
  final bool isLoadingMore;

  PagedTxState copyWith({
    List<TransactionWithCategory>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) => PagedTxState(
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

// Categorías
typedef CategoryTxArgs = ({int categoryId, int? year, int? month});

class CategoryTxNotifier extends AsyncNotifier<PagedTxState> {
  CategoryTxNotifier(this.args);
  final CategoryTxArgs args;

  Future<List<TransactionWithCategory>> _fetch(int offset) {
    final dao = ref.read(transactionsDaoProvider);
    return dao.getTransactions(
      categoryId: args.categoryId,
      year: args.year,
      month: args.month,
      limit: _pageSize,
      offset: offset,
    );
  }

  @override
  Future<PagedTxState> build() async {
    final first = await _fetch(0);
    return PagedTxState(items: first, hasMore: first.length == _pageSize);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _fetch(current.items.length);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next],
          hasMore: next.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

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

final categoryTxProvider = AsyncNotifierProvider.autoDispose
    .family<CategoryTxNotifier, PagedTxState, CategoryTxArgs>(
      CategoryTxNotifier.new,
    );

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
        return expensesStream.asyncMap((expensesByCategory) async {
          if (bwc == null) return null;

          final effectiveLimit = await budgetsDao.getEffectiveLimit(
            categoryId: bwc.category.id,
            month: params.month,
            year: params.year,
            baseLimit: bwc.budget.limitAmount,
            rollover: bwc.budget.rollover,
            txDao: txDao,
          );

          return BudgetProgress(
            budget: bwc.budget,
            category: bwc.category,
            spent: expensesByCategory[bwc.budget.categoryId] ?? 0.0,
            effectiveLimit: effectiveLimit,
          );
        });
      });
    });

// Estadísticas
final monthlyFlowProvider =
    StreamProvider.family<List<MonthFlow>, ({int months, int year, int month})>(
      (ref, params) => ref
          .watch(transactionsDaoProvider)
          .watchMonthlyFlow(
            months: params.months,
            year: params.year,
            month: params.month,
          ),
    );
