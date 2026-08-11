import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/services/local_backup_service.dart';

class LocalBackupSheet extends ConsumerStatefulWidget {
  const LocalBackupSheet({super.key});

  @override
  ConsumerState<LocalBackupSheet> createState() => _LocalBackupSheetState();
}

class _LocalBackupSheetState extends ConsumerState<LocalBackupSheet> {
  bool _creatingBackup = false;
  bool _restoringBackup = false;
  String? _statusMessage;
  bool _isError = false;

  // Clave para cifrar/descifrar — usamos un identificador fijo
  // del dispositivo o un valor guardado en SharedPreferences.
  // Para simplicidad usamos un string fijo por ahora;
  // en producción puedes usar el device_info_plus package
  // para obtener un ID único del dispositivo.
  static const _backupKey = 'kaku_local_backup_key_v1';

  Future<void> _createBackup() async {
    setState(() {
      _creatingBackup = true;
      _statusMessage = null;
    });

    final result = await LocalBackupService.createBackup(
      userKey: _backupKey,
      share: true, // abre Share sheet para que el usuario elija destino
    );

    if (!mounted) return;

    setState(() {
      _creatingBackup = false;
      switch (result) {
        case LocalBackupResult.success:
          _statusMessage = '✅ Backup generado correctamente';
          _isError = false;
        case LocalBackupResult.dbNotFound:
          _statusMessage = 'No se encontró la base de datos';
          _isError = true;
        case LocalBackupResult.permissionDenied:
          _statusMessage = 'Sin permiso para acceder al almacenamiento';
          _isError = true;
        case LocalBackupResult.error:
          _statusMessage = 'Error al crear el backup. Intenta de nuevo.';
          _isError = true;
      }
    });
  }

  Future<void> _restoreBackup() async {
    // Primero pide confirmación
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

    // Abre el file picker para que el usuario seleccione el archivo
    final picked = await FilePicker.pickFiles(
      type: FileType.any,
      dialogTitle: 'Selecciona el archivo de backup de Kaku',
      withData: false,
      withReadStream: false,
    );

    if (picked == null || picked.files.isEmpty) return;

    final filePath = picked.files.first.path;
    if (filePath == null) return;

    setState(() {
      _restoringBackup = true;
      _statusMessage = null;
    });

    final result = await LocalBackupService.restoreBackup(
      filePath: filePath,
      userKey: _backupKey,
    );

    if (!mounted) return;

    setState(() {
      _restoringBackup = false;
      switch (result) {
        case LocalRestoreResult.success:
          final counter = ref.read(appRefreshCounterProvider.notifier);
          counter.state++;

          // 2. (Opcional) Invalidar explícitamente el databaseProvider para asegurar recreación
          ref.invalidate(databaseProvider);
          _statusMessage = '✅ Datos restaurados correctamente';
          _isError = false;
        case LocalRestoreResult.fileNotFound:
          _statusMessage = 'No se encontró el archivo de backup';
          _isError = true;
        case LocalRestoreResult.wrongKey:
          _statusMessage =
              'El archivo no es un backup válido de Kaku o está dañado';
          _isError = true;
        case LocalRestoreResult.error:
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
          const Center(child: Text('💾', style: TextStyle(fontSize: 44))),
          const SizedBox(height: 12),

          // ── Qué incluye el backup ──────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El backup incluye:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _item('🗄️', 'Base de datos (transacciones, cuentas, metas)'),
                _item('🖼️', 'Fotos de recibos'),
                _item('🔒', 'Cifrado AES-256 — solo Kaku puede leerlo'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nota informativa
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El archivo se guarda en tu dispositivo. '
                    'Puedes moverlo a Google Drive, WhatsApp o '
                    'donde prefieras usando el botón Compartir.',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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

          // ── Botón crear backup ─────────────────────────
          FilledButton.icon(
            onPressed: (_creatingBackup || _restoringBackup)
                ? null
                : _createBackup,
            icon: _creatingBackup
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share_outlined, size: 18),
            label: Text(
              _creatingBackup
                  ? 'Creando backup...'
                  : 'Crear y compartir backup',
            ),
          ),

          const SizedBox(height: 8),

          // ── Botón restaurar ────────────────────────────
          OutlinedButton.icon(
            onPressed: (_creatingBackup || _restoringBackup)
                ? null
                : _restoreBackup,
            icon: _restoringBackup
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : const Icon(Icons.restore_outlined, size: 18),
            label: Text(
              _restoringBackup ? 'Restaurando...' : 'Restaurar desde archivo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(String emoji, String text) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}
