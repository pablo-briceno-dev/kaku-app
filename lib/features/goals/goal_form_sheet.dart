import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/features/goals/goals_list.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/date_picker_field.dart';
import 'package:kaku/shared/widgets/emoji_picker_field.dart';

class GoalFormSheet extends ConsumerStatefulWidget {
  final GoalsListConfig? goal;
  final String defaultName;

  const GoalFormSheet({super.key, this.goal, required this.defaultName});

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  String _selectedEmoji = '🎯';
  DateTime _deadline = DateTime.now();
  final controllers = <String, TextEditingController>{
    'name': TextEditingController(),
    'targetAmount': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    final currency = ref.read(currencyProvider);
    if (widget.goal != null) {
      controllers['name']?.text = widget.goal!.name;
      _selectedEmoji = widget.goal!.emoji;
      controllers['targetAmount']?.text = CurrencyFormatter.format(
        widget.goal!.targetAmount,
        currency,
      );
      controllers['deadline']?.text = context.dates.fullDateTime(
        widget.goal!.deadline!,
      );
    } else {
      controllers['name']?.text = widget.defaultName;
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
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  _selectedEmoji,
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
                  l10n.nameGoal(name: controllers['name']?.text ?? ''),
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
            validator: (value) => value!.isEmpty ? l10n.formRequired : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(labelText: '${l10n.formName}*'),
          ),
          const SizedBox(height: 16),
          EmojiPickerField(
            selectedEmoji: _selectedEmoji,
            onChanged: (emoji) => setState(() => _selectedEmoji = emoji),
          ),
          const SizedBox(height: 26),
          TextFormField(
            controller: controllers['targetAmount'],
            keyboardType: const TextInputType.numberWithOptions(
              decimal:
                  true, // ← muestra "." o "," según el idioma del dispositivo
              signed: false, // ← no muestra el botón "-"
            ),
            inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.formRequired;
              }
              if (CurrencyFormatter.parse(value, currency) <= 0) {
                return l10n.formAmountMajor;
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: '${l10n.amountGoal}*',
              hintText: r'$0',
            ),
          ),
          const SizedBox(height: 16),
          DatePickerField(
            label: l10n.dateGoal,
            mode: DatePickerFieldMode.future,
            selectedDate: _deadline,
            onChanged: (date) {
              setState(() => _deadline = date);
            },
          ),
          const SizedBox(height: 8),
          Text(l10n.dateGoalMessage, style: ts.titleSmall),
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
                            emoji: _selectedEmoji,
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
                            emoji: drift.Value(_selectedEmoji),
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
                              ? l10n.goalUpdateSuccess
                              : l10n.goalCreateSuccess,
                        );
                        Navigator.pop(context);
                      }
                    },
              child: widget.goal != null
                  ? Text(l10n.btnUpdateGoal)
                  : Text(l10n.btnCreateGoal),
            ),
          ),
        ],
      ),
    );
  }
}
