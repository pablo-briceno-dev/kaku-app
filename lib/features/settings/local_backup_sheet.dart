import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  static const _kPasswordPrefix = 'kaku_local_backup_key';

  @override
  void initState() {
    super.initState();
    _passwordController.text =
        ref.read(sharedPrefsProvider).getString(_kPasswordPrefix) ?? '';
  }

  Future<void> _createBackup() async {
    setState(() {
      _creatingBackup = true;
      _statusMessage = null;
    });

    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.passwordNotEmpty;
        _isError = true;
        _creatingBackup = false;
      });
      return;
    }

    ref.read(sharedPrefsProvider).setString(_kPasswordPrefix, password);

    final result = await LocalBackupService.createBackup(
      context,
      userKey: password,
      share: true, // abre Share sheet para que el usuario elija destino
    );

    if (!mounted) return;

    setState(() {
      _creatingBackup = false;
      switch (result) {
        case LocalBackupResult.success:
          _statusMessage = AppLocalizations.of(context)!.backupGenerateSuccess;
          _isError = false;
        case LocalBackupResult.dbNotFound:
          _statusMessage = AppLocalizations.of(context)!.backupDbNotFound;
          _isError = true;
        case LocalBackupResult.permissionDenied:
          _statusMessage = AppLocalizations.of(context)!.backupPermissionDenied;
          _isError = true;
        case LocalBackupResult.error:
          _statusMessage = AppLocalizations.of(context)!.backupErrorGeneric;
          _isError = true;
      }
    });
  }

  Future<void> _restoreBackup() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.passwordNotEmpty;
        _isError = true;
        _creatingBackup = false;
      });
      return;
    }

    // Primero pide confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.restoreDialogTitle),
        content: Text(AppLocalizations.of(context)!.restoreDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.restoreDialogConfirm),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    ref.read(sharedPrefsProvider).setString(_kPasswordPrefix, password);

    if (!mounted) return;

    // Abre el file picker para que el usuario seleccione el archivo
    final picked = await FilePicker.pickFiles(
      type: FileType.any,
      dialogTitle: AppLocalizations.of(context)!.selectedFileBackup,
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
      userKey: password,
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
          _statusMessage = AppLocalizations.of(context)!.restoreSuccess;
          _isError = false;
        case LocalRestoreResult.fileNotFound:
          _statusMessage = AppLocalizations.of(context)!.backupFileNotFound;
          _isError = true;
        case LocalRestoreResult.wrongKey:
          _statusMessage = AppLocalizations.of(context)!.backupFileNotValid;
          _isError = true;
        case LocalRestoreResult.error:
          _statusMessage = AppLocalizations.of(context)!.restoreErrorGeneric;
          _isError = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.backupIncludesTitle,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _item('🗄️', l10n.backupIncludesDatabase),
                _item('🖼️', l10n.backupIncludesReceipts),
                _item('🔒', l10n.backupIncludesEncryptionLocal),
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
                    l10n.backupMessageShare,
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
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            // obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: l10n.formPassword,
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
                  ? l10n.backupBtnCreating
                  : l10n.backupBtnCreateShare,
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
              _restoringBackup
                  ? l10n.backupBtnRestoring
                  : l10n.backupBtnRestore,
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
