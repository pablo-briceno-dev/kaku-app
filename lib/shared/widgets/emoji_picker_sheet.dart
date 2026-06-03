import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmojiPickerSheet extends StatefulWidget {
  final String initialEmoji;
  final ValueChanged<String> onSelected;

  const EmojiPickerSheet({
    super.key,
    required this.initialEmoji,
    required this.onSelected,
  });

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialEmoji;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      // ✅ width doble infinity para ocupar todo el sheet
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // ← stretch en lugar de center
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Cabecera con preview del emoji seleccionado
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Elige un emoji',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  // Preview del emoji actual
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(_current, style: const TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),

            // ── EmojiPicker ───────────────────────────────
            // LayoutBuilder para obtener el ancho real disponible
            // dentro del bottom sheet (descuenta padding lateral)
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                width: constraints.maxWidth,
                height: 320,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() => _current = emoji.emoji);
                    widget.onSelected(emoji.emoji);
                  },
                  config: Config(
                    // Altura del picker dentro del sheet
                    height: 320,

                    // Verifica compatibilidad con el dispositivo
                    checkPlatformCompatibility: true,

                    // Orden de los elementos del picker
                    viewOrderConfig: const ViewOrderConfig(
                      top: EmojiPickerItem.categoryBar,
                      middle: EmojiPickerItem.emojiView,
                      bottom: EmojiPickerItem.searchBar, // buscador abajo
                    ),

                    emojiViewConfig: EmojiViewConfig(
                      // Tamaño de los emojis — fix para iOS
                      emojiSizeMax:
                          28 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.20
                              : 1.0),
                      backgroundColor: cs.surface,
                    ),

                    // Barra de categorías adaptada al tema
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: cs.surface,
                      iconColor: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      iconColorSelected: cs.primary,
                      indicatorColor: cs.primary,
                      backspaceColor: cs.primary,
                      categoryIcons: const CategoryIcons(),
                    ),

                    // Barra de búsqueda adaptada al tema
                    searchViewConfig: SearchViewConfig(
                      backgroundColor: cs.surface,
                      buttonIconColor: cs.primary,
                      hintText: 'Buscar emoji...',
                      inputTextStyle: TextStyle(color: cs.onSurface),
                      hintTextStyle: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),

                    // Skin tones (tonos de piel) — habilitados
                    skinToneConfig: const SkinToneConfig(),

                    // Solo inglés para reducir el tamaño del paquete
                    emojiSet: (locale) => defaultEmojiSet,
                  ),
                ), // cierra EmojiPicker
              ), // cierra SizedBox
            ), // cierra LayoutBuilder
            // Espacio para el safe area inferior
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
