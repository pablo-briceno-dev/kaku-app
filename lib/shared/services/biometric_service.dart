// import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBiometricsEnabled = 'biometrics_enabled';

class BiometricService {
  static final _auth = LocalAuthentication();

  // ── ¿El dispositivo puede autenticar? ────────────────
  // Con biometricOnly: false solo necesita que el dispositivo
  // tenga PIN/patrón/contraseña configurado — sin importar
  // si tiene huella o cara.
  static Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  // ── ¿Tiene biometría enrollada? ───────────────────────
  // Útil para mostrar el ícono correcto (huella/cara/PIN)
  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  // ── ¿Qué tipo de biometría tiene el dispositivo? ─────
  // Útil para mostrar el icono correcto (huella o cara)
  static Future<BiometricType?> getAvailableType() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return BiometricType.face;
      if (types.contains(BiometricType.fingerprint))
        return BiometricType.fingerprint;
      if (types.contains(BiometricType.strong)) return BiometricType.strong;
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Autenticar al usuario ─────────────────────────────
  // Devuelve true si autenticó correctamente.
  // reason: texto que aparece en el diálogo del sistema.
  static Future<BiometricResult> authenticate({required String reason}) async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return authenticated ? BiometricResult.success : BiometricResult.failed;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        // LocalAuthExceptionCode.notEnrolled         => BiometricResult.notEnrolled,
        LocalAuthExceptionCode.noBiometricHardware =>
          BiometricResult.notAvailable,
        LocalAuthExceptionCode.temporaryLockout => BiometricResult.lockedOut,
        LocalAuthExceptionCode.biometricLockout => BiometricResult.lockedOut,
        _ => BiometricResult.failed,
      };
    } catch (_) {
      return BiometricResult.failed;
    }
  }

  // ── Leer estado guardado ──────────────────────────────
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometricsEnabled) ?? false;
  }

  // ── Guardar estado ────────────────────────────────────
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricsEnabled, value);
  }
}

enum BiometricResult { success, failed, notEnrolled, notAvailable, lockedOut }
