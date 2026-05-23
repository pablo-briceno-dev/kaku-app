import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceiptViewer extends StatefulWidget {
  final String filePath;

  const ReceiptViewer({super.key, required this.filePath});

  // ════════════════════════════════════════════════════════
  //  Abre el viewer desde cualquier widget con una línea.
  //
  //  Uso:
  //    ReceiptViewer.open(context, filePath: tx.receiptPath!);
  // ════════════════════════════════════════════════════════
  static Future<void> open(
    BuildContext context, {
    required String filePath,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque:       false,
        barrierColor: Colors.black,
        pageBuilder:  (_, __, ___) => ReceiptViewer(filePath: filePath),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child:   child,
        ),
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
  bool  _isZoomed = false;

  // Animación para el reset de zoom (vuelve suave a escala 1)
  late AnimationController _resetAnimController;
  Animation<Matrix4>?      _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetAnimController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_resetAnimation != null) {
          _transformController.value = _resetAnimation!.value;
        }
      });

    // Escucha cambios en el zoom para mostrar/ocultar el botón reset
    _transformController.addListener(_onTransformChanged);

    // Pantalla completa — oculta la barra de estado del sistema
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _resetAnimController.dispose();
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    // Restaura la barra de estado al salir
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onTransformChanged() {
    // La escala está en la posición [0][0] de la matriz 4x4
    final scale   = _transformController.value.getMaxScaleOnAxis();
    final zoomed  = scale > 1.05;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  // Anima el zoom de vuelta a la escala 1 (imagen completa)
  void _resetZoom() {
    _resetAnimation = Matrix4Tween(
      begin: _transformController.value,
      end:   Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _resetAnimController,
      curve:  Curves.easeOutCubic,
    ));
    _resetAnimController
      ..reset()
      ..forward();
  }

  // Doble tap: zoom al punto tocado o reset si ya hay zoom
  void _onDoubleTapDown(TapDownDetails details) {
    if (_isZoomed) {
      _resetZoom();
      return;
    }

    // Zoom 2.5x centrado en el punto donde tocó el usuario
    final position = details.localPosition;
    final x        = -position.dx * 1.5;  // offset para centrar
    final y        = -position.dy * 1.5;

    final zoomed = Matrix4.identity()
      ..translate(x, y)
      ..scale(2.5);

    _resetAnimation = Matrix4Tween(
      begin: _transformController.value,
      end:   zoomed,
    ).animate(CurvedAnimation(
      parent: _resetAnimController,
      curve:  Curves.easeOutCubic,
    ));
    _resetAnimController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.filePath);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── Imagen con zoom y pan ──────────────────────
          GestureDetector(
            onDoubleTapDown: _onDoubleTapDown,
            onDoubleTap:     () {}, // necesario para que onDoubleTapDown dispare
            child: InteractiveViewer(
              transformationController: _transformController,
              // Zoom mínimo: imagen completa en pantalla
              minScale: 0.8,
              // Zoom máximo: 5x
              maxScale: 5.0,
              // Permite hacer pan más allá de los bordes de la imagen
              boundaryMargin: const EdgeInsets.all(80),
              child: Center(
                child: file.existsSync()
                    ? Image.file(
                        file,
                        fit:          BoxFit.contain,
                        errorBuilder: (_, __, ___) => _ErrorWidget(),
                      )
                    : _ErrorWidget(),
              ),
            ),
          ),

          // ── Botón cerrar ──────────────────────────────
          Positioned(
            top:  48,
            left: 16,
            child: _CircleButton(
              icon:    Icons.close_rounded,
              onTap:   () => Navigator.of(context).pop(),
              tooltip: 'Cerrar',
            ),
          ),

          // ── Botón resetear zoom ───────────────────────
          // Aparece con animación solo cuando hay zoom activo
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve:    Curves.easeOut,
            top:   48,
            right: _isZoomed ? 16 : -56,
            child: _CircleButton(
              icon:    Icons.zoom_out_map_rounded,
              onTap:   _resetZoom,
              tooltip: 'Restablecer zoom',
            ),
          ),

          // ── Indicador de gestos (primera vez) ─────────
          Positioned(
            bottom: 40,
            left:   0,
            right:  0,
            child:  _BottomLabel(filePath: widget.filePath),
          ),
        ],
      ),
    );
  }
}

// ── Botón circular ───────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final String       tooltip;

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
          width:  42,
          height: 42,
          decoration: BoxDecoration(
            color:  Colors.black.withValues(alpha: 0.55),
            shape:  BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ── Label inferior ───────────────────────────────────────────
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
          color:        Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white60,
              size:  14,
            ),
            const SizedBox(width: 6),
            Text(
              'Recibo · $fileName',
              style: const TextStyle(
                color:    Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.pinch_rounded,
              color: Colors.white38,
              size:  14,
            ),
            const SizedBox(width: 4),
            const Text(
              'Pellizca para hacer zoom',
              style: TextStyle(
                color:    Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error cuando el archivo no existe ────────────────────────
class _ErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.broken_image_outlined,
          color: Colors.white38,
          size:  56,
        ),
        const SizedBox(height: 12),
        Text(
          'No se pudo cargar el recibo',
          style: TextStyle(
            color:    Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}