import 'package:flutter/foundation.dart';

/// Ruta pendiente de abrir por el toque de una notificación
final pendingNotificationRoute = ValueNotifier<String?>(null);

void handleNotificationPayload(String? payload) {
  // Solo se aceptan rutas del calendario, que son las que programamos nosotros
  if (payload != null && payload.startsWith('/personal')) {
    pendingNotificationRoute.value = payload;
  }
}
