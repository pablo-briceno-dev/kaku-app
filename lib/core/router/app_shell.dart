import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/calendar_provider.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:kaku/shared/services/app_pin_service.dart';
import 'package:kaku/shared/services/biometric_service.dart';
import 'package:kaku/shared/services/last_route_service.dart';
import 'package:kaku/shared/services/notification_navigation.dart';
import 'package:kaku/shared/services/calendar_widget_sync.dart';
import 'package:kaku/shared/services/whats_new_service.dart';
import 'package:kaku/shared/widgets/whats_new_dialog.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  // Mismo orden que los BottomNavigationBarItem de abajo
  static const _tabs = AppRoutes.shellTabs;

  bool _consumingPending = false;
  bool _resumeProcessing = false;
  DateTime? _lastNotificationNavigation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pendingNotificationRoute.addListener(_consumePendingRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumePendingRoute();
      ref.read(calendarControllerProvider).startupSync();
      ref.read(calendarWidgetSyncProvider).push();
      _maybeShowWhatsNew();
    });
  }

  @override
  void dispose() {
    pendingNotificationRoute.removeListener(_consumePendingRoute);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(authenticationStateProvider.notifier).state = false;
      LastRouteService.markInactive();
      _resumeProcessing = false;
    }
    if (state == AppLifecycleState.resumed) {
      _onResumed();
    }
  }

  Future<void> _maybeShowWhatsNew() async {
    await Future.delayed(
      const Duration(milliseconds: 900),
    ); // deja asentarse la pantalla
    if (!mounted ||
        pendingNotificationRoute.value != null ||
        deepLinkWasRecent()) {
      return;
    }

    final path = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    if (path == AppRoutes.personal) {
      await WhatsNewService.markSeen(); // ya encontró el calendario por su cuenta
      return;
    }

    if (path != AppRoutes.dashboard) return;

    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (!mounted) return;
    if (!await WhatsNewService.shouldShow(
      hasExistingData: accounts.isNotEmpty,
    )) {
      return;
    }

    await WhatsNewService.markSeen();
    if (!mounted) return;
    await showWhatsNewDialog(context);
  }

  Future<void> _consumePendingRoute() async {
    if (_consumingPending) return;
    final route = pendingNotificationRoute.value;
    if (route == null) return;

    if (!ref.read(authenticationStateProvider)) {
      final locked =
          await AppPinService.isEnabled() || await BiometricService.isEnabled();
      if (locked) return;
    }
    if (!mounted || pendingNotificationRoute.value == null) return;

    _consumingPending = true;
    try {
      pendingNotificationRoute.value = null;
      _lastNotificationNavigation = DateTime.now();
      await LastRouteService.markActive();
      if (!mounted) return;
      context.go(withFreshToken(route));
    } finally {
      _consumingPending = false;
    }
  }

  Future<void> _onResumed() async {
    if (_resumeProcessing) return;
    _resumeProcessing = true;
    try {
      ref.read(calendarWidgetSyncProvider).push();
      final wasExpired = await LastRouteService.isExpired();
      await LastRouteService.markActive();

      final pinEnabled = await AppPinService.isEnabled();
      final biometricEnabled = await BiometricService.isEnabled();
      if (!mounted) return;

      final locked = pinEnabled || biometricEnabled;

      if (locked && !ref.read(authenticationStateProvider)) {
        // LockScreen decide el destino con goToStartRoute (respeta la expiración)
        context.go(AppRoutes.root);
        return;
      }

      if (pendingNotificationRoute.value != null) {
        await _consumePendingRoute();
        return;
      }

      final lastNav = _lastNotificationNavigation;
      if (lastNav != null &&
          DateTime.now().difference(lastNav) < const Duration(seconds: 2)) {
        return;
      }

      // Sin bloqueo: si pasó mucho tiempo, vuelve al dashboard
      if (wasExpired) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted || deepLinkWasRecent()) return;
        context.go(AppRoutes.dashboard);
      }
    } finally {
      _resumeProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Tamaño fijo para el botón central (entre 48 y 60 dp)
    const double centerSize = 56.0; // o calcúlalo con MediaQuery si quieres

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: ListenableBuilder(
        listenable: router.routerDelegate,
        builder: (context, _) {
          final location = router.routerDelegate.currentConfiguration.uri.path;
          var currentIndex = _tabs.lastIndexWhere(
            (t) => location.startsWith(t),
          );
          if (currentIndex < 0) currentIndex = 0;

          return BottomAppBar(
            color: cs.surface,
            elevation: 8,
            notchMargin: 8,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Grupo izquierdo: Inicio + Estadísticas
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: l10n.appShellTabDashboard,
                  index: 0,
                  current: currentIndex,
                  onTap: () => context.go(_tabs[0]),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  selectedIcon: Icons.bar_chart,
                  label: l10n.appShellTabStats,
                  index: 1,
                  current: currentIndex,
                  onTap: () => context.go(_tabs[1]),
                ),

                // Centro (ocupa un espacio fijo)
                SizedBox(
                  width: centerSize,
                  height: centerSize,
                  child: _NavCenterItem(
                    icon: Icons.add,
                    onTap: () => context.push(AppRoutes.addTransaction),
                  ),
                ),

                // Grupo derecho: Metas + Cuentas
                _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person_rounded,
                  label: l10n.appShellTabPersonal,
                  index: 2,
                  current: currentIndex,
                  onTap: () => context.go(_tabs[2]),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet,
                  label: l10n.appShellTabAccounts,
                  index: 3,
                  current: currentIndex,
                  onTap: () => context.go(_tabs[3]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- Ítem normal (ahora con Flexible para que se ajuste sin romper) ---
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

    return Flexible(
      flex: 1, // ambos grupos ocupan el mismo espacio
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Botón central (sin cambios, solo se usa dentro del SizedBox) ---
class _NavCenterItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavCenterItem({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          color: cs.primary,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withAlpha(30),
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
