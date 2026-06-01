import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kNotificationsEnabled = 'notifications_enabled';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── Inicializar (llama en main.dart) ──────────────────
  static Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: false, // pedimos permiso manualmente
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: iOS),
    );

    _initialized = true;
  }

  // ── Solicitar permiso del sistema ─────────────────────
  // Devuelve true si el usuario aceptó
  static Future<bool> requestPermission() async {
    // Android 13+ necesita permiso explícito
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // ── ¿Tiene permiso actualmente? ──────────────────────
  static Future<bool> hasPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // ── Leer estado guardado ──────────────────────────────
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotificationsEnabled) ?? false;
  }

  // ── Guardar estado ────────────────────────────────────
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsEnabled, value);
  }

  // ── Enviar notificación de alerta de presupuesto ──────
  // Llámalo desde budgetProgressProvider cuando progress >= 0.8
  static Future<void> showBudgetAlert({
    required String categoryName,
    required String categoryEmoji,
    required double percentage,
    required String spent,
    required String limit,
  }) async {
    if (!await isEnabled()) return;
    if (!await hasPermission()) return;

    final isExceeded = percentage >= 1.0;
    final title = isExceeded
        ? '$categoryEmoji Presupuesto excedido'
        : '$categoryEmoji Presupuesto al ${(percentage * 100).toStringAsFixed(0)}%';
    final body = isExceeded
        ? 'Gastaste $spent de $limit en $categoryName este mes'
        : 'Llevas $spent de $limit en $categoryName';

    await _plugin.show(
      id: categoryName.hashCode, // id único por categoría
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts', // channel id
          'Alertas de presupuesto', // channel name
          channelDescription: 'Avisos cuando te acercas al límite mensual',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // icon: '@drawable/ic_launcher_foreground',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
