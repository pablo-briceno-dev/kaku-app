import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:kaku/shared/services/premium_service.dart';

// ── ID del producto en Google Play Console ────────────────────
// Lo configuras en Play Console → Monetización → Productos →
// Productos de pago único
// Debe coincidir EXACTAMENTE con el que pusiste en Play Console
const _kPremiumProductId = 'kaku_premium_lifetime';

// ── API Key de RevenueCat ─────────────────────────────────────
// La obtienes en app.revenuecat.com → tu app → API Keys
// Guárdala en .env:
//   REVENUECAT_ANDROID_KEY=appl_xxxxxxxxxx
String _kRevenueCatAndroidKey = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

class BillingService {
  // ── Inicializar RevenueCat ────────────────────────────────────
  // Llama en main.dart antes de runApp
  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // await Purchases.setLogLevel(LogLevel.debug); // TODO: quitar en producción
    // debugPrint('BillingService.initialize key: $_kRevenueCatAndroidKey');
    await Purchases.configure(PurchasesConfiguration(_kRevenueCatAndroidKey));

    // Si el usuario ya era premium (compra previa), sincronizar
    await _syncPremiumStatus();
  }

  // ── Sincronizar estado de premium con RevenueCat ──────────────
  static Future<void> _syncPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.containsKey('premium');

      if (isPremium) {
        await PremiumService.activate(source: 'restore');
      }
    } catch (e) {
      debugPrint('BillingService._syncPremiumStatus error: $e');
    }
  }

  // ── Obtener el producto de la tienda ─────────────────────────
  static Future<StoreProduct?> getProduct() async {
    try {
      final products = await Purchases.getProducts([
        _kPremiumProductId,
      ], productCategory: ProductCategory.nonSubscription);
      return products.firstOrNull;
    } catch (e) {
      // debugPrint('BillingService.getProduct error: $e');
      return null;
    }
  }

  // ── Realizar la compra ────────────────────────────────────────
  static Future<BillingResult> purchase() async {
    try {
      // 1. Obtener el producto
      final product = await getProduct();
      if (product == null) {
        return BillingResult.productNotFound;
      }

      // 2. Lanzar el flujo de compra de Google Play
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.storeProduct(product),
      );

      // 3. Verificar si el entitlement quedó activo
      final isPremium = purchaseResult.customerInfo.entitlements.active
          .containsKey('premium');

      if (isPremium) {
        await PremiumService.activate(source: 'purchase');
        return BillingResult.success;
      }

      return BillingResult.failed;
    } on PurchasesErrorCode catch (errorCode) {
      return switch (errorCode) {
        PurchasesErrorCode.purchaseCancelledError => BillingResult.cancelled,
        PurchasesErrorCode.paymentPendingError => BillingResult.pending,
        PurchasesErrorCode.productAlreadyPurchasedError =>
          BillingResult.alreadyPurchased,
        _ => BillingResult.failed,
      };
    } catch (e) {
      // debugPrint('BillingService.purchase error: $e');
      return BillingResult.failed;
    }
  }

  // ── Restaurar compra previa ───────────────────────────────────
  // Para usuarios que reinstalaron la app o cambiaron de dispositivo
  static Future<BillingResult> restore() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.active.containsKey('premium');

      if (isPremium) {
        await PremiumService.activate(source: 'restore');
        return BillingResult.success;
      }

      return BillingResult.notFound;
    } catch (e) {
      // debugPrint('BillingService.restore error: $e');
      return BillingResult.failed;
    }
  }

  // ── Precio formateado desde la tienda ────────────────────────
  // Devuelve el precio real en la moneda local del usuario
  // ej: "US$ 3.99", "COP 16,900", etc.
  static Future<String?> getLocalizedPrice() async {
    final product = await getProduct();
    return product?.priceString;
  }
}

enum BillingResult {
  success,
  cancelled,
  pending,
  failed,
  productNotFound,
  alreadyPurchased,
  notFound, // restore: no se encontró compra previa
}
