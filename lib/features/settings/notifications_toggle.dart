import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/widgets/switch_list_tile_child.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/notification_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsToggle extends ConsumerWidget {
  const NotificationsToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEnabled = ref.watch(notificationsEnabledProvider);

    return SwitchListTileChild(
      label: l10n.notifTitle,
      subtitle: isEnabled
          ? l10n.notifActivatingBudget
          : l10n.notifDeactivatingBudget,
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
    final l10n = AppLocalizations.of(context)!;
    final result = await ref
        .read(notificationsEnabledProvider.notifier)
        .toggle(newValue);

    if (!context.mounted) return;

    if (!result.success && result.permissionDenied) {
      // El usuario denegó el permiso del sistema
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.notifPermissionTitle),
          content: const Text(l10n.notifPermissionSubtitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings(); // de permission_handler
              },
              child: Text(l10n.btnOpenSettings),
            ),
          ],
        ),
      );
    }
  }
}
