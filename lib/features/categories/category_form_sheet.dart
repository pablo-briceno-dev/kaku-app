import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/features/categories/widgets/toggle_is_income_category.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/emoji_picker_field.dart';
import 'package:kaku/shared/widgets/preview_icon_for_widgets.dart';
import 'package:kaku/shared/widgets/selected_color_picker.dart';

class CategoryFormSheet extends ConsumerStatefulWidget {
  final int totalCategories;
  final Category? category;

  const CategoryFormSheet({super.key, this.category, this.totalCategories = 0});

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  TransactionType selectedType = TransactionType.expense;
  String _selectedEmoji = '🍕';

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedEmoji = widget.category!.emoji;
      _colorController.text = widget.category!.colorHex;
      selectedType = widget.category!.isIncome
          ? TransactionType.income
          : TransactionType.expense;
    } else {
      _nameController.text = 'Nueva Categoría';
      _colorController.text = '#FF6B6B';
    }

    _nameController.addListener(_refresh);
    _colorController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: PreviewIconForWidgets(
              color: hexToColor(_colorController.text),
              icon: _selectedEmoji,
              label: _nameController.text,
              subtitle: 'Vista previa',
              size: 90,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 2),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            maxLength: 30,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            decoration: const InputDecoration(labelText: 'Nombre*'),
          ),
          const SizedBox(height: 16),
          EmojiPickerField(
            selectedEmoji: _selectedEmoji,
            onChanged: (emoji) => setState(() => _selectedEmoji = emoji),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Color', style: ts.titleMedium),
              const SizedBox(width: 20),
              SelectedColorPicker(
                onColorSelected: (color) =>
                    setState(() => _colorController.text = colorToHex(color)),
                initialColor: hexToColor(_colorController.text),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ToggleIsIncomeCategory(
            selectedType: selectedType,
            onPressed: (index) => setState(
              () => selectedType = index == 0
                  ? TransactionType.expense
                  : TransactionType.income,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nameController.text.isEmpty
                  ? null
                  : () async {
                      final dao = ref.read(categoriesDaoProvider);
                      if (widget.category != null) {
                        await dao.updateCategory(
                          Category(
                            id: widget.category!.id,
                            name: _nameController.text,
                            emoji: _selectedEmoji,
                            colorHex: _colorController.text,
                            isDefault: widget.category!.isDefault,
                            isIncome: selectedType == TransactionType.income,
                            isActive: widget.category!.isActive,
                            sortOrder: widget.category!.sortOrder,
                            isSystem: widget.category!.isSystem,
                          ),
                        );
                      } else {
                        await dao.insertCategory(
                          CategoriesTableCompanion.insert(
                            name: _nameController.text,
                            emoji: drift.Value(_selectedEmoji),
                            colorHex: drift.Value(_colorController.text),
                            isDefault: drift.Value(false),
                            isIncome: drift.Value(
                              selectedType == TransactionType.income,
                            ),
                            isActive: drift.Value(true),
                            isSystem: drift.Value(false),
                            sortOrder: drift.Value(widget.totalCategories + 1),
                          ),
                        );
                      }

                      if (context.mounted) {
                        AppSnackbar.success(
                          context,
                          widget.category != null
                              ? 'Categoría actualizada'
                              : 'Categoría creada',
                        );
                        Navigator.pop(context);
                      }
                    },
              child: widget.category != null
                  ? const Text('Actualizar')
                  : const Text('Crear Categoría'),
            ),
          ),
        ],
      ),
    );
  }
}
