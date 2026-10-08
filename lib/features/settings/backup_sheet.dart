import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    final ok = await BackupService.authenticate();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _statusMessage = ok
          ? l10n.backupConnectedAs(BackupService.currentUser?.email ?? '')
          : l10n.backupConnectFailed;
      _isError = !ok;
    });
  }

  Future<void> _signOut() async {
    await BackupService.signOut();
    if (mounted) setState(() => _statusMessage = null);
  }

  Future<void> _backup() async {
    final l10n = AppLocalizations.of(context)!;
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
          _statusMessage = l10n.backupCompleted;
          _isError = false;
        case BackupResult.notSignedIn:
          _statusMessage = l10n.backupSignInFirst;
          _isError = true;
        case BackupResult.dbNotFound:
          _statusMessage = l10n.backupDbNotFound;
          _isError = true;
        case BackupResult.error:
          _statusMessage = l10n.backupErrorGeneric;
          _isError = true;
      }
    });
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;

    // Doble confirmación — restaurar sobreescribe todos los datos actuales
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.restoreDialogTitle),
        content: Text(l10n.restoreDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.restoreDialogCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.restoreDialogConfirm),
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
          final counter = ref.read(appRefreshCounterProvider.notifier);
          counter.state++;
          ref.invalidate(databaseProvider);
          _statusMessage = l10n.restoreSuccess;
          _isError = false;
        case RestoreResult.noBackupFound:
          _statusMessage = l10n.restoreNoBackupFound;
          _isError = true;
        case RestoreResult.notSignedIn:
          _statusMessage = l10n.backupSignInFirst;
          _isError = true;
        case RestoreResult.error:
          _statusMessage = l10n.restoreErrorGeneric;
          _isError = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.backupIncludesTitle,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _backupItem('🗄️', l10n.backupIncludesDatabase),
                _backupItem('🖼️', l10n.backupIncludesReceipts),
                _backupItem('🔒', l10n.backupIncludesEncryption),
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
                    child: Text(
                      l10n.backupSignOut,
                      style: TextStyle(fontSize: 11),
                    ),
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
              label: Text(l10n.backupConnectGoogle),
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
            label: Text(_loading ? l10n.backupUploading : l10n.backupDoNow),
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
              _restoring ? l10n.backupRestoring : l10n.backupRestoreFromDrive,
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
