import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/features/goals/goals_list.dart';
import 'package:kaku/features/goals/widgets/emoji_picker.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/date_picker_field.dart';
import 'package:drift/drift.dart' as drift;

class GoalFormSheet extends ConsumerStatefulWidget {
  final GoalsListConfig? goal;

  const GoalFormSheet({super.key, this.goal});

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  DateTime _deadline = DateTime.now();
  final List<String> _emojis = [
    '🎯',
    '✈️',
    '🏠',
    '📱',
    '🎓',
    '🚗',
    '💍',
    '🌴',
    '💻',
    '🎸',
    '🐕',
  ];
  final controllers = <String, TextEditingController>{
    'name': TextEditingController(),
    'emoji': TextEditingController(),
    'targetAmount': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    final currency = ref.read(currencyProvider);
    if (widget.goal != null) {
      controllers['name']?.text = widget.goal!.name;
      controllers['emoji']?.text = _emojis
          .indexOf(widget.goal!.emoji)
          .toString();
      controllers['targetAmount']?.text = CurrencyFormatter.format(
        widget.goal!.targetAmount,
        currency,
      );
      controllers['deadline']?.text = DateFormatter.fullDateTime(
        widget.goal!.deadline!,
      );
    } else {
      controllers['name']?.text = 'Nueva Meta';
      controllers['emoji']?.text = _emojis[0];
      controllers['targetAmount']?.text = CurrencyFormatter.format(0, currency);
    }

    controllers['name']?.addListener(_refresh);
    controllers['targetAmount']?.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _validatedButton(CurrencyType currency) {
    if (controllers['name']?.text == null ||
        controllers['name']!.text.isEmpty) {
      return true;
    }
    if (controllers['targetAmount']?.text == null ||
        controllers['targetAmount']!.text.isEmpty ||
        CurrencyFormatter.parse(controllers['targetAmount']!.text, currency) <=
            0) {
      debugPrint('targetAmount <= 0');
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final currency = ref.watch(currencyProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _emojis[int.tryParse(controllers['emoji']?.text ?? '0') ?? 0],
                  style: ts.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 50,
                  ),
                ),
                Text(
                  controllers['name']?.text ?? '',
                  style: ts.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.justify,
                ),
                Text(
                  'Meta: ${controllers['targetAmount']?.text ?? ''}',
                  style: ts.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 2),
          const SizedBox(height: 20),
          TextFormField(
            controller: controllers['name'],
            keyboardType: TextInputType.text,
            maxLength: 60,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(labelText: 'Nombre*'),
          ),
          const SizedBox(height: 16),
          Text('Emoji', style: ts.titleMedium),
          EmojiPicker(
            emojis: _emojis,
            selectedEmoji: int.tryParse(controllers['emoji']?.text ?? '0') ?? 0,
            onEmojiSelected: (index) =>
                setState(() => controllers['emoji']?.text = index.toString()),
          ),
          TextFormField(
            controller: controllers['targetAmount'],
            keyboardType: const TextInputType.numberWithOptions(
              decimal:
                  true, // ← muestra "." o "," según el idioma del dispositivo
              signed: false, // ← no muestra el botón "-"
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')), // ← primero
              CurrencyFormatter.inputFormatter(currency), // ← luego el tuyo
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              if (CurrencyFormatter.parse(value, currency) <= 0) {
                return 'Debe ser mayor a 0';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Monto objetivo*',
              hintText: r'$0',
            ),
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: 'Fecha límite (opcional)',
            selectedDate: _deadline,
            onChanged: (date) {
              setState(() => _deadline = date);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Si no ingresa una fecha, el sistema utilizará su historial de ahorro para estimar cuándo podría cumplir su meta.',
            style: ts.titleSmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validatedButton(currency)
                  ? null
                  : () async {
                      final dao = ref.read(goalsDaoProvider);
                      if (widget.goal != null) {
                        await dao.updateGoal(
                          Goal(
                            id: widget.goal!.id,
                            name: controllers['name']!.text,
                            emoji:
                                _emojis[int.tryParse(
                                      controllers['emoji']?.text ?? '0',
                                    ) ??
                                    0],
                            targetAmount: CurrencyFormatter.parse(
                              controllers['targetAmount']!.text,
                              currency,
                            ),
                            savedAmount: widget.goal!.savedAmount,
                            deadline:
                                DateFormatter.isSameDay(
                                  _deadline,
                                  DateTime.now(),
                                )
                                ? null
                                : _deadline,
                            type: widget.goal!.type,
                            isCompleted: widget.goal!.isCompleted,
                            createdAt: widget.goal!.createdAt,
                          ),
                        );
                      } else {
                        await dao.insertGoal(
                          GoalsTableCompanion.insert(
                            name: controllers['name']!.text,
                            emoji: drift.Value(
                              _emojis[int.tryParse(
                                    controllers['emoji']?.text ?? '0',
                                  ) ??
                                  0],
                            ),
                            targetAmount: CurrencyFormatter.parse(
                              controllers['targetAmount']!.text,
                              currency,
                            ),
                            deadline:
                                DateFormatter.isSameDay(
                                  _deadline,
                                  DateTime.now(),
                                )
                                ? drift.Value(null)
                                : drift.Value(_deadline),
                          ),
                        );
                      }
                      if (context.mounted) {
                        AppSnackbar.success(
                          context,
                          widget.goal != null
                              ? 'Meta actualizada'
                              : 'Meta creada',
                        );
                        Navigator.pop(context);
                      }
                    },
              child: widget.goal != null
                  ? const Text('Actualizar Meta')
                  : const Text('Crear Meta'),
            ),
          ),
        ],
      ),
    );
  }
}
