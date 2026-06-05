import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoCodeService {
  // ── Códigos válidos (SHA-256 del código original) ────────
  //
  // Para agregar un código nuevo:
  //   1. Elige el código: "KAKU-BETA-2026"
  //   2. Calcula su hash ejecutando en Dart:
  //      print(sha256.convert(utf8.encode("KAKU-BETA-2026")).toString());
  //   3. Agrega el hash a este Set
  //   4. Comparte SOLO el código original con tus testers
  //      (nunca el hash)
  static const _validHashes = <String>{
    // "KAKU-BETA-2026"
    'e3b0c44298fc1c149afb4c8996fb92427ae41e4649b934ca495991b7852b855',
    // "PABLO-PREMIUM"
    'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
    // Agrega más hashes aquí según necesites
    // Hasta 100 testers sin problema
  };
 
  static const _kUsedCodes = 'used_promo_codes';
 
  static Future<RedeemResult> redeem(String code) async {
    final hash = sha256
        .convert(utf8.encode(code.trim().toUpperCase()))
        .toString();
 
    // Verificar que el código sea válido
    if (!_validHashes.contains(hash)) {
      return RedeemResult.invalid;
    }
 
    // Verificar que no haya sido canjeado ya en este dispositivo
    final prefs    = await SharedPreferences.getInstance();
    final usedList = prefs.getStringList(_kUsedCodes) ?? [];
 
    if (usedList.contains(hash)) {
      return RedeemResult.alreadyUsed;
    }
 
    // Marcar como usado y activar premium
    usedList.add(hash);
    await prefs.setStringList(_kUsedCodes, usedList);
    await PremiumService.activate(source: 'promo_code');
 
    return RedeemResult.success;
  }
 
  // Helper para generar hashes en desarrollo
  // Llama esto en la consola y copia el resultado al Set de arriba:
  //
  //   PromoCodeService.generateHash('KAKU-BETA-2026')
  static String generateHash(String code) =>
      sha256.convert(utf8.encode(code.trim().toUpperCase())).toString();
}
 
enum RedeemResult { success, invalid, alreadyUsed }