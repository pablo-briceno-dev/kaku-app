import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/personal/calendar/widgets/entry_sheet.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/calendar_provider.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

enum _EntryAction { paid, skip, delete, deleteSeries }

class EntryTile extends ConsumerWidget {
  final CalendarEntry entry;

  const EntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final amount = entry.amount;
    final isPlanned = amount != null;
    final pending = entry.status == EntryStatus.pending.name;
    final done = entry.status == EntryStatus.done.name;
    final currency = ref.read(currencyProvider);
    final inSeries = entry.seriesId != null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: pending
          ? () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => EntrySheet(date: entry.date, entry: entry),
            )
          : null,
      leading: Icon(
        done
            ? Icons.check_circle_outline
            : !pending
            ? Icons.remove_circle_outline
            : isPlanned
            ? Icons.event_available_outlined
            : Icons.sticky_note_2_outlined,
        color: !pending
            ? cs.onSurfaceVariant
            : isPlanned
            ? cs.primary
            : cs.tertiary,
      ),
      title: Text(
        entry.title,
        style: TextStyle(
          decoration: pending ? null : TextDecoration.lineThrough,
          color: pending ? null : cs.onSurfaceVariant,
        ),
      ),
      subtitle: Row(
        children: [
          if (entry.remindAt != null) ...[
            Icon(
              Icons.notifications_active_outlined,
              size: 14,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              isPlanned
                  ? '${l10n.calendarPlannedExpense} · ${CurrencyFormatter.format(amount, currency)}'
                  : l10n.calendarNote,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<_EntryAction>(
        onSelected: (action) async {
          final dao = ref.read(calendarDaoProvider);
          final reminders = ref.read(reminderServiceProvider);
          switch (action) {
            case _EntryAction.paid:
              context.push(AppRoutes.toAddTransaction(entryId: entry.id));
            case _EntryAction.skip:
              await dao.setStatus(entry.id, EntryStatus.skipped);
              await reminders.cancel(entry.id);
            case _EntryAction.delete:
              await dao.deleteEntry(entry.id);
              await reminders.cancel(entry.id);
            case _EntryAction.deleteSeries:
              await ref
                  .read(calendarControllerProvider)
                  .deleteSeriesFrom(entry);
          }
        },
        itemBuilder: (_) => [
          if (pending && isPlanned)
            PopupMenuItem(
              value: _EntryAction.paid,
              child: Text(l10n.calendarMarkPaid),
            ),
          if (pending && (isPlanned || inSeries))
            PopupMenuItem(
              value: _EntryAction.skip,
              child: Text(l10n.calendarSkip),
            ),
          if (!inSeries)
            PopupMenuItem(
              value: _EntryAction.delete,
              child: Text(l10n.btnDelete),
            ),
          if (inSeries && pending)
            PopupMenuItem(
              value: _EntryAction.deleteSeries,
              child: Text(l10n.calendarDeleteSeries),
            ),
        ],
      ),
    );
  }
}
