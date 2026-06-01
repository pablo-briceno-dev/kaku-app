import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/backup_service.dart';

class BackupSheet extends ConsumerStatefulWidget {
  const BackupSheet({super.key});

  @override
  ConsumerState<BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends ConsumerState<BackupSheet> {
  bool _loading = false;
  bool _restoring = false;
  String? _statusMessage;
  bool _isError = false;

  bool get _isSignedIn => BackupService.isSignedIn;
  String? get _userEmail => BackupService.currentUser?.email;

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    final ok = await BackupService.authenticate();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _statusMessage = ok
          ? '✅ Conectado como ${BackupService.currentUser?.email}'
          : 'No se pudo conectar con Google';
      _isError = !ok;
    });
  }

  Future<void> _signOut() async {
    await BackupService.signOut();
    if (mounted) setState(() => _statusMessage = null);
  }

  Future<void> _backup() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    final db = ref.read(databaseProvider);
    final result = await BackupService.backup(db);
    if (!mounted) return;

    if (result == BackupResult.success) {
      // Actualiza el subtítulo en Settings
      await saveLastBackupDate();
      ref.read(backupRefreshSignalProvider.notifier).state++;
    }

    setState(() {
      _loading = false;
      switch (result) {
        case BackupResult.success:
          _statusMessage = '✅ Backup completado — DB + recibos cifrados';
          _isError = false;
        case BackupResult.notSignedIn:
          _statusMessage = 'Inicia sesión con Google primero';
          _isError = true;
        case BackupResult.dbNotFound:
          _statusMessage = 'No se encontró la base de datos';
          _isError = true;
        case BackupResult.error:
          _statusMessage = 'Error al realizar el backup. Intenta de nuevo.';
          _isError = true;
      }
    });
  }

  Future<void> _restore() async {
    // Doble confirmación — restaurar sobreescribe todos los datos actuales
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurar backup'),
        content: const Text(
          'Se reemplazarán todos los datos actuales con los del backup.\n\n'
          'Esta acción no se puede deshacer.',
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
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _restoring = true;
      _statusMessage = null;
    });
    final result = await BackupService.restore();
    if (!mounted) return;

    setState(() {
      _restoring = false;
      switch (result) {
        case RestoreResult.success:
          _statusMessage = '✅ Datos restaurados correctamente';
          _isError = false;
        case RestoreResult.noBackupFound:
          _statusMessage = 'No se encontró ningún backup en Drive';
          _isError = true;
        case RestoreResult.notSignedIn:
          _statusMessage = 'Inicia sesión con Google primero';
          _isError = true;
        case RestoreResult.error:
          _statusMessage = 'Error al restaurar. Intenta de nuevo.';
          _isError = true;
      }
    });
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
          const Center(child: Text('☁️', style: TextStyle(fontSize: 40))),
          const SizedBox(height: 8),

          // Qué incluye el backup
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El backup incluye:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _backupItem(
                  '🗄️',
                  'Base de datos (transacciones, cuentas, metas)',
                ),
                _backupItem('🖼️', 'Fotos de recibos'),
                _backupItem('🔒', 'Cifrado AES-256 con tu cuenta de Google'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Estado cuenta conectada
          if (_isSignedIn) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _userEmail ?? '',
                      style: TextStyle(fontSize: 12, color: cs.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: (_loading || _restoring) ? null : _signOut,
                    child: const Text('Salir', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Mensaje de estado
          if (_statusMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isError ? cs.error : cs.primary).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _isError ? cs.error : cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Botón conectar
          if (!_isSignedIn)
            OutlinedButton.icon(
              onPressed: _loading ? null : _authenticate,
              icon: const Text('🔑', style: TextStyle(fontSize: 16)),
              label: const Text('Conectar con Google'),
            ),

          if (!_isSignedIn) const SizedBox(height: 8),

          // Botón backup
          FilledButton.icon(
            onPressed: (_loading || _restoring || !_isSignedIn)
                ? null
                : _backup,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload_outlined, size: 18),
            label: Text(_loading ? 'Subiendo...' : 'Hacer backup ahora'),
          ),

          const SizedBox(height: 8),

          // Botón restaurar
          OutlinedButton.icon(
            onPressed: (_loading || _restoring || !_isSignedIn)
                ? null
                : _restore,
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
            ),
            icon: _restoring
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.error,
                    ),
                  )
                : const Icon(Icons.cloud_download_outlined, size: 18),
            label: Text(
              _restoring ? 'Restaurando...' : 'Restaurar desde Drive',
            ),
          ),
        ],
      ),
    );
  }

  Widget _backupItem(String emoji, String text) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}
