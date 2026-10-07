// ── Estado de biometría ───────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/security/lock_method_picker.dart';
import 'package:kaku/features/settings/security/pin_screen.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/services/app_pin_service.dart';
import 'package:kaku/shared/services/biometric_service.dart';
import 'package:kaku/shared/services/notification_service.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod/legacy.dart';

// ── Estado de biometría ───────────────────────────────────
final biometricsEnabledProvider =
    StateNotifierProvider<BiometricsNotifier, bool>((ref) {
      return BiometricsNotifier();
    });

class BiometricsNotifier extends StateNotifier<bool> {
  BiometricsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    // Activo si hay PIN configurado O si la biometría del sistema está activa
    final pinEnabled = await AppPinService.isEnabled();
    final biometricEnabled = await BiometricService.isEnabled();
    state = pinEnabled || biometricEnabled;
  }

  Future<BiometricToggleResult> toggle(
    bool newValue,
    BuildContext context,
  ) async {
    if (newValue) {
      return _activate(context);
    } else {
      return _deactivate(context);
    }
  }

  // ── Activar: intenta biometría del sistema, si no → PIN propio ──
  Future<BiometricToggleResult> _activate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Mostrar el selector de métodos
    final selected = await AppBottomSheet.show<LockMethod>(
      context,
      title: l10n.securityBiometrics,
      subtitle: l10n.securityBiometricsSubtitle,
      useRootNavigator: false,
      isFullScreen: false,
      child: const LockMethodPicker(),
    );
    if (selected == null) {
      return BiometricToggleResult(success: false);
    }
    // El método ya se maneja dentro del picker, pero podemos devolver éxito
    return BiometricToggleResult(success: true);
  }

  // ── Desactivar: pide verificación antes ──────────────
  Future<BiometricToggleResult> _deactivate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final pinEnabled = await AppPinService.isEnabled();

    bool verified = false;

    if (pinEnabled) {
      // Verifica con el PIN propio
      if (!context.mounted) return BiometricToggleResult(success: false);
      verified = await PinScreen.verifyPin(context);
    } else {
      // Verifica con biometría del sistema
      final result = await BiometricService.authenticate(
        reason: l10n.securityUnlockConfirm,
      );
      verified = result == BiometricResult.success;
    }

    if (!verified) {
      return BiometricToggleResult(success: false, error: l10n.securityError);
    }

    await AppPinService.clearPin();
    await BiometricService.setEnabled(false);
    state = false;
    return BiometricToggleResult(success: true);
  }

  // ✅ Método público para activar el bloqueo (desde selector)
  Future<void> enableWithMethod(LockMethod method) async {
    if (method == LockMethod.pin) {
      // Ya se guardó el PIN desde el picker, solo actualizamos estado
      state = true;
    } else {
      // Para biometría, ya se autenticó y se guardó en SharedPreferences
      state = true;
    }
  }

  // ✅ Método para desactivar
  Future<void> disable() async {
    await AppPinService.clearPin();
    await BiometricService.setEnabled(false);
    state = false;
  }
}

class BiometricToggleResult {
  final bool success;
  final String? error;
  const BiometricToggleResult({required this.success, this.error});
}

// ── Tipo de método disponible ────────────────────────────
// null = solo PIN/contraseña (sin biometría)
final biometricTypeProvider = FutureProvider<BiometricType?>((ref) async {
  final hasBiometrics = await BiometricService.hasBiometrics();
  if (!hasBiometrics) return null; // solo PIN disponible
  return BiometricService.getAvailableType();
});

// ── Estado de notificaciones ─────────────────────────────
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
    final isEnabled = await NotificationService.isEnabled();
    // Solo está "activo" si tiene permiso Y está habilitado
    state = hasPermission && isEnabled;
  }

  // Nuevo método para activar directamente con un método
  Future<void> enableWithMethod(LockMethod method) async {
    if (method == LockMethod.pin) {
      // Ya se guardó el PIN desde el picker
      state = true;
    } else {
      // Para biometría, ya se autenticó y se llamó a setEnabled(true)
      state = true;
    }
  }

  Future<BiometricToggleResult> toggle(
    bool newValue,
    BuildContext context,
  ) async {
    if (newValue) {
      final l10n = AppLocalizations.of(context)!;
      // Mostrar selector y esperar método
      final selected = await AppBottomSheet.show<LockMethod>(
        context,
        title: l10n.securityBiometrics,
        subtitle: l10n.securityBiometricsSubtitle,
        useRootNavigator: false,
        isFullScreen: false,
        child: const LockMethodPicker(),
      );
      if (selected == null) {
        return BiometricToggleResult(success: false);
      }
      // El picker ya ejecutó la acción, solo actualizamos estado
      // Pero como el picker llama a toggle de nuevo, evitamos recursión.
      // Mejor: mover la lógica del picker fuera.
      return BiometricToggleResult(success: true);
    } else {
      return _deactivate(context);
    }
  }

  Future<BiometricToggleResult> _deactivate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final pinEnabled = await AppPinService.isEnabled();

    bool verified = false;

    if (pinEnabled) {
      // Verifica con el PIN propio
      if (!context.mounted) return BiometricToggleResult(success: false);
      verified = await PinScreen.verifyPin(context);
    } else {
      // Verifica con biometría del sistema
      final result = await BiometricService.authenticate(
        reason: l10n.securityUnlockConfirm,
      );
      verified = result == BiometricResult.success;
    }

    if (!verified) {
      return BiometricToggleResult(success: false, error: l10n.securityError);
    }

    await AppPinService.clearPin();
    await BiometricService.setEnabled(false);
    state = false;
    return BiometricToggleResult(success: true);
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

// security_provider.dart
final authenticationStateProvider = StateProvider<bool>((ref) => false);

// Funciones auxiliares para modificar el estado
void setAuthenticated(WidgetRef ref, bool value) {
  ref.read(authenticationStateProvider.notifier).state = value;
}

bool isAuthenticated(WidgetRef ref) {
  return ref.read(authenticationStateProvider);
}

enum LockMethod { pin, fingerprint, faceId }

extension LockMethodExtension on LockMethod {
  IconData get icon {
    switch (this) {
      case LockMethod.pin:
        return Icons.pin_outlined;
      case LockMethod.fingerprint:
        return Icons.fingerprint;
      case LockMethod.faceId:
        return Icons.face_retouching_natural;
    }
  }

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      LockMethod.pin => l10n.securityPin,
      LockMethod.fingerprint => l10n.securityFingerprint,
      LockMethod.faceId => l10n.securityFaceId,
    };
  }
}

final availableLockMethodsProvider = FutureProvider<List<LockMethod>>((
  ref,
) async {
  final isPremium = await PremiumService.isPremium();
  final List<LockMethod> methods = [LockMethod.pin];

  if (isPremium) {
    final biometrics = await BiometricService.getAvailableBiometrics();
    for (final type in biometrics) {
      if (type == BiometricType.fingerprint || type == BiometricType.strong) {
        methods.add(LockMethod.fingerprint);
      } else if (type == BiometricType.face) {
        methods.add(LockMethod.faceId);
      }
    }
  }

  return methods;
});
