import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/security/pin_screen.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/security_provider.dart';
import 'package:kaku/shared/services/app_pin_service.dart';
import 'package:kaku/shared/services/biometric_service.dart';
import 'package:kaku/shared/services/last_route_service.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with WidgetsBindingObserver {
  bool _isAuthenticating = false;
  bool _biometricInFlight = false; // el prompt del sistema está abierto
  bool _needsAuth = false; // reintentar cuando la app vuelva al frente
  int _attempt = 0; // invalida intentos viejos que quedaron colgados

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWhenResumed());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startWhenResumed() {
    final s = WidgetsBinding.instance.lifecycleState;
    if (s == null || s == AppLifecycleState.resumed) {
      _authenticate();
    } else {
      // El prompt biométrico no puede mostrarse hasta que la app esté activa
      _needsAuth = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_biometricInFlight) {
        // El prompt del sistema se cancela al ir a segundo plano
        _attempt++;
        _biometricInFlight = false;
        _needsAuth = true;
        if (mounted) setState(() => _isAuthenticating = false);
      } else if (!_isAuthenticating) {
        _needsAuth = true;
      }
    } else if (state == AppLifecycleState.resumed && _needsAuth) {
      _needsAuth = false;
      // Al volver desde el widget la actividad aún se está acomodando
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _authenticate();
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final attempt = ++_attempt;
    bool stale() => !mounted || attempt != _attempt;
    setState(() => _isAuthenticating = true);

    try {
      final pinEnabled = await AppPinService.isEnabled();
      final biometricEnabled =
          await BiometricService.isEnabled(); // misma fuente que el router
      if (stale()) return;
      if(!mounted) return;

      if (!pinEnabled && !biometricEnabled) {
        ref.read(authenticationStateProvider.notifier).state = true;
        await LastRouteService.goToStart(context);
        return;
      }

      var authenticated = false;

      if (pinEnabled) {
        authenticated = await PinScreen.verifyPin(context);
      } else {
        _biometricInFlight = true;
        final result =
            await BiometricService.authenticate(
              reason: l10n.biometricAuthReason,
            ).timeout(
              const Duration(seconds: 90),
              onTimeout: () => BiometricResult.failed,
            );
        _biometricInFlight = false;
        if (stale()) return;

        authenticated = result == BiometricResult.success;
        if (!authenticated && result == BiometricResult.failed) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.biometricAuthFailed),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      if (!mounted) return;
      if (authenticated) {
        ref.read(authenticationStateProvider.notifier).state = true;
        await LastRouteService.goToStart(context);
      }
    } catch (e) {
      if (!stale()) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted && attempt == _attempt) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  // Salida de emergencia: descarta cualquier intento que haya quedado colgado
  void _retry() {
    _attempt++;
    _biometricInFlight = false;
    setState(() => _isAuthenticating = false);
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              _isAuthenticating
                  ? l10n.biometricLockVerifying
                  : l10n.biometricLockSubtitle,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            // Siempre visible: nunca más queda una pantalla sin salida
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.fingerprint),
              label: Text(l10n.btnRetry),
            ),
          ],
        ),
      ),
    );
  }
}
