import 'package:shared_preferences/shared_preferences.dart';

class PremiumLimits {
  // Metas
  static const int maxGoals = 3;
  // Presupuestos
  static const int maxBudgets = 3;
  // Categorías personalizadas (las default no cuentan)
  static const int maxCustomCategories = 5;
  // Exportación
  static const bool canExportCsv = true; // free puede CSV
  static const bool canExportPdfBasic = true; // free puede PDF básico
  static const bool canExportPdfWithReceipts = false; // solo premium
  static const bool canExportCustomRange = false; // solo premium
  // Backup
  static const bool canBackupLocal = true; // free puede local
  static const bool canBackupDrive = false; // solo premium
  // Estadísticas
  static const bool canViewHistory = false; // solo premium (>1 mes)
  // Seguridad
  static const bool canUsePinLock = false; // solo premium
}

class PremiumService {
  static const _kIsPremium = 'is_premium';
  static const _kPremiumSource = 'premium_source'; // 'purchase' | 'promo'
  static const _kPremiumDate = 'premium_activated_date';

  // Estado actual
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsPremium) ?? false;
  }

  // Activar premium
  // source: 'purchase' | 'promo_code' | 'restore'
  static Future<void> activate({required String source}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPremium, true);
    await prefs.setString(_kPremiumSource, source);
    await prefs.setString(_kPremiumDate, DateTime.now().toIso8601String());
    // debugPrint('premium activated - fuente: $source');
  }

  // Renovar premium (por si se hace refound)
  static Future<void> revoke() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPremium, false);
    await prefs.remove(_kPremiumSource);
    await prefs.remove(_kPremiumDate);
  }

  // Info del plan
  static Future<PremiumInfo> getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(_kIsPremium) ?? false;
    final source = prefs.getString(_kPremiumSource);
    final dateStr = prefs.getString(_kPremiumDate);
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    return PremiumInfo(isActive: active, source: source, activatedAt: date);
  }

  // Verificar si puede realizar una acción
  static Future<PremiumBlockReason?> canDo(PremiumFeature feature) async {
    final premium = await isPremium();
    if (premium) return null; // premium puede todo

    return switch (feature) {
      PremiumFeature.backupDrive => PremiumBlockReason.backupDrive,
      PremiumFeature.exportPdfWithReceipts =>
        PremiumBlockReason.exportPdfWithReceipts,
      PremiumFeature.exportCustomRange => PremiumBlockReason.exportCustomRange,
      PremiumFeature.viewHistory => PremiumBlockReason.viewHistory,
      PremiumFeature.pinLock => PremiumBlockReason.pinLock,
      PremiumFeature.unlimitedGoals => PremiumBlockReason.unlimitedGoals,
      PremiumFeature.unlimitedBudgets => PremiumBlockReason.unlimitedBudgets,
      PremiumFeature.unlimitedCategories =>
        PremiumBlockReason.unlimitedCategories,
    };
  }
}

// ── Modelo de info del plan ───────────────────────────────
class PremiumInfo {
  final bool isActive;
  final String? source;
  final DateTime? activatedAt;

  const PremiumInfo({required this.isActive, this.source, this.activatedAt});
}

// ── Features que requieren premium ───────────────────────
enum PremiumFeature {
  backupDrive,
  exportPdfWithReceipts,
  exportCustomRange,
  viewHistory,
  pinLock,
  unlimitedGoals,
  unlimitedBudgets,
  unlimitedCategories,
}

/// Razones por las que una acción está bloqueada.
/// Cada una corresponde a una clave ARB en inglés.
enum PremiumBlockReason {
  backupDrive,
  exportPdfWithReceipts,
  exportCustomRange,
  viewHistory,
  pinLock,
  unlimitedGoals,
  unlimitedBudgets,
  unlimitedCategories,
}
