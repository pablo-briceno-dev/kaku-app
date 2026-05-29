import 'package:flutter/material.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/shared/utils/emojis_defaults.dart';
import 'package:kaku/shared/widgets/emoji_picker.dart';
import 'package:kaku/shared/widgets/preview_icon_for_widgets.dart';

class CategoryFormSheet extends StatefulWidget {
  final Category? category;

  const CategoryFormSheet({super.key, this.category});

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emojiController = TextEditingController(text: '0');
  TextEditingController _colorController = TextEditingController();
  final List<String> _emojis = categoryEmojis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: PreviewIconForWidgets(
              color: hexToColor('#7cffd4'),
              icon: '🍕',
              // label: controllers['name']?.text,
              subtitle: 'Vista previa',
              size: 90,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 2),
          const SizedBox(height: 16),
          EmojiPicker(
            emojis: _emojis,
            selectedEmoji: int.tryParse(_emojiController.text) ?? 0,
            onEmojiSelected: (index) =>
                setState(() => _emojiController.text = index.toString()),
          ),
        ],
      ),
    );
  }
}
