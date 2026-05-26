import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {
  final List<String> emojis;
  final int selectedEmoji;
  final Function(int) onEmojiSelected;
  final VoidCallback? onAddEmoji;

  const EmojiPicker({
    super.key,
    required this.emojis,
    required this.onEmojiSelected,
    this.onAddEmoji,
    required this.selectedEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisExtent: 50,
        crossAxisSpacing: 12,
        mainAxisSpacing: 15,
      ),
      itemCount: emojis.length,
      itemBuilder: (_, index) {
        final emoji = emojis[index];
        final isSelected = index == selectedEmoji;

        return InkWell(
          onTap: () => onEmojiSelected(index),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:
                  (isSelected
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest)
                      .withAlpha(60),
              border: Border.all(
                color: isSelected
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 25)),
            ),
          ),
        );
      },
    );
  }
}
