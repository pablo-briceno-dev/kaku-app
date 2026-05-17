import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  // Mismo orden que los BottomNavigationBarItem de abajo
  static const _tabs = AppRoutes.shellTabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    // Calcula qué tab está activo según la URL actual.
    // lastIndexWhere prioriza el match más largo, evitando que '/accounts/42'
    // active '/accounts' en lugar del tab correcto
    int currentIndex = _tabs.lastIndexWhere((t) => location.startsWith(t));
    if (currentIndex < 0) currentIndex = 0; // fallback al Dashboard

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // go() en lugar de push() para que el back button funcione bien entre tabs
          context.go(_tabs[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
            selectedIcon: Icon(Icons.bar_chart),
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            label: 'Metas',
            selectedIcon: Icon(Icons.flag),
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Cuentas',
            selectedIcon: Icon(Icons.account_balance_wallet),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
            selectedIcon: Icon(Icons.settings),
          ),
        ],
      ),
      // FAB central para agregar gasto rápido desde cualquier tab
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
