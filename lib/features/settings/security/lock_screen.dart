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
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final pinEnabled = await AppPinService.isEnabled();
      final biometricEnabled = ref.read(biometricsEnabledProvider);

      debugPrint(
        '🔐 pinEnabled: $pinEnabled, biometricEnabled: $biometricEnabled',
      );

      if (!pinEnabled && !biometricEnabled) {
        // Sin bloqueo → ir directo al dashboard
        ref.read(authenticationStateProvider.notifier).state = true;
        if (mounted) {
          context.go(AppRoutes.dashboard);
        }
        return;
      }

      bool authenticated = false;

      if (pinEnabled && mounted) {
        authenticated = await PinScreen.verifyPin(context);
      } else if (biometricEnabled) {
        final result = await BiometricService.authenticate(
          reason: 'Confirma tu identidad para acceder a Kaku',
        );
        authenticated = result == BiometricResult.success;
        if (!authenticated && result == BiometricResult.failed) {
          // Mostrar mensaje de error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Autenticación fallida. Intenta de nuevo.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }

      if (authenticated && mounted) {
        ref.read(authenticationStateProvider.notifier).state = true;
        context.go(AppRoutes.dashboard);
      } else {
        // Si falla, no se navega y se queda en la pantalla de bloqueo
        setState(() => _isAuthenticating = false);
      }
    } catch (e) {
      debugPrint('❌ Error en autenticación: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isAuthenticating = false);
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
            if (_isAuthenticating)
              const CircularProgressIndicator()
            else
              Icon(Icons.lock_outline_rounded, size: 56, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Kaku',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _isAuthenticating ? 'Verificando...' : 'Desbloqueando...',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            if (!_isAuthenticating)
              FilledButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }
}
