import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoCodeService {
  static const _kUsedCodes = 'used_promo_codes';

  // ── Hashes de códigos válidos ─────────────────────────
  static const _validHashes = <String>{
    // 'KAKU-BETA-2026' ← código general para testers
    '00d4feaecca1f7a590037b420499c9ee0fc1eddbf14d6159c17615ac95dcdfba',
    // 'PABLO-DEV' ← tu código personal
    '9889c38cd0f288c84018b15f7e11273fe06130faf3a036d5e52e10f93ace2097',
    // 'TESTER-01'
    'c998a762fb566c14af67f5e12ed5f39916608b038a8b06555f6253326d419e4c',
    // 'TESTER-02'
    '713498a3731aedf97e01724e2e4b04ff857a61737da9fba51797ff44380288a7',
    // 'TESTER-03'
    '90d3f92cb9dff39db9d49efe3d110e9ae60e9d11550e986c98452d7e70bc88ad',
    // Agrega más hashes aquí cuando necesites más testers
  };

  // ── Canjear un código ─────────────────────────────────
  static Future<RedeemResult> redeem(String code) async {
    // Normaliza y hashea el código ingresado
    final inputHash = _hash(code);

    // 1. Verificar que sea un código válido
    if (!_validHashes.contains(inputHash)) {
      return RedeemResult.invalid;
    }

    // 2. Verificar que no haya sido canjeado en este dispositivo
    final prefs = await SharedPreferences.getInstance();
    final usedList = prefs.getStringList(_kUsedCodes) ?? [];

    if (usedList.contains(inputHash)) {
      return RedeemResult.alreadyUsed;
    }

    // 3. Marcar como usado y activar premium
    usedList.add(inputHash);
    await prefs.setStringList(_kUsedCodes, usedList);
    await PremiumService.activate(source: 'promo_code');

    return RedeemResult.success;
  }

  // ── Generar hash de un código ─────────────────────────
  // Úsalo para generar nuevos hashes sin ejecutar el script:
  //   debugPrint(PromoCodeService.generateHash('MI-NUEVO-CODIGO'));
  static String generateHash(String code) => _hash(code);

  static String _hash(String code) =>
      sha256.convert(utf8.encode(code.trim().toUpperCase())).toString();
}

enum RedeemResult { success, invalid, alreadyUsed }
