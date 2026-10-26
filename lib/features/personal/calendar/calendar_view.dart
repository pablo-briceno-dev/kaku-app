import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/personal/calendar/month_limit_card.dart';
import 'package:kaku/features/personal/calendar/widgets/entry_sheet.dart';
import 'package:kaku/features/personal/calendar/widgets/entry_tile.dart';
import 'package:kaku/features/personal/calendar/widgets/month_grid.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/transaction_item.dart';

class CalendarView extends ConsumerStatefulWidget {
  final DateTime? initialDay;
  final String? focusToken;

  const CalendarView({super.key, this.initialDay, this.focusToken});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _selected = DateUtils.dateOnly(
    widget.initialDay ?? DateTime.now(),
  );
  late DateTime _month = DateTime(_selected.year, _selected.month);

  @override
  void didUpdateWidget(CalendarView old) {
    super.didUpdateWidget(old);
    final d = widget.initialDay;
    if (d != null &&
        (d != old.initialDay || widget.focusToken != old.focusToken)) {
      _selected = DateUtils.dateOnly(d);
      _month = DateTime(d.year, d.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final args = (month: _month.month, year: _month.year);

    final entries =
        ref.watch(calendarMonthProvider(args)).value ?? const <CalendarEntry>[];
    final txs =
        ref.watch(monthTransactionsProvider(args)).value ??
        const <TransactionWithCategory>[];

    final markers = <DateTime, DayMarkers>{};
    void mark(
      DateTime d, {
      bool spent = false,
      bool planned = false,
      bool note = false,
    }) {
      final key = DateUtils.dateOnly(d);
      markers[key] = (markers[key] ?? const DayMarkers()).merge(
        spent: spent,
        planned: planned,
        note: note,
      );
    }

    for (final t in txs) {
      if (t.transaction.type == TransactionType.expense.name) {
        mark(t.transaction.date, spent: true);
      }
    }
    for (final e in entries) {
      if (e.amount == null) {
        mark(e.date, note: true);
      } else if (e.status == EntryStatus.pending.name) {
        mark(e.date, planned: true);
      }
    }

    final dayEntries = entries
        .where((e) => DateUtils.isSameDay(e.date, _selected))
        .toList();
    final dayTxs = txs
        .where((t) => DateUtils.isSameDay(t.transaction.date, _selected))
        .toList();

    final spent = txs
        .where((t) => t.transaction.type == TransactionType.expense.name)
        .fold<double>(0, (s, t) => s + t.transaction.amount);
    final planned = entries
        .where(
          ((e) => e.amount != null && e.status == EntryStatus.pending.name),
        )
        .fold<double>(0, (s, e) => s + e.amount!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        MonthGrid(
          month: _month,
          selected: _selected,
          markers: markers,
          onDaySelected: (d) => setState(() => _selected = d),
          onMonthChanged: (m) => setState(() {
            _month = m;
            _selected = m;
          }),
        ),
        const SizedBox(height: 8),
        MonthLimitCard(
          year: _month.year,
          month: _month.month,
          spent: spent,
          planned: planned,
        ),
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                context.dates.dayMonthYear(_selected),
                style: ts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => EntrySheet(date: _selected),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.calendarAddEntry),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (dayEntries.isEmpty && dayTxs.isEmpty)
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.calendarEmptyDay,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        for (final e in dayEntries) EntryTile(entry: e),
        if (dayTxs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              l10n.transactionCount(dayTxs.length),
              style: ts.labelMedium,
            ),
          ),
          for (final t in dayTxs)
            TransactionItem(
              txWithCat: t,
              onTap: () =>
                  context.push(AppRoutes.toTransaction(t.transaction.id)),
            ),
        ],
      ],
    );
  }
}
