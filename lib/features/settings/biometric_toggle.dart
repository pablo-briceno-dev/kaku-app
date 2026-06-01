import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/widgets/switch_list_tile_child.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class BiometricToggle extends ConsumerWidget {
  const BiometricToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(biometricsEnabledProvider);
    final biometricType = ref.watch(biometricTypeProvider);

    // ✅ Ícono y label según el método disponible:
    //    huella → Icons.fingerprint
    //    cara   → Icons.face_retouching_natural
    //    solo PIN (sin biometría) → Icons.pin_outlined
    final (icon, label) = biometricType.when(
      loading: () => (Icons.lock_outline, 'Bloqueo de pantalla'),
      error: (_, __) => (Icons.lock_outline, 'Bloqueo de pantalla'),
      data: (type) => switch (type) {
        BiometricType.face => (Icons.face_retouching_natural, 'Face ID'),
        BiometricType.fingerprint => (Icons.fingerprint, 'Huella digital'),
        BiometricType.strong => (Icons.fingerprint, 'Huella digital'),
        null => (Icons.pin_outlined, 'PIN / Contraseña'),
        _ => (Icons.lock_outline, 'Bloqueo de pantalla'),
      },
    );

    final subtitle = isEnabled
        ? 'Activo · Se pide al abrir la app'
        : 'Inactivo · La app no pide confirmación';

    return SwitchListTileChild(
      label: label,
      subtitle: subtitle,
      icon: icon,
      value: isEnabled,
      onChanged: (value) => _onToggle(context, ref, value),
    );
  }

  Future<void> _onToggle(
    BuildContext context,
    WidgetRef ref,
    bool newValue,
  ) async {
    final result = await ref
        .read(biometricsEnabledProvider.notifier)
        .toggle(newValue);

    if (!context.mounted) return;

    if (!result.success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No se pudo configurar'),
          content: Text(result.error ?? 'Error desconocido'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
            if (result.error?.contains('Ajustes') == true)
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Abrir Ajustes'),
              ),
          ],
        ),
      );
    }
  }
}
