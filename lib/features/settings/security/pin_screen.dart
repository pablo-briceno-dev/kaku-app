import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaku/shared/services/app_pin_service.dart';

enum PinMode { create, confirm, verify }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? pinToConfirm; // solo en mode.confirm
  final String title;
  final String? subtitle;
  final bool canDismiss;

  const PinScreen({
    super.key,
    required this.mode,
    this.pinToConfirm,
    required this.title,
    this.subtitle,
    this.canDismiss = true,
  });

  // ── Helpers para abrir cada modo ────────────────────

  // Crea un PIN nuevo (dos pasos: ingresar + confirmar)
  // Devuelve el PIN si se completó, null si canceló
  static Future<String?> createPin(BuildContext context) async {
    final pin = await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(
        builder: (_) => const PinScreen(
          mode: PinMode.create,
          title: 'Crear PIN',
          subtitle: 'Elige un PIN de 4 dígitos',
        ),
      ),
    );
    if (pin == null || !context.mounted) return null;

    // Paso 2: confirmar el PIN
    final confirmed = await Navigator.of(context, rootNavigator: true)
        .push<String>(
          MaterialPageRoute(
            builder: (_) => PinScreen(
              mode: PinMode.confirm,
              pinToConfirm: pin,
              title: 'Confirmar PIN',
              subtitle: 'Ingresa el PIN nuevamente',
            ),
          ),
        );
    return confirmed;
  }

  // Verifica el PIN existente
  // Devuelve true si fue correcto
  static Future<bool> verifyPin(BuildContext context) async {
    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PinScreen(
          mode: PinMode.verify,
          title: 'Ingresa tu PIN',
          canDismiss: false,
        ),
      ),
    );
    return result ?? false;
  }

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  static const _pinLength = 4;

  String _pin = '';
  String _errorMessage = '';
  int _attempts = 0;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (_pin.length >= _pinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += key;
      _errorMessage = '';
    });
    if (_pin.length == _pinLength) {
      // Pequeño delay para que el usuario vea el último punto
      Future.delayed(const Duration(milliseconds: 150), _onPinComplete);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _onPinComplete() async {
    switch (widget.mode) {
      case PinMode.create:
        // Devuelve el PIN al caller para el paso de confirmación
        if (mounted) Navigator.of(context).pop(_pin);

      case PinMode.confirm:
        if (_pin == widget.pinToConfirm) {
          // Confirmación correcta → devuelve el PIN
          if (mounted) Navigator.of(context).pop(_pin);
        } else {
          _shake();
          setState(() {
            _pin = '';
            _errorMessage = 'Los PINs no coinciden. Intenta de nuevo.';
          });
        }

      case PinMode.verify:
        final correct = await AppPinService.verifyPin(_pin);
        if (correct) {
          if (mounted) Navigator.of(context).pop(true);
        } else {
          _attempts++;
          _shake();
          setState(() {
            _pin = '';
            _errorMessage = _attempts >= 3
                ? 'PIN incorrecto ($_attempts intentos fallidos)'
                : 'PIN incorrecto. Intenta de nuevo.';
          });
        }
    }
  }

  void _shake() {
    HapticFeedback.vibrate();
    _shakeCtrl.forward().then((_) => _shakeCtrl.reset());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: widget.canDismiss
          ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Título y subtítulo
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],

            const SizedBox(height: 40),

            // Puntos del PIN con animación de shake
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) {
                final dx = _shakeAnim.value > 0
                    ? 12 * (0.5 - _shakeAnim.value).abs() * 2
                    : 0.0;
                return Transform.translate(
                  offset: Offset(dx * (_shakeAnim.value > 0.5 ? -1 : 1), 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Mensaje de error
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _errorMessage.isEmpty
                  ? const SizedBox(height: 20)
                  : Text(
                      _errorMessage,
                      key: ValueKey(_errorMessage),
                      style: TextStyle(fontSize: 13, color: cs.error),
                    ),
            ),

            const Spacer(),

            // Teclado numérico
            _NumPad(onKeyPressed: _onKeyPressed, onDelete: _onDelete),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Teclado numérico ─────────────────────────────────────
class _NumPad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onDelete;

  const _NumPad({required this.onKeyPressed, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: keys
        .map((k) => _NumKey(label: k, onTap: () => onKeyPressed(k)))
        .toList(),
  );

  Widget _buildBottomRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      const SizedBox(width: 72), // espacio vacío izquierda
      _NumKey(label: '0', onTap: () => onKeyPressed('0')),
      _NumKey(icon: Icons.backspace_outlined, onTap: onDelete),
    ],
  );
}

class _NumKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _NumKey({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        alignment: Alignment.center,
        child: label != null
            ? Text(
                label!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(icon, size: 22, color: cs.onSurface),
      ),
    );
  }
}
