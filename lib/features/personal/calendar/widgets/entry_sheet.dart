import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class EntrySheet extends ConsumerStatefulWidget {
  final DateTime date;

  const EntrySheet({super.key, required this.date});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount(CurrencyType currency) =>
      CurrencyFormatter.parse(_amountController.text, currency);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(calendarDaoProvider)
        .insertEntry(
          CalendarEntriesTableCompanion.insert(
            date: DateUtils.dateOnly(widget.date),
            title: _titleController.text.trim(),
            amount: drift.Value(_parseAmount(ref.read(currencyProvider))),
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.calendarEntryTitleLabel,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.formRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
              decoration: InputDecoration(
                labelText: l10n.calendarEntryAmountLabel,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = CurrencyFormatter.parse(v, currency);
                return (n <= 0) ? l10n.formAmountMajor : null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l10n.btnSave)),
          ],
        ),
      ),
    );
  }
}
