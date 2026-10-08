import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/widgets/switch_list_tile_child.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:local_auth/local_auth.dart';

class BiometricToggle extends ConsumerWidget {
  const BiometricToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEnabled = ref.watch(biometricsEnabledProvider);
    final biometricType = ref.watch(biometricTypeProvider);

    // ✅ Ícono y label según el método disponible:
    //    huella → Icons.fingerprint
    //    cara   → Icons.face_retouching_natural
    //    solo PIN (sin biometría) → Icons.pin_outlined
    final (icon, label) = biometricType.when(
      loading: () => (Icons.lock_outline, l10n.securityBiometrics),
      error: (_, _) => (Icons.lock_outline, l10n.securityBiometrics),
      data: (type) => switch (type) {
        BiometricType.face => (Icons.face_retouching_natural, l10n.securityFaceId),
        BiometricType.fingerprint => (Icons.fingerprint, l10n.securityFingerprint),
        BiometricType.strong => (Icons.fingerprint, l10n.securityFingerprint),
        null => (Icons.pin_outlined, l10n.securityPin),
        _ => (Icons.lock_outline, l10n.securityBiometrics),
      },
    );

    final subtitle = isEnabled
        ? l10n.biometricEnableSubtitle
        : l10n.biometricDisableSubtitle;

    return SwitchListTileChild(
      label: label,
      subtitle: subtitle,
      icon: icon,
      value: isEnabled,
      onChanged: (value) => _onToggle(context, l10n, ref, value),
    );
  }

  Future<void> _onToggle(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    bool newValue,
  ) async {
    final result = await ref
        .read(biometricsEnabledProvider.notifier)
        .toggle(newValue, context); // ← pasa context para PinScreen

    if (!context.mounted) return;

    // Solo muestra error si hay mensaje (null = usuario canceló)
    if (!result.success && result.error != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.biometricNotConfigured),
          content: Text(result.error!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text(l10n.btnUnderstood),
            ),
          ],
        ),
      );
    }
  }
}
