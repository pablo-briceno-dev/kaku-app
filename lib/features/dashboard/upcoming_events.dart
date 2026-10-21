import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/dashboard/widgets/upcoming_event_item.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class UpcomingEvents extends ConsumerWidget {
  const UpcomingEvents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final args = (month: selectedMonth.month, year: selectedMonth.year);

    final entriesAsync = ref.watch(calendarMonthProvider(args));

    return entriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final today = DateTime.now();
        final latestEntries = <CalendarEntry>[];
        var count = 0;
        for (final e in entries) {
          if ((e.date.isAfter(today) || e.date.isAtSameMomentAs(today)) &&
              e.status == EntryStatus.pending.name &&
              count < 3) {
            latestEntries.add(e);
            count++;
          }
        }

        return Container(
          // width: 120,
          // height: fixedHeight,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.primary.withAlpha(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    l10n.upcomingEventsTitle,
                    style: ts.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(
                      AppRoutes.toPersonal(initialTab: 'calendar'),
                    ),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...latestEntries.map(
                (e) => UpcomingEventItem(
                  date: e.date,
                  title: e.title,
                  amount: e.amount,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
