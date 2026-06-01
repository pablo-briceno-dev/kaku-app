// ── Estado de notificaciones ─────────────────────────────
import 'package:kaku/shared/services/notification_service.dart';
import 'package:riverpod/legacy.dart';

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  return NotificationsNotifier();
});
 
class NotificationsNotifier extends StateNotifier<bool> {
  NotificationsNotifier() : super(false) {
    _load();
  }
 
  Future<void> _load() async {
    final hasPermission = await NotificationService.hasPermission();
    final isEnabled     = await NotificationService.isEnabled();
    // Solo está "activo" si tiene permiso Y está habilitado
    state = hasPermission && isEnabled;
  }
 
  Future<NotificationToggleResult> toggle(bool newValue) async {
    if (newValue) {
      // Activar: pedir permiso del sistema si no lo tiene
      final hasPermission = await NotificationService.hasPermission();
      if (!hasPermission) {
        final granted = await NotificationService.requestPermission();
        if (!granted) {
          return NotificationToggleResult(
            success: false,
            permissionDenied: true,
          );
        }
      }
    }
 
    await NotificationService.setEnabled(newValue);
    state = newValue;
    return NotificationToggleResult(success: true);
  }
}
 
class NotificationToggleResult {
  final bool success;
  final bool permissionDenied;
  const NotificationToggleResult({
    required this.success,
    this.permissionDenied = false,
  });
}