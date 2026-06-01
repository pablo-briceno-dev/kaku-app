// ── Estado de biometría ───────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/services/biometric_service.dart';
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
    state = await BiometricService.isEnabled();
  }

  // Activa: pide autenticación antes de guardar
  // Desactiva: también pide autenticación (para que otro no lo desactive)
  Future<BiometricToggleResult> toggle(bool newValue) async {
    final result = await BiometricService.authenticate(
      reason: newValue
          ? 'Confirma tu identidad para activar la biometría'
          : 'Confirma tu identidad para desactivar la biometría',
    );

    if (result != BiometricResult.success) {
      return BiometricToggleResult(
        success: false,
        error: _errorMessage(result),
      );
    }

    await BiometricService.setEnabled(newValue);
    state = newValue;
    return BiometricToggleResult(success: true);
  }

  String _errorMessage(BiometricResult result) => switch (result) {
    BiometricResult.notEnrolled =>
      'No tienes biometría configurada en el dispositivo. '
          'Ve a Ajustes → Seguridad para configurarla.',
    BiometricResult.notAvailable =>
      'Tu dispositivo no soporta autenticación biométrica.',
    BiometricResult.lockedOut =>
      'Biometría bloqueada por demasiados intentos. '
          'Desbloquea el dispositivo con tu PIN primero.',
    _ => 'No se pudo autenticar. Intenta de nuevo.',
  };
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
