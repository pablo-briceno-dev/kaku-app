import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/settings/security/pin_screen.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:kaku/shared/services/app_pin_service.dart';
import 'package:kaku/shared/services/biometric_service.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    final pinEnabled = await AppPinService.isEnabled();
    final biometricEnabled = await BiometricService.isEnabled();

    if (!mounted) return;

    // Sin bloqueo → ir directo
    if (!pinEnabled && !biometricEnabled) {
      ref.read(authenticationStateProvider.notifier).state =
          true; // ✅ marcar autenticado
      context.go(AppRoutes.dashboard);
      return;
    }

    if (pinEnabled) {
      final verified = await PinScreen.verifyPin(context);
      if (!mounted) return;
      if (verified) {
        ref.read(authenticationStateProvider.notifier).state =
            true; // ✅ marcar autenticado
        context.go(AppRoutes.dashboard); // ✅ ruta correcta
      }
    } else {
      final result = await BiometricService.authenticate(
        reason: 'Confirma tu identidad para acceder a Kaku',
      );
      if (!mounted) return;
      if (result == BiometricResult.success) {
        ref.read(authenticationStateProvider.notifier).state =
            true; // ✅ marcar autenticado
        context.go(AppRoutes.dashboard); // ✅ ruta correcta
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 56, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Kaku',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
