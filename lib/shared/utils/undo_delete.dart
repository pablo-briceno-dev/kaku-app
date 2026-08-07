import 'dart:async';
import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  showUndoDelete — función principal
//
//  [context]    : BuildContext para mostrar el SnackBar
//  [label]      : texto principal del SnackBar
//                 ej: "Transacción eliminada"
//  [onDelete]   : Future que ejecuta el delete real en la DB.
//                 Se llama solo si el usuario NO presiona Deshacer.
//  [onUndo]     : (opcional) callback extra al deshacer.
//                 Útil si necesitas restaurar algo en el estado local.
//  [seconds]    : duración del timer antes del delete (default: 4)
// ════════════════════════════════════════════════════════
Future<void> showUndoDelete({
  required BuildContext context,
  required String label,
  required Future<void> Function() onDelete,
  VoidCallback? onUndo,
  int seconds = 4,
}) async {
  // Timer que ejecutará el delete cuando expire
  Timer? deleteTimer;
  // Flag para saber si el usuario presionó Deshacer
  bool undone = false;

  // Cierra cualquier SnackBar anterior antes de mostrar el nuevo
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // ── Crea el SnackBar ──────────────────────────────────
  final snackBar = SnackBar(
    // Duración total visible del SnackBar
    duration: Duration(seconds: seconds + 10),
    behavior: SnackBarBehavior.floating,
    // Sin padding extra — el contenido lo manejamos nosotros
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

    content: _UndoContent(label: label, seconds: seconds),

    action: SnackBarAction(
      label: 'Deshacer',
      onPressed: () {
        undone = true;
        deleteTimer?.cancel();
        onUndo?.call();
        // Cierra el SnackBar inmediatamente al deshacer
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  // ── Muestra el SnackBar ───────────────────────────────
  final controller = ScaffoldMessenger.of(context).showSnackBar(snackBar);

  // ── Inicia el timer del delete ────────────────────────
  // Se ejecuta después de [seconds] segundos si no se deshizo
  deleteTimer = Timer(Duration(seconds: seconds), () async {
    if (!undone) {
      await onDelete();
      controller.close();
    }
  });
}

// ════════════════════════════════════════════════════════
//  _UndoContent — contenido del SnackBar con barra de progreso
// ════════════════════════════════════════════════════════
class _UndoContent extends StatefulWidget {
  final String label;
  final int seconds;

  const _UndoContent({required this.label, required this.seconds});

  @override
  State<_UndoContent> createState() => _UndoContentState();
}

class _UndoContentState extends State<_UndoContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    // Anima de 1.0 → 0.0 durante [seconds] segundos
    // La barra va vaciándose visualmente como un timer
    _progressCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
      value: 1.0,
    )..animateTo(0.0, curve: Curves.linear);
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        // Barra de progreso que se vacía con el timer
        AnimatedBuilder(
          animation: _progressCtrl,
          builder: (_, _) => LinearProgressIndicator(
            value: _progressCtrl.value,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 2,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
