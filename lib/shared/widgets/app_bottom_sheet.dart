import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;

  // Si true, el sheet ocupa toda la pantalla (útil para formularios largos).
  final bool isFullScreen;

  // Si false, el usuario no puede cerrar arrastrando hacia abajo.
  // Úsalo cuando haya datos sin guardar.
  final bool isDismissible;

  // Padding extra debajo del contenido para no quedar tapado
  // por el teclado cuando aparece.
  final bool resizeToAvoidBottomInset;

  const AppBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.isFullScreen = false,
    this.isDismissible = true,
    this.resizeToAvoidBottomInset = true,
  });

  // ════════════════════════════════════════════════════════
  //  Método estático helper — úsalo desde cualquier widget.
  //
  //  Devuelve T? porque el sheet puede retornar un resultado
  //  al cerrarse (útil para saber si el usuario guardó algo).
  //
  //  Ejemplo:
  //    final saved = await AppBottomSheet.show<bool>(
  //      context,
  //      title: 'Nueva cuenta',
  //      child: AccountFormSheet(),
  //    );
  //    if (saved == true) { /* éxito */ }
  // ════════════════════════════════════════════════════════
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    required Widget child,
    bool isFullScreen = false,
    bool isDismissible = true,
    bool resizeToAvoidBottomInset = true,
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      // isScrollControlled = true permite que el sheet
      // crezca más allá del 50% de la pantalla y que el
      // teclado no lo tape cuando isFullScreen = true.
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      useRootNavigator: useRootNavigator,
      // backgroundColor transparent para que el
      // Container interno maneje el color y el borderRadius.
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        subtitle: subtitle,
        isFullScreen: isFullScreen,
        isDismissible: isDismissible,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        child: SingleChildScrollView(
          child: Column(
            children: [
              child,
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    // Padding del teclado: si está visible, el contenido
    // sube para no quedar tapado.
    final keyboardPadding = resizeToAvoidBottomInset
        ? mq.viewInsets.bottom
        : 0.0;

    // Altura máxima: full screen deja 32px de margen arriba
    // para que se vea que está sobre el contenido.
    // Normal: 92% de la pantalla como máximo.
    final maxHeight = isFullScreen
        ? mq.size.height - 32 - mq.padding.top
        : mq.size.height * 0.92;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          // ✅ DecoratedBox externo solo para el borde superior sutil.
          // Un solo color uniforme → compatible con borderRadius.
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: ClipRRect(
            // ClipRRect aplica el radio al contenido interior.
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              // Container interno solo para el color de fondo,
              // sin border → sin el conflicto de colores.
              color: cs.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Handle(isDismissible: isDismissible),
                  if (title != null)
                    _Header(
                      title: title!,
                      subtitle: subtitle,
                      onClose: isDismissible
                          ? () => Navigator.of(context).pop()
                          : null,
                    ),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Handle ──────────────────────────────────────────────
class _Handle extends StatelessWidget {
  final bool isDismissible;
  const _Handle({required this.isDismissible});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isDismissible ? 40 : 24,
          height: 4,
          decoration: BoxDecoration(
            // Cuando no es dismissible el handle se hace
            // más pequeño y opaco para indicar que no se
            // puede arrastrar.
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
              alpha: isDismissible ? 0.3 : 0.12,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Cabecera ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  const _Header({required this.title, this.subtitle, this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + subtítulo
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: subtitle != null
                        ? FontWeight.w800
                        : FontWeight.bold,
                    letterSpacing: -0.02,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          // Botón de cierre (solo si es dismissible)
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(
                Icons.close_rounded,
                color: cs.onSurfaceVariant,
                size: 30,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Cerrar',
            ),
        ],
      ),
    );
  }
}
