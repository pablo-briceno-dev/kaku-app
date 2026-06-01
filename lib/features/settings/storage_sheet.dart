import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/storage_service.dart';

class StorageSheet extends ConsumerStatefulWidget {
  const StorageSheet({super.key});
 
  @override
  ConsumerState<StorageSheet> createState() => _StorageSheetState();
}
 
class _StorageSheetState extends ConsumerState<StorageSheet> {
  StorageInfo? _info;
  bool         _loading  = false;
  bool         _clearing = false;
 
  @override
  void initState() {
    super.initState();
    _loadInfo();
  }
 
  Future<void> _loadInfo() async {
    setState(() => _loading = true);
    final info = await StorageService.getInfo();
    if (mounted) setState(() { _info = info; _loading = false; });
  }
 
  Future<void> _clearReceipts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Limpiar recibos'),
        content: Text(
          'Se eliminarán ${_info?.count ?? 0} fotos de recibos '
          '(${_info?.sizeLabel ?? '0 MB'}) del dispositivo.\n\n'
          'Las transacciones se conservan pero ya no tendrán foto adjunta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
 
    if (confirm != true) return;
 
    setState(() => _clearing = true);
    ref.read(storageRefreshSignalProvider.notifier).state++;
    await StorageService.clearReceipts(ref.read(databaseProvider));
    await _loadInfo(); // refresca el contador
    if (mounted) setState(() => _clearing = false);
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
 
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
 
          // Info de espacio
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_info != null) ...[
            // Tarjeta de uso
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('🖼️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fotos de recibos',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${_info!.count} ${_info!.count == 1 ? 'foto' : 'fotos'} · ${_info!.sizeLabel}',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
 
            // Nota informativa
            Text(
              'Las fotos se guardan en el almacenamiento privado '
              'de la app y nunca salen de tu dispositivo.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
 
            // Botón limpiar (deshabilitado si no hay recibos)
            OutlinedButton.icon(
              onPressed: (_info!.count == 0 || _clearing)
                  ? null
                  : _clearReceipts,
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(
                    color: cs.error.withValues(alpha: 0.4)),
              ),
              icon: _clearing
                  ? SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: cs.error))
                  : const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(_clearing
                  ? 'Limpiando...'
                  : _info!.count == 0
                      ? 'Sin recibos que limpiar'
                      : 'Limpiar ${_info!.count} recibos (${_info!.sizeLabel})'),
            ),
          ],
        ],
      ),
    );
  }
}