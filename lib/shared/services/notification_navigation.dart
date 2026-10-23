import 'package:flutter/foundation.dart';
import 'package:kaku/core/router/app_routes.dart';

/// Ruta pendiente de abrir por el toque de una notificación
final pendingNotificationRoute = ValueNotifier<String?>(null);

void handleNotificationPayload(String? payload) {
  // Solo se aceptan rutas del calendario, que son las que programamos nosotros
  if (payload != null && payload.startsWith(AppRoutes.personal)) {
    pendingNotificationRoute.value = payload;
  }
}

/// Hace única la ruta, para que go_router la trate como una navegación nueva.
String withFreshToken(String route) {
  final uri = Uri.parse(route);
  return uri
      .replace(
        queryParameters: {
          ...uri.queryParameters,
          'n': DateTime.now().microsecondsSinceEpoch.toString(),
        },
      )
      .toString();
}

// Enlaces que llegan de fuera de la app (widget) ==============
DateTime? _lastDeepLinkAt;

/// Se llama cuando el sistema entrega un enlace del widget
void markDeepLink() => _lastDeepLinkAt = DateTime.now();

/// ¿Llegó hace poco un enlace externo? Evita que otra lógica lo pise
bool deepLinkWasRecent([Duration within = const Duration(seconds: 3)]) {
  final t = _lastDeepLinkAt;
  return t != null && DateTime.now().difference(t) < within;
}

/// Enlace del widget: abre una pestaña de Personal y no trae token propio
bool isExternalPersonalLink(Uri uri) =>
    uri.path == AppRoutes.personal &&
    uri.queryParameters.containsKey('tab') &&
    !uri.queryParameters.containsKey('n');

/// Solo ruta y query, sin esquema ni host (kaku://app/...)
String routeLocation(Uri uri) =>
    uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
