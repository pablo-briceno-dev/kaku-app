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
    // KAKU-TESTER-01
    'ace7c754523bce69653c7043c967c82f38e947efbbbfc4208200d6a7de7eed60',
    // KAKU-TESTER-02
    'b561a2b9ec74a20952014228d4f873add7f679062efe4dbb2b6fc5a7db49121a',
    // KAKU-TESTER-03
    'bed84bf8bb713f2755596cd69c113a4d0eb5013f762c2f76a3e7a9d326764096',
    // KAKU-TESTER-04
    '2f9ef243e0f1782c99743248b93e14889efbeecfa59e449db4295ce3a237c8fa',
    // KAKU-TESTER-05
    '6a4bcdda525efe472c7b6bcc6a6d507513cac62868ec64a080e4dec59cbd6934',
    // KAKU-TESTER-06
    '96adeb3f9b7bda6f5812b4a45b422b050a6c79406c15c2779ba4cd75fe4ac84b',
    // KAKU-TESTER-07
    'fcc06d36c640f1f0d90cda8856720dd6358dcccc80cc1f3826e80dc20a4a9d10',
    // KAKU-TESTER-08
    '953b89bdb2a0415ee965b9305269343caa345d22c57eebaa93d0350f848a3d21',
    // KAKU-TESTER-09
    '1aa68d89bd40bbcabe7242fd260b5aeb462ed1e8dfd9a561c7363d04d772ce1f',
    // KAKU-TESTER-10
    '9fd40b72dacc22338b638d3223445e390b07ccb58201d610360bd21db021b0c2',
    // KAKU-TESTER-11
    '9eddade0a571ed7ec488706e7a8a9dce1a0ac7d913e523cd8beaa39541ff7744',
    // KAKU-TESTER-12
    'e92224a96609490cb06e0a411098416adcddee4cee6aef03ad31ff46ade372b4',
    // KAKU-TESTER-13
    '7a155c53356beb3a0d08dfe80ddf23d70e77b069da1b606162e233083944697d',
    // KAKU-TESTER-14
    '900b58a978b0fb9d2dcf8422dd36e2aa618d2fcd97aa86306fffbbfe286c9782',
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
