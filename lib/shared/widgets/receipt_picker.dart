import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiptPicker extends StatefulWidget {
  final String?              initialPath;
  final ValueChanged<String?> onChanged;

  const ReceiptPicker({
    super.key,
    this.initialPath,
    required this.onChanged,
  });

  @override
  State<ReceiptPicker> createState() => _ReceiptPickerState();
}

class _ReceiptPickerState extends State<ReceiptPicker>
    with SingleTickerProviderStateMixin {
  String? _currentPath;
  bool    _isLoading = false;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;
    _animCtrl = AnimationController(
      vsync:    this,
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

  // ════════════════════════════════════════════════════════
  //  Solicitar permiso antes de abrir galería o cámara
  // ════════════════════════════════════════════════════════
  Future<bool> _requestPermission(ImageSource source) async {
    // En iOS siempre pedimos photos + camera según la fuente.
    // En Android el permiso depende de la versión del SO:
    //   ≥ Android 13 (API 33) → READ_MEDIA_IMAGES / CAMERA
    //   <  Android 13          → READ_EXTERNAL_STORAGE / CAMERA
    // permission_handler detecta la versión automáticamente.
    final Permission permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;         // cubre galería en iOS y Android

    final status = await permission.request();

    if (status.isGranted) return true;

    // Permiso denegado permanentemente → el usuario debe ir
    // a Ajustes del sistema para habilitarlo manualmente
    if (status.isPermanentlyDenied && mounted) {
      _showSettingsDialog(source);
    }

    return false;
  }

  // ── Diálogo cuando el permiso fue denegado permanentemente ──
  void _showSettingsDialog(ImageSource source) {
    final resource = source == ImageSource.camera ? 'cámara' : 'galería';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Permiso de $resource'),
        content: Text(
          'Kaku necesita acceso a tu $resource para adjuntar recibos. '
          'Habilítalo en los Ajustes del dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            // openAppSettings abre la pantalla de permisos de la app
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir Ajustes'),
          ),
        ],
      ),
    );
  }

  // ── Flujo completo: pedir permiso → abrir picker ─────────
  Future<void> _pick(ImageSource source) async {
    // 1. Pedir permiso — si no lo otorga, detenemos
    final granted = await _requestPermission(source);
    if (!granted) return;

    // 2. Abrir galería o cámara
    setState(() => _isLoading = true);

    try {
      final file = await _picker.pickImage(
        source:       source,
        imageQuality: 80,
        maxWidth:     1200,
      );

      if (file == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _currentPath = file.path;
        _isLoading   = false;
      });

      _animCtrl.forward();
      widget.onChanged(file.path);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo abrir la '
              '${source == ImageSource.camera ? 'cámara' : 'galería'}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _remove() {
    _animCtrl.reverse().then((_) {
      setState(() => _currentPath = null);
      widget.onChanged(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve:  Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _currentPath != null
          ? _PreviewCard(
              key:      const ValueKey('preview'),
              path:     _currentPath!,
              fadeAnim: _fadeAnim,
              onRemove: _remove,
            )
          : _PickerButtons(
              key:       const ValueKey('buttons'),
              isLoading: _isLoading,
              onGallery: () => _pick(ImageSource.gallery),
              onCamera:  () => _pick(ImageSource.camera),
            ),
    );
  }
}

// ── Botones de selección ─────────────────────────────────────
class _PickerButtons extends StatelessWidget {
  final bool         isLoading;
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: isLoading
          ? const SizedBox(
              height: 52,
              child: Center(
                child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    icon:   Icons.photo_library_outlined,
                    label:  'Galería',
                    onTap:  onGallery,
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
                    icon:   Icons.camera_alt_outlined,
                    label:  'Cámara',
                    onTap:  onCamera,
                    isLeft: false,
                  ),
                ),
              ],
            ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         isLeft;

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
        left:  isLeft  ? const Radius.circular(12) : Radius.zero,
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
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Preview de la foto ───────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  final String            path;
  final Animation<double> fadeAnim;
  final VoidCallback      onRemove;

  const _PreviewCard({
    super.key,
    required this.path,
    required this.fadeAnim,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final file = File(path);

    return FadeTransition(
      opacity: fadeAnim,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SizedBox(
              width:  double.infinity,
              height: 160,
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _BrokenImage(cs: cs))
                  : _BrokenImage(cs: cs),
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topCenter,
                    end:    Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12, bottom: 10,
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  const Text(
                    'Recibo adjunto',
                    style: TextStyle(
                      fontSize: 11, color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 16),
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
      child: Icon(Icons.broken_image_outlined,
          color: cs.onSurfaceVariant.withValues(alpha: 0.4), size: 32),
    ),
  );
}