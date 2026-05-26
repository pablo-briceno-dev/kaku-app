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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomAppBar(
        color: cs.surface,
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 2 tabs a la izquierda
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Inicio',
              index: 0,
              current: currentIndex,
              onTap: () => context.go(_tabs[0]),
            ),
            _NavItem(
              icon: Icons.bar_chart_outlined,
              selectedIcon: Icons.bar_chart,
              label: 'Stats',
              index: 1,
              current: currentIndex,
              onTap: () => context.go(_tabs[1]),
            ),

            // Centro
            _NavCenterItem(
              icon: Icons.add,
              onTap: () => context.push(AppRoutes.addTransaction),
            ),

            // 2 tabs a la derecha
            _NavItem(
              icon: Icons.flag_outlined,
              selectedIcon: Icons.flag,
              label: 'Metas',
              index: 2,
              current: currentIndex,
              onTap: () => context.go(_tabs[2]),
            ),
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet,
              label: 'Cuentas',
              index: 3,
              current: currentIndex,
              onTap: () => context.go(_tabs[3]),
            ),
          ],
        ),
      ),
      // FAB central para agregar gasto rápido desde cualquier tab
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => context.push(AppRoutes.addTransaction),
      //   tooltip: 'Agregar gasto',
      //   child: const Icon(Icons.add, size: 28),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Widget auxiliar para cada ítem del BottomAppBar
class _NavItem extends StatelessWidget {
  final IconData icon, selectedIcon;
  final String label;
  final int index, current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    final color = active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? selectedIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCenterItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavCenterItem({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          color: cs.primary,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: cs.onPrimary, size: 35),
      ),
    );
  }
}
