import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class EntryTile extends ConsumerWidget {
  final CalendarEntry entry;

  const EntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);
    final amount = entry.amount;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        amount != null
            ? Icons.event_available_outlined
            : Icons.sticky_note_2_outlined,
        color: amount != null ? cs.primary : cs.tertiary,
      ),
      title: Text(entry.title),
      subtitle: Text(
        amount != null
            ? '${l10n.calendarPlannedExpense} · ${CurrencyFormatter.format(amount, currency)}'
            : l10n.calendarNote,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: l10n.btnDelete,
        onPressed: () => ref.read(calendarDaoProvider).deleteEntry(entry),
      ),
    );
  }
}
