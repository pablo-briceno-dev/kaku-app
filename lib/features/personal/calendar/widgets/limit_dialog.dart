import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class LimitDialog extends ConsumerStatefulWidget {
  final double current;

  const LimitDialog({super.key, required this.current});

  @override
  ConsumerState<LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends ConsumerState<LimitDialog> {
  late final _ctrl = TextEditingController(
    text: widget.current > 0
        ? CurrencyFormatter.format(widget.current, ref.read(currencyProvider))
        : '',
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    return AlertDialog(
      title: Text(l10n.calendarLimitSet),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
            decoration: InputDecoration(
              labelText: l10n.calendarLimitAmountLabel(currency.label),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.calendarLimitCarryNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            CurrencyFormatter.parse(_ctrl.text, currency),
          ),
          child: Text(l10n.btnSave),
        ),
      ],
    );
  }
}
