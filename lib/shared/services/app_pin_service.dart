import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPinHash = 'app_pin_hash';
const _kPinEnabled = 'app_pin_enabled';

class AppPinService {
  // ── ¿Tiene PIN configurado? ──────────────────────────
  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPinHash) != null;
  }

  // ── Guardar PIN nuevo ────────────────────────────────
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _hashPin(pin);
    await prefs.setString(_kPinHash, hash);
    await prefs.setBool(_kPinEnabled, true);
  }

  // ── Verificar PIN ingresado ──────────────────────────
  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPinHash);
    if (saved == null) return false;
    return _hashPin(pin) == saved;
  }

  // ── Eliminar PIN (al desactivar) ─────────────────────
  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPinHash);
    await prefs.setBool(_kPinEnabled, false);
  }

  // ── Estado activo ────────────────────────────────────
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPinEnabled) ?? false;
  }

  // ── Hash SHA-256 del PIN ─────────────────────────────
  // Nunca guardamos el PIN en texto plano
  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }
}
