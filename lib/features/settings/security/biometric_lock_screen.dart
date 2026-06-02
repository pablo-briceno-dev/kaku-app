import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/security/pin_screen.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:kaku/shared/services/app_pin_service.dart';
import 'package:kaku/shared/services/biometric_service.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  final Widget child;
  const BiometricLockScreen({super.key, required this.child});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Bloquea cuando la app pasa a segundo plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final biometricsEnabled = ref.read(biometricsEnabledProvider);
      if (biometricsEnabled) setState(() => _isLocked = true);
    }
    if (state == AppLifecycleState.resumed && _isLocked) {
      _authenticate();
    }
  }

  Future<void> _checkAndLock() async {
    final pinEnabled = await AppPinService.isEnabled();
    final biometricEnabled = await BiometricService.isEnabled();
    if ((pinEnabled || biometricEnabled) && mounted) {
      setState(() => _isLocked = true);
      await _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    final pinEnabled = await AppPinService.isEnabled();

    if (pinEnabled) {
      // Usa el PIN propio de la app
      if (mounted) {
        final verified = await PinScreen.verifyPin(context);
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
            if (verified) _isLocked = false;
          });
        }
      }
    } else {
      // Usa la biometría del sistema
      final result = await BiometricService.authenticate(
        reason: 'Confirma tu identidad para acceder a Kaku',
      );
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          if (result == BiometricResult.success) _isLocked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) return widget.child;

    // Pantalla de bloqueo
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
              'Kaku bloqueado',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa tu biometría para continuar',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _isAuthenticating ? null : _authenticate,
              icon: _isAuthenticating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(_isAuthenticating ? 'Verificando...' : 'Desbloquear'),
            ),
          ],
        ),
      ),
    );
  }
}
