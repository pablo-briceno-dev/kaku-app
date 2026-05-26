// Animación de confeti para cuando se completa una meta.
// Usa el paquete confetti:
//   confetti: ^0.7.0
//
// Dos formas de usarlo:
//   1. GoalConfettiOverlay  — lo pones en el árbol de widgets
//      y le pasas el controller para controlarlo desde afuera.
//   2. GoalConfettiOverlay.show() — helper estático que lo
//      inserta sobre toda la pantalla usando an OverlayEntry,
//      sin tocar el árbol de widgets existente.

import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  Controller reutilizable — créalo en el State que
//  muestra la pantalla de metas y pásalo al widget.
//
//  Ciclo de vida:
//    1. Crea: final _confetti = GoalConfettiController();
//    2. Dispara: _confetti.play();
//    3. Libera: en dispose() → _confetti.dispose();
// ════════════════════════════════════════════════════════
class GoalConfettiController {
  late final ConfettiController _ctrl;

  GoalConfettiController() {
    _ctrl = ConfettiController(duration: const Duration(seconds: 3));
  }

  void play() => _ctrl.play();
  void stop() => _ctrl.stop();
  void dispose() => _ctrl.dispose();

  ConfettiController get raw => _ctrl;
}

// ════════════════════════════════════════════════════════
//  GoalConfettiOverlay — widget que renderiza el confeti.
//
//  Colócalo encima del contenido con un Stack:
//
//    Stack(
//      children: [
//        TuPantallaDeContenido(),
//        GoalConfettiOverlay(controller: _confetti),
//      ],
//    )
// ════════════════════════════════════════════════════════
class GoalConfettiOverlay extends StatelessWidget {
  final GoalConfettiController controller;

  // Si true: dispara desde el centro arriba.
  // Si false: dispara desde las dos esquinas superiores
  //           (más espectacular para pantalla completa).
  final bool centered;

  const GoalConfettiOverlay({
    super.key,
    required this.controller,
    this.centered = false,
  });

  // ── Helper estático ───────────────────────────────────
  // Muestra el confeti sobre TODA la pantalla sin modificar
  // el árbol de widgets. Se limpia solo cuando termina.
  //
  // Uso desde GoalContributeBottomSheet al confirmar:
  //   GoalConfettiOverlay.show(context);
  static void show(BuildContext context) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final ctrl = GoalConfettiController();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FullScreenConfetti(
        controller: ctrl,
        onDone: () {
          entry.remove();
          ctrl.dispose();
        },
      ),
    );

    overlay.insert(entry);
    ctrl.play();
  }

  @override
  Widget build(BuildContext context) {
    if (centered) {
      return _CenteredConfetti(controller: controller.raw);
    }
    return _CornerConfetti(controller: controller.raw);
  }
}

// ════════════════════════════════════════════════════════
//  _FullScreenConfetti — para el helper estático .show()
//  Dispara desde las dos esquinas + centro arriba.
//  Se elimina del Overlay cuando la animación termina.
// ════════════════════════════════════════════════════════
class _FullScreenConfetti extends StatefulWidget {
  final GoalConfettiController controller;
  final VoidCallback onDone;

  const _FullScreenConfetti({required this.controller, required this.onDone});

  @override
  State<_FullScreenConfetti> createState() => _FullScreenConfettiState();
}

