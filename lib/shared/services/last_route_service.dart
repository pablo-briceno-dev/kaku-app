import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/shared/services/notification_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastRouteService {
  static const _kRoute = 'last_route';
  static const _kInactiveAt = 'last_inactive_at';

  /// Tiempo máximo fuera de la app antes de volver al Dashboard
  static const maxInactivity = Duration(hours: 1);

  /// Pantallas que NO se restauran (formularios a medias, lock, etc.)
  static const _excluded = [
    AppRoutes.root,
    // AppRoutes.addTransaction,
    AppRoutes.premium,
  ];

  static bool isRestorable(String location) =>
      !_excluded.contains(Uri.parse(location).path);

  static Future<void> save(String location) async {
    if (!isRestorable(location)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRoute, location);
  }

  /// Se llama cuando la app pasa a segundo plano
  static Future<void> markInactive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kInactiveAt, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> isExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_kInactiveAt);
    if (ts == null) return false;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ts),
    );
    return elapsed > maxInactivity;
  }

  /// Ruta a la que debe ir el usuario al entrar a la app
  static Future<String> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kRoute);
    if (saved == null || !isRestorable(saved) || await isExpired()) {
      return AppRoutes.dashboard;
    }
    return saved;
  }

  static Future<void> goToStart(BuildContext context) async {
    final pending = pendingNotificationRoute.value;
    if (pending != null) {
      pendingNotificationRoute.value = null;
      if (context.mounted) context.go(withFreshToken(pending));
      return;
    }

    final target = await restore();
    if (!context.mounted) return;
    final path = Uri.parse(target).path;

    if (AppRoutes.shellTabs.contains(path)) {
      context.go(target); // es un tab, se navega directo
    } else {
      // Detalle u otra pantalla: primero el Dashboard y encima el destino,
      // para que "atrás" tenga a dónde volver.
      context.go(AppRoutes.dashboard);
      context.push(target);
    }
  }

  /// Marca la app como "activa" — limpia el timestamp de inactividad.
  /// Llámalo en cuanto se maneja el `resumed`, para que eventos duplicados
  /// no vuelvan a disparar la navegación a dashboard.
  static Future<void> markActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kInactiveAt);
  }
}
