import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/receipt_storage.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DangerZoneSheet extends ConsumerStatefulWidget {
  const DangerZoneSheet({super.key});
 
  @override
  ConsumerState<DangerZoneSheet> createState() => _DangerZoneSheetState();
}
 
class _DangerZoneSheetState extends ConsumerState<DangerZoneSheet> {
  final _confirmController = TextEditingController();
  bool _isDeleting = false;
  bool _confirmEnabled = false;
 
  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      setState(() {
        _confirmEnabled =
            _confirmController.text.trim().toUpperCase() == 'BORRAR';
      });
    });
  }
 
  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }
 
  Future<void> _deleteAll() async {
    setState(() => _isDeleting = true);
 
    try {
      final db = ref.read(databaseProvider);
 
      // 1. Eliminar fotos de recibos del disco
      await ReceiptStorage.deleteAll();
 
      // 2. Limpiar todas las tablas de la DB
      await db.deleteEverything();
 
      // 3. Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
 
      if (!mounted) return;
 
      // 4. Cerrar el sheet y navegar al inicio
      Navigator.of(context).pop();
      context.go(AppRoutes.root);
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al borrar los datos: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
 
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
 
          // ── Ícono de advertencia ──
          const Center(
            child: Text('⚠️', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 12),
 
          // ── Título ──
          Text(
            'Borrar todos los datos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.error,
            ),
          ),
          const SizedBox(height: 8),
 
          Text(
            'Esta acción es permanente e irreversible. '
            'Se eliminarán todos los datos de Kaku de tu dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
 
          // ── Lista de qué se borra ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        cs.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(
                color: cs.error.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se eliminará permanentemente:',
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                    color:      cs.error,
                  ),
                ),
                const SizedBox(height: 10),
                ...[
                  ('💸', 'Todas las transacciones'),
                  ('🏦', 'Todas las cuentas'),
                  ('🎯', 'Todas las metas y aportes'),
                  ('📊', 'Todos los presupuestos'),
                  ('🗂️', 'Todas las categorías personalizadas'),
                  ('🖼️', 'Todas las fotos de recibos'),
                  ('⚙️', 'Toda la configuración de la app'),
                ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text(item.$1,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
 
          const SizedBox(height: 20),
 
          // ── Campo de confirmación ──
          Text(
            'Escribe BORRAR para confirmar',
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller:  _confirmController,
            autofocus:   false,
            enabled:     !_isDeleting,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText:    'BORRAR',
              hintStyle:   TextStyle(
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide(
                  color: cs.error.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide(
                  color: cs.error.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide(color: cs.error),
              ),
            ),
          ),
 
          const SizedBox(height: 16),
 
          // ── Botón eliminar ──
          FilledButton(
            onPressed: (_confirmEnabled && !_isDeleting) ? _deleteAll : null,
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              disabledBackgroundColor:
                  cs.error.withValues(alpha: 0.3),
            ),
            child: _isDeleting
                ? const SizedBox(
                    width:  18,
                    height: 18,
                    child:  CircularProgressIndicator(
                      strokeWidth: 2,
                      color:       Colors.white,
                    ),
                  )
                : const Text(
                    'Eliminar todos los datos',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
 
          const SizedBox(height: 8),
 
          // ── Botón cancelar ──
          OutlinedButton(
            onPressed: _isDeleting
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}