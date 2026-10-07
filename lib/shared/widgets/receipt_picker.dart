import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaku/core/errors/app_error.dart';
import 'package:kaku/core/helpers/error_localizer.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kaku/core/receipt_storage.dart';

class ReceiptPicker extends StatefulWidget {
  final String? initialPath;
  final ValueChanged<String?> onChanged;

  const ReceiptPicker({super.key, this.initialPath, required this.onChanged});

  @override
  State<ReceiptPicker> createState() => _ReceiptPickerState();
}

class _ReceiptPickerState extends State<ReceiptPicker>
    with SingleTickerProviderStateMixin {
  String? _currentPath;
  bool _isLoading = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    if (_currentPath != null) _animCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission(
    AppLocalizations l10n,
    ImageSource source,
  ) async {
    if (source == ImageSource.gallery) return true;

    final status = await Permission.camera.request();
    if (!mounted || !context.mounted) return false; // ← agregar esto también
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) _showSettingsDialog(l10n, source);
    return false;
  }

  void _showSettingsDialog(AppLocalizations l10n, ImageSource source) {
    final resource = source == ImageSource.camera ? l10n.camera : l10n.galery;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.permissionTitle(source: resource)),
        content: Text(l10n.permissionDesc(source: resource)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.btnOpenSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(AppLocalizations l10n, ImageSource source) async {
    final granted = await _requestPermission(l10n, source);
    if (!mounted || !granted) return;

    setState(() => _isLoading = true);

    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (!mounted) return;

      if (file == null) {
        setState(() => _isLoading = false);
        return;
      }

      final savedPath = await ReceiptStorage.save(file.path);

      if (!mounted) return;

      setState(() {
        _currentPath = savedPath;
        _isLoading = false;
      });

      _animCtrl.forward();
      widget.onChanged(savedPath);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizeError(
              context,
              e.code,
              messageComplement: source == ImageSource.camera
                  ? l10n.camera.toLowerCase()
                  : l10n.galery.toLowerCase(),
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _remove() {
    final pathToDelete = _currentPath;
    _animCtrl.reverse().then((_) {
      setState(() => _currentPath = null);
      widget.onChanged(null);

      // Elimina el archivo del disco en segundo plano.
      // No esperamos el Future porque no afecta la UI.
      if (pathToDelete != null) {
        ReceiptStorage.delete(pathToDelete);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _currentPath != null
          ? _PreviewCard(
              key: const ValueKey('preview'),
              path: _currentPath!,
              fadeAnim: _fadeAnim,
              onRemove: _remove,
            )
          : _PickerButtons(
              key: const ValueKey('buttons'),
              isLoading: _isLoading,
              onGallery: () => _pick(l10n, ImageSource.gallery),
              onCamera: () => _pick(l10n, ImageSource.camera),
            ),
    );
  }
}

// ── El resto de widgets (_PickerButtons, _PreviewCard, etc.)
//    son idénticos a la versión anterior — no cambian ──────────

class _PickerButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _PickerButtons({
    super.key,
    required this.isLoading,
    required this.onGallery,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: isLoading
          ? const SizedBox(
              height: 52,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    icon: Icons.photo_library_outlined,
                    label: l10n.galery,
                    onTap: onGallery,
                    isLeft: true,
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: VerticalDivider(
                    width: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                Expanded(
                  child: _PickerButton(
                    icon: Icons.camera_alt_outlined,
                    label: l10n.camera,
                    onTap: onCamera,
                    isLeft: false,
                  ),
                ),
              ],
            ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLeft;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.horizontal(
        left: isLeft ? const Radius.circular(12) : Radius.zero,
        right: !isLeft ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String path;
  final Animation<double> fadeAnim;
  final VoidCallback onRemove;

  const _PreviewCard({
    super.key,
    required this.path,
    required this.fadeAnim,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final file = File(path);
    final l10n = AppLocalizations.of(context)!;

    return FadeTransition(
      opacity: fadeAnim,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 160,
              child: file.existsSync()
                  ? Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _BrokenImage(cs: cs),
                    )
                  : _BrokenImage(cs: cs),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 10,
              child: Row(
                children: const [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 12,
                    color: Colors.white70,
                  ),
                  SizedBox(width: 4),
                  Text(
                    l10n.attachedReceipt,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  final ColorScheme cs;
  const _BrokenImage({required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    color: cs.surfaceContainerHighest,
    child: Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
        size: 32,
      ),
    ),
  );
}
