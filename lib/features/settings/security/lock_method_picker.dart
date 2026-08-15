import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/settings/security/pin_screen.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:kaku/shared/services/app_pin_service.dart';
import 'package:kaku/shared/services/biometric_service.dart';

class LockMethodPicker extends ConsumerWidget {
  const LockMethodPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(availableLockMethodsProvider);

    return methodsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Error al cargar opciones')),
      data: (methods) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ...methods.map(
            (method) => Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: Icon(method.icon),
                title: Text(method.label),
                onTap: () => _selectMethod(context, ref, method),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMethod(
    BuildContext context,
    WidgetRef ref,
    LockMethod method,
  ) async {
    if (method == LockMethod.pin) {
      final pin = await PinScreen.createPin(context);
      if (pin != null) {
        await AppPinService.savePin(pin);
        // Asegurar que biometría quede desactivada
        await BiometricService.setEnabled(false);
        await ref
            .read(biometricsEnabledProvider.notifier)
            .enableWithMethod(LockMethod.pin);
        ref.read(authenticationStateProvider.notifier).state = true;
        if (context.mounted) context.go(AppRoutes.root);
      }
    } else {
      // Biometría (huella o Face ID)
      final result = await BiometricService.authenticate(
        reason: 'Activar bloqueo biométrico',
      );
      if (result == BiometricResult.success) {
        await BiometricService.setEnabled(true);
        debugPrint('✅ Biometría activada y guardada en SharedPreferences');
        // Limpiar PIN si existía
        await AppPinService.clearPin();
        await ref
            .read(biometricsEnabledProvider.notifier)
            .enableWithMethod(method);
        ref.read(authenticationStateProvider.notifier).state = true;
        if (context.mounted) context.go(AppRoutes.root);
      } else {
        // Falló la autenticación
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo activar: ${result.name}')),
          );
        }
      }
    }
  }
}
