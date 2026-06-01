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
  bool    _loading       = false;
  String? _statusMessage;
  bool    _isError       = false;
 
  // ✅ Usa la propiedad estática del servicio
  bool get _isSignedIn => BackupService.isSignedIn;
  String? get _userEmail => BackupService.currentUser?.email;
 
  Future<void> _authenticate() async {
    setState(() { _loading = true; _statusMessage = null; });
    final ok = await BackupService.authenticate();
    if (!mounted) return;
    setState(() {
      _loading       = false;
      _statusMessage = ok
          ? '✅ Conectado como ${BackupService.currentUser?.email}'
          : 'No se pudo conectar con Google';
      _isError = !ok;
    });
  }
 
  Future<void> _signOut() async {
    await BackupService.signOut();
    if (mounted) setState(() { _statusMessage = null; });
  }
 
  Future<void> _backup() async {
    setState(() { _loading = true; _statusMessage = null; });
    final db     = ref.read(databaseProvider);
    final result = await BackupService.backup(db);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case BackupResult.success:
          _statusMessage = '✅ Backup completado correctamente';
          _isError       = false;
          ref.read(backupRefreshSignalProvider.notifier).state++;
        case BackupResult.notSignedIn:
          _statusMessage = 'Inicia sesión con Google primero';
          _isError       = true;
        case BackupResult.dbNotFound:
          _statusMessage = 'No se encontró la base de datos';
          _isError       = true;
        case BackupResult.error:
          _statusMessage = 'Error al realizar el backup. Intenta de nuevo.';
          _isError       = true;
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
          const SizedBox(height: 12),
          Text(
            'Tu base de datos se sube a una carpeta privada '
            '"Kaku Backup" en tu Google Drive.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
 
          // Estado actual de la cuenta
          if (_isSignedIn)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Conectado como $_userEmail',
                      style: TextStyle(fontSize: 12, color: cs.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _signOut,
                    child: const Text('Salir', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
 
          // Mensaje de estado
          if (_statusMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isError ? cs.error : cs.primary)
                    .withValues(alpha: 0.1),
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
          ],
 
          const SizedBox(height: 16),
 
          // Botón conectar (si no está autenticado)
          if (!_isSignedIn)
            OutlinedButton.icon(
              onPressed: _loading ? null : _authenticate,
              icon:  const Text('🔑', style: TextStyle(fontSize: 16)),
              label: const Text('Conectar con Google'),
            ),
 
          const SizedBox(height: 8),
 
          // Botón backup
          FilledButton.icon(
            onPressed: (_loading || !_isSignedIn) ? null : _backup,
            icon: _loading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_upload_outlined, size: 18),
            label: Text(_loading ? 'Subiendo...' : 'Hacer backup ahora'),
          ),
        ],
      ),
    );
  }
}