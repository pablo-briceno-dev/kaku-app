import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceiptViewer extends StatefulWidget {
  final String filePath;

  const ReceiptViewer({super.key, required this.filePath});

  // ════════════════════════════════════════════════════════
  //  Usa useRootNavigator: true para salir del ShellRoute
  //  y ocupar toda la pantalla sin el bottom nav encima.
  // ════════════════════════════════════════════════════════
  static Future<void> open(BuildContext context, {required String filePath}) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => ReceiptViewer(filePath: filePath),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  State<ReceiptViewer> createState() => _ReceiptViewerState();
}

class _ReceiptViewerState extends State<ReceiptViewer>
    with SingleTickerProviderStateMixin {
  final _transformController = TransformationController();
  bool _isZoomed = false;

  late AnimationController _resetAnimController;
  Animation<Matrix4>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetAnimController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          if (_resetAnimation != null) {
            _transformController.value = _resetAnimation!.value;
          }
        });

    _transformController.addListener(_onTransformChanged);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _resetAnimController.dispose();
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.05;
    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
  }

  void _resetZoom() {
    _resetAnimation =
        Matrix4Tween(
          begin: _transformController.value,
          end: Matrix4.identity(),
        ).animate(
          CurvedAnimation(
            parent: _resetAnimController,
            curve: Curves.easeOutCubic,
          ),
        );
    _resetAnimController
      ..reset()
      ..forward();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    if (_isZoomed) {
      _resetZoom();
      return;
    }

    // ✅ Reemplaza translate() + scale() deprecados.
    // Construimos la matriz manualmente:
    //   1. Escalar 2.5x desde el origen
    //   2. Trasladar para centrar en el punto tocado
    final position = details.localPosition;
    const scaleValue = 2.5;
    final dx = -position.dx * (scaleValue - 1);
    final dy = -position.dy * (scaleValue - 1);

    // Matrix4.identity() + setEntry para escala + traducción manual
    final zoomed = Matrix4.identity()
      ..setEntry(0, 0, scaleValue) // escala X
      ..setEntry(1, 1, scaleValue) // escala Y
      ..setEntry(0, 3, dx) // traslación X
      ..setEntry(1, 3, dy); // traslación Y

    _resetAnimation =
        Matrix4Tween(begin: _transformController.value, end: zoomed).animate(
          CurvedAnimation(
            parent: _resetAnimController,
            curve: Curves.easeOutCubic,
          ),
        );
    _resetAnimController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.filePath);

    // ✅ Wrap con PopScope para restaurar la UI del sistema
    // si el usuario usa el gesto de "atrás" del sistema.
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      // ✅ Material sin Scaffold para que no herede el tema
      // del AppShell (que tiene bottom nav, appbar, etc.)
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Imagen con zoom y pan ──
            GestureDetector(
              onDoubleTapDown: _onDoubleTapDown,
              onDoubleTap: () {},
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.5,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(80),
                child: Center(
                  child: file.existsSync()
                      ? Image.file(
                          file,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const _ErrorWidget(),
                        )
                      : const _ErrorWidget(),
                ),
              ),
            ),

            // ── Botón cerrar ──
            Positioned(
              top: 48,
              left: 16,
              child: _CircleButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                tooltip: 'Cerrar',
              ),
            ),

            // ── Botón resetear zoom ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: 48,
              right: _isZoomed ? 16 : -56,
              child: _CircleButton(
                icon: Icons.zoom_out_map_rounded,
                onTap: _resetZoom,
                tooltip: 'Restablecer zoom',
              ),
            ),

            // ── Label inferior ──
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _BottomLabel(filePath: widget.filePath),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _BottomLabel extends StatelessWidget {
  final String filePath;
  const _BottomLabel({required this.filePath});

  @override
  Widget build(BuildContext context) {
    final fileName = filePath.split('/').last;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white60,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Recibo · $fileName',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.pinch_rounded, color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            const Text(
              'Pellizca para hacer zoom',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.broken_image_outlined,
          color: Colors.white38,
          size: 56,
        ),
        const SizedBox(height: 12),
        Text(
          'No se pudo cargar el recibo',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
