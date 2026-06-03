import 'package:flutter/material.dart';
import 'package:kaku/shared/widgets/emoji_picker_sheet.dart';

class EmojiPickerField extends StatelessWidget {
  final String selectedEmoji;
  final ValueChanged<String> onChanged;

  const EmojiPickerField({
    super.key,
    required this.selectedEmoji,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emoji',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 0.5,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _openPicker(context),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(selectedEmoji, style: const TextStyle(fontSize: 34)),
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 11,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmojiPickerSheet(
        initialEmoji: selectedEmoji,
        onSelected: (emoji) {
          onChanged(emoji);
          Navigator.pop(context);
        },
      ),
    );
  }
}
