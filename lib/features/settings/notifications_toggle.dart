import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/widgets/switch_list_tile_child.dart';
import 'package:kaku/shared/providers/notification_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsToggle extends ConsumerWidget {
  const NotificationsToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(notificationsEnabledProvider);

    return SwitchListTileChild(
      label: 'Notificaciones',
      subtitle: isEnabled ? 'Activo · Alertas de presupuesto' : 'Inactivo',
      icon: Icons.notifications,
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
        .read(notificationsEnabledProvider.notifier)
        .toggle(newValue);

    if (!context.mounted) return;

    if (!result.success && result.permissionDenied) {
      // El usuario denegó el permiso del sistema
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permiso de notificaciones'),
          content: const Text(
            'Kaku necesita permiso para enviarte alertas cuando '
            'te acercas al límite de un presupuesto.\n\n'
            'Habilítalo en los Ajustes del dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings(); // de permission_handler
              },
              child: const Text('Abrir Ajustes'),
            ),
          ],
        ),
      );
    }
  }
}
