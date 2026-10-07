import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:kaku/l10n/app_localizations.dart';

class SelectedColorPicker extends StatefulWidget {
  final Function(Color) onColorSelected;
  final VoidCallback? onCancel;
  final Color initialColor;

  const SelectedColorPicker({
    super.key,
    required this.onColorSelected,
    this.onCancel,
    this.initialColor = Colors.blue,
  });

  @override
  State<SelectedColorPicker> createState() => _SelectedColorPickerState();
}

class _SelectedColorPickerState extends State<SelectedColorPicker> {
  Color tempColor = Colors.green;

  @override
  void initState() {
    super.initState();
    tempColor = widget.initialColor;
  }

  void _openDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.selectedColor),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Preview
            const SizedBox(height: 16),

            /// Picker
            ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onCancel?.call();
              Navigator.pop(ctx);
            },
            child: Text(l10n.btnCancel),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onColorSelected(tempColor);
              Navigator.pop(ctx);
            },
            child: Text(l10n.btnAdd),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDialog(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: tempColor,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}
