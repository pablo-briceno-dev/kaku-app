import 'package:flutter/material.dart';
import 'package:kaku/shared/services/promo_code_service.dart';

class PromoCodeSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const PromoCodeSheet({super.key, required this.onSuccess});

  @override
  State<PromoCodeSheet> createState() => _PromoCodeSheetState();
}

class _PromoCodeSheetState extends State<PromoCodeSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await PromoCodeService.redeem(_ctrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case RedeemResult.success:
        widget.onSuccess();
      case RedeemResult.invalid:
        setState(
          () => _error = 'Código no válido. Verifica e intenta de nuevo.',
        );
      case RedeemResult.alreadyUsed:
        setState(
          () => _error = 'Este código ya fue canjeado en este dispositivo.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '🎁 Canjear código',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Ingresa tu código de descuento o acceso premium',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onFieldSubmitted: (_) => _redeem(),
            decoration: InputDecoration(
              hintText: 'KAKU-XXXX-XXXX',
              errorText: _error,
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton(
            onPressed: _loading ? null : _redeem,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Canjear código'),
          ),
        ],
      ),
    );
  }
}
