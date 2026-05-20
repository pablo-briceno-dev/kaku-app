import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/core/router/app_shell.dart';
import 'package:kaku/features/accounts/account_detail_screen.dart';
import 'package:kaku/features/accounts/account_form_screen.dart';
import 'package:kaku/features/accounts/accounts_screen.dart';
import 'package:kaku/features/categories/category_detail_screen.dart';
import 'package:kaku/features/dashboard/dashboard_screen.dart';
import 'package:kaku/features/goals/goals_screen.dart';
import 'package:kaku/features/settings/settings_screen.dart';
import 'package:kaku/features/stats/stats_screen.dart';
import 'package:kaku/features/transactions/add_transaction_screen.dart';
import 'package:kaku/features/transactions/transaction_detail_screen.dart';
import 'package:kaku/features/transactions/transactions_screen.dart';

// Provider que expone el router a toda la app
// Se consume en main.dart con: router: ref.watch(routerProvider)
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true, //! Quitar en producción
    routes: [
      // ShellRoute: envuelve todas las pantallas que tienen bottom nav
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Tabs principales
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.stats,
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: AppRoutes.goals,
            builder: (context, state) => const GoalsScreen(),
          ),
          GoRoute(
            path: AppRoutes.accounts,
            builder: (context, state) => const AccountsScreen(),
          ),

          GoRoute(
            path: AppRoutes.transactions,
            builder: (context, state) => const TransactionsScreen(),
          ),

          // Accounts
          GoRoute(
            path: AppRoutes.newAccount,
            builder: (_, state) => const AccountFormScreen(),
          ),

          // Sub-routas de detalle (mantiene el bottom nav)
          GoRoute(
            path: AppRoutes.transactionDetail,
            builder: (context, state) => TransactionDetailScreen(
              id: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: AppRoutes.categoryDetail, // '/category/:id'
            builder: (_, state) {
              final id = int.parse(state.pathParameters['id']!);
              final month = int.parse(
                state.uri.queryParameters['month'] ?? '1',
              );
              final year = int.parse(
                state.uri.queryParameters['year'] ?? '2024',
              );
              return CategoryDetailScreen(id: id, month: month, year: year);
            },
          ),
          GoRoute(
            path: AppRoutes.accountDetail, // '/accounts/:id'
            builder: (_, state) =>
                AccountDetailScreen(id: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),

      // ── Fuera del ShellRoute: sin bottom nav (pantalla completa) ──
      GoRoute(
        path: AppRoutes.addTransaction, // '/add-transaction'
        builder: (_, state) {
          final accountIdStr = state.uri.queryParameters['accountId'];
          final accountId = accountIdStr != null
              ? int.tryParse(accountIdStr)
              : null;
          return AddTransactionScreen(accountId: accountId);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
