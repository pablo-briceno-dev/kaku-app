import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/premium_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';

class PremiumGate extends ConsumerWidget {
  final PremiumFeature feature;
  final Widget child;
  final bool showLockBadge; // muestra el candado en la esquina

  const PremiumGate({
    super.key,
    required this.feature,
    required this.child,
    required this.showLockBadge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumNotifierProvider);

    return premiumAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (isPremium) {
        if (isPremium) return child; // premium -> sin restricción

        // Free -> envuelve con GestureDetector que abre el paywall
        return Stack(
          children: [
            // Widget original con opacidad reducida
            Opacity(opacity: 0.5, child: child),
            // Overlay tappable
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _showPaywall(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            if (showLockBadge)
              Positioned(top: 8, right: 8, child: _LockBadge()),
          ],
        );
      },
    );
  }

  void _showPaywall(BuildContext context) {
    // TODO: abrir PremiumScreen - se implementa en Paso 3
    // Por ahora muestra un snackbar informativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Esta función es Premium'),
        action: SnackBarAction(
          label: 'Ver planes',
          onPressed: () {
            // context.push(AppRoutes.premium)
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 11, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  PremiumLimitChecker — verifica antes de crear
//
//  Úsalo antes de insertar un nuevo registro para verificar
//  si el usuario ya llegó al límite del plan free.
//
//  Uso en GoalsScreen al tocar "+ Nueva meta":
//
//    final blocked = await PremiumLimitChecker.check(
//      context: context,
//      feature: PremiumFeature.unlimitedGoals,
//      currentCount: goals.length,
//      limit: PremiumLimits.maxGoals,
//    );
//    if (blocked) return; // no continuar
//    // abrir formulario de nueva meta
// ════════════════════════════════════════════════════════
class PremiumLimitChecker {
  static Future<bool> check({
    required BuildContext  context,
    required PremiumFeature feature,
    required int           currentCount,
    required int           limit,
  }) async {
    final premium = await PremiumService.isPremium();
    if (premium) return false; // premium → no bloqueado
 
    if (currentCount < limit) return false; // no llegó al límite
 
    // Llegó al límite → mostrar dialog
    final reason = await PremiumService.canDo(feature);
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => _LimitReachedDialog(reason: reason ?? ''),
      );
    }
    return true; // bloqueado
  }
}
 
class _LimitReachedDialog extends StatelessWidget {
  final String reason;
  const _LimitReachedDialog({required this.reason});
 
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Text('👑', style: TextStyle(fontSize: 32)),
      title: const Text('Límite alcanzado'),
      content: Text(reason),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:     const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            // context.push(AppRoutes.premium)
          },
          child: const Text('Ver Premium'),
        ),
      ],
    );
  }
}
