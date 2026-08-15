import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/core/router/app_shell.dart';
import 'package:kaku/features/accounts/account_detail_screen.dart';
import 'package:kaku/features/accounts/accounts_screen.dart';
import 'package:kaku/features/categories/categories_screen.dart';
import 'package:kaku/features/categories/category_detail_screen.dart';
import 'package:kaku/features/dashboard/dashboard_screen.dart';
import 'package:kaku/features/goals/goals_screen.dart';
import 'package:kaku/features/premium/premium_screen.dart';
import 'package:kaku/features/settings/budget_list_screen.dart';
import 'package:kaku/features/settings/security/lock_screen.dart';
import 'package:kaku/features/settings/settings_screen.dart';
import 'package:kaku/features/stats/stats_screen.dart';
import 'package:kaku/features/transactions/add_transactions/add_transaction_screen.dart';
import 'package:kaku/features/transactions/transaction_detail_screen.dart';
import 'package:kaku/features/transactions/transactions_screen.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:kaku/shared/services/app_pin_service.dart';
import 'package:kaku/shared/services/biometric_service.dart';

// Provider que expone el router a toda la app
// Se consume en main.dart con: router: ref.watch(routerProvider)
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.root,
    // debugLogDiagnostics: true, //! Quitar en producción
    routes: [
      GoRoute(path: AppRoutes.root, builder: (_, state) => const LockScreen()),
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

          // Sub-routas de detalle (mantiene el bottom nav)
          GoRoute(
            path: AppRoutes.transactionDetail,
            builder: (context, state) => TransactionDetailScreen(
              id: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: AppRoutes.accountDetail, // '/accounts/:id'
            builder: (context, state) =>
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
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoryDetail, // '/category/:id'
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final month = int.parse(state.uri.queryParameters['month'] ?? '1');
          final year = int.parse(state.uri.queryParameters['year'] ?? '2024');
          return CategoryDetailScreen(id: id, month: month, year: year);
        },
      ),
      GoRoute(
        path: AppRoutes.budgets, // '/category/:id'
        builder: (context, state) {
          return BudgetListScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
    redirect: (context, routerState) async {
      final isLockRoute = routerState.matchedLocation == AppRoutes.root;

      // Ya en /lock → no redirigir
      if (isLockRoute) return null;

      final authenticated = ref.watch(authenticationStateProvider);
      // ✅ FIX 2: si ya autenticó en esta sesión → dejar pasar
      if (authenticated) return null;

      // Si no hay bloqueo activo → dejar pasar sin pasar por /lock
      final locked = await _isLocked();
      if (!locked) {
        // no tiene bloqueo, marcar como autenticado
        ref.read(authenticationStateProvider.notifier).state = true;
        return null;
      }

      // Tiene bloqueo y no ha autenticado → ir a /lock
      return AppRoutes.root;
    },
  );
});

Future<bool> _isLocked() async {
  final pinEnabled = await AppPinService.isEnabled();
  final biometricEnabled = await BiometricService.isEnabled();
  return pinEnabled || biometricEnabled;
}