class _FullScreenConfettiState extends State<_FullScreenConfetti> {
  @override
  void initState() {
    super.initState();
    // Cuando el controller termina de emitir partículas,
    // esperamos un poco más para que caigan y limpiamos.
    widget.controller.raw.addListener(() {
      if (widget.controller.raw.state == ConfettiControllerState.stopped) {
        Future.delayed(const Duration(milliseconds: 1500), widget.onDone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // IgnorePointer para que los taps pasen al contenido de abajo
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Esquina superior izquierda
            Positioned(
              top: 0,
              left: 0,
              child: _ConfettiEmitter(
                controller: widget.controller.raw,
                blastDirection: pi * 0.75, // abajo-derecha diagonal
                origin: const Offset(0.0, 0.0),
              ),
            ),
            // Esquina superior derecha
            Positioned(
              top: 0,
              right: 0,
              child: _ConfettiEmitter(
                controller: widget.controller.raw,
                blastDirection: pi * 0.35, // abajo-izquierda diagonal
                origin: const Offset(1.0, 0.0),
              ),
            ),
            // Centro arriba
            Positioned(
              top: 0,
              left: MediaQuery.of(context).size.width / 2,
              child: _ConfettiEmitter(
                controller: widget.controller.raw,
                blastDirection: pi / 2, // recto hacia abajo
                origin: const Offset(0.5, 0.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _CenteredConfetti — un solo emisor desde el centro
//  Bueno para bottom sheets o tarjetas individuales.
// ════════════════════════════════════════════════════════
class _CenteredConfetti extends StatelessWidget {
  final ConfettiController controller;
  const _CenteredConfetti({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: _ConfettiEmitter(
        controller: controller,
        blastDirection: pi / 2,
        origin: const Offset(0.5, 0.0),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _CornerConfetti — dos emisores desde las esquinas
//  Bueno para pantallas completas o listas de metas.
// ════════════════════════════════════════════════════════
class _CornerConfetti extends StatelessWidget {
  final ConfettiController controller;
  const _CornerConfetti({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: _ConfettiEmitter(
            controller: controller,
            blastDirection: pi * 0.75,
            origin: const Offset(0.0, 0.0),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: _ConfettiEmitter(
            controller: controller,
            blastDirection: pi * 0.35,
            origin: const Offset(1.0, 0.0),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ConfettiEmitter — el widget base de confeti.
//  Todos los colores y tamaños se configuran aquí.
// ════════════════════════════════════════════════════════
class _ConfettiEmitter extends StatelessWidget {
  final ConfettiController controller;
  final double blastDirection;
  final Offset origin;

  const _ConfettiEmitter({
    required this.controller,
    required this.blastDirection,
    required this.origin,
  });

  // Colores del confeti — usa los colores de la app
  static const _colors = [
    Color(0xFF7CFFD4), // accent aurora
    Color(0xFF7CB8FF), // blue
    Color(0xFFC87CFF), // violet
    Color(0xFFFFD97C), // yellow
    Color(0xFF6ADF9A), // green
    Color(0xFFFF9F7C), // orange
    Color(0xFFFFFFFF), // white
  ];

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controller,

      // Dirección principal del chorro
      blastDirection: blastDirection,
      // Cuánto se dispersa alrededor de blastDirection (en radianes)
      blastDirectionality: BlastDirectionality.explosive,

      // Física de las partículas
      gravity: 0.25, // qué tan rápido caen
      particleDrag: 0.05, // fricción del aire
      emissionFrequency: 0.04, // partículas por frame
      numberOfParticles: 18, // partículas por emisión
      maxBlastForce: 25,
      minBlastForce: 12,

      // Tamaño de las partículas
      minimumSize: const Size(6, 4),
      maximumSize: const Size(14, 8),

      // Colores
      colors: _colors,

      // Forma de las partículas: mezcla de rectángulos y
      // estrellas para más variedad visual
      createParticlePath: _buildParticle,

      // No repite la animación automáticamente
      shouldLoop: false,

      // Posición de origen del emisor
      canvas: MediaQuery.of(context).size,
    );
  }

  // Alterna entre rectángulo y estrella según el índice
  // para dar más variedad visual al confeti
  Path _buildParticle(Size size) {
    final path = Path();
    // Elige aleatoriamente la forma
    if (Random().nextBool()) {
      // Rectángulo redondeado (más clásico)
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(2),
        ),
      );
    } else {
      // Estrella de 4 puntas (más festivo)
      final cx = size.width / 2;
      final cy = size.height / 2;
      final r1 = size.width / 2;
      final r2 = size.width / 5;
      for (var i = 0; i < 8; i++) {
        final r = i.isEven ? r1 : r2;
        final angle = i * pi / 4;
        final x = cx + r * cos(angle);
        final y = cy + r * sin(angle);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
    }
    return path;
  }
}
