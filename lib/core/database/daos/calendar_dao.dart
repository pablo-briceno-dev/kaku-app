import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/calendar_entries_table.dart';
import 'package:kaku/core/database/tables/monthly_limits_table.dart';
import 'package:kaku/core/models/entry_status.dart';
import 'package:kaku/core/recurrence.dart';

part 'calendar_dao.g.dart';

@DriftAccessor(tables: [CalendarEntriesTable, MonthlyLimitsTable])
class CalendarDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarDaoMixin {
  CalendarDao(super.db);

  Stream<List<CalendarEntry>> watchMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return (select(calendarEntriesTable)
          ..where(
            (e) =>
                e.date.isBiggerOrEqualValue(start) &
                e.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([
            (e) => OrderingTerm.asc(e.date),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .watch();
  }

  Future<int> insertEntry(CalendarEntriesTableCompanion entry) =>
      into(calendarEntriesTable).insert(entry);

  Future<bool> updateEntry(CalendarEntry entry) =>
      update(calendarEntriesTable).replace(entry);

  Future<int> deleteEntry(int id) =>
      (delete(calendarEntriesTable)..where((e) => e.id.equals(id))).go();

  Future<void> setStatus(int id, EntryStatus status, {int? transactionId}) =>
      (update(calendarEntriesTable)..where((e) => e.id.equals(id))).write(
        CalendarEntriesTableCompanion(
          status: Value(status.name),
          transactionId: Value(transactionId),
        ),
      );

  Future<CalendarEntry?> getById(int id) => (select(
    calendarEntriesTable,
  )..where((e) => e.id.equals(id))).getSingleOrNull();

  // Recordatorios futuros de entradas pendientes (para el límite del plan gratuito)
  Future<int> countActiveReminders({int? excludeId}) async {
    final count = calendarEntriesTable.id.count();
    final query = selectOnly(calendarEntriesTable)
      ..addColumns([count])
      ..where(
        calendarEntriesTable.remindAt.isBiggerThanValue(DateTime.now()) &
            calendarEntriesTable.status.equals(EntryStatus.pending.name) &
            (excludeId == null
                ? const Constant(true)
                : calendarEntriesTable.id.equals(excludeId).not()),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<List<CalendarEntry>> getUpcomingReminders({int limit = 60}) =>
      (select(calendarEntriesTable)
            ..where(
              (e) =>
                  e.remindAt.isBiggerThanValue(DateTime.now()) &
                  e.status.equals(EntryStatus.pending.name),
            )
            ..orderBy([(e) => OrderingTerm.asc(e.remindAt)])
            ..limit(limit))
          .get();

  // Límite mensual (se arrastra a los meses siguientes)
  int _period(int year, int month) => year * 100 + month;

  Stream<MonthlyLimit?> watchLimitFor(int year, int month) =>
      (select(monthlyLimitsTable)
            ..where((t) => t.period.isSmallerOrEqualValue(_period(year, month)))
            ..orderBy([(t) => OrderingTerm.desc(t.period)])
            ..limit(1))
          .watchSingleOrNull();

  Future<void> setLimit(int year, int month, double amount) =>
      into(monthlyLimitsTable).insertOnConflictUpdate(
        MonthlyLimitsTableCompanion(
          period: Value(_period(year, month)),
          amount: Value(amount),
        ),
      );

  // Series recurrentes
  Future<void> insertSeries(List<CalendarEntriesTableCompanion> rows) async {
    if (rows.isEmpty) return;
    await transaction(() async {
      final firstId = await into(calendarEntriesTable).insert(rows.first);
      await (update(calendarEntriesTable)..where((c) => c.id.equals(firstId)))
          .write(CalendarEntriesTableCompanion(seriesId: Value(firstId)));
      for (final r in rows.skip(1)) {
        await into(
          calendarEntriesTable,
        ).insert(r.copyWith(seriesId: Value(firstId)));
      }
    });
  }

  // Borra esta ocurrencia y las siguientes pendientes, y cierra la serie
  Future<void> deleteSeriesFrom(CalendarEntry entry) async {
    final sid = entry.seriesId;
    if (sid == null) {
      await deleteEntry(entry.id);
      return;
    }
    await transaction(() async {
      await (delete(calendarEntriesTable)..where(
            (e) =>
                e.seriesId.equals(sid) &
                e.status.equals(EntryStatus.pending.name) &
                e.date.isBiggerOrEqualValue(entry.date),
          ))
          .go();
      await (update(
        calendarEntriesTable,
      )..where((e) => e.seriesId.equals(sid))).write(
        const CalendarEntriesTableCompanion(recurrence: Value('none')),
      );
    });
  }

  // Mantiene 12 meses de ocurrencias hacia adelante
  Future<void> extendSeries({int horizonMonths = 12}) async {
    final now = DateTime.now();
    final until = DateTime(now.year, now.month + horizonMonths, now.day);

    final rows =
        await (select(calendarEntriesTable)
              ..where(
                (e) =>
                    e.seriesId.isNotNull() & e.recurrence.equals('none').not(),
              )
              ..orderBy([(e) => OrderingTerm.asc(e.date)]))
            .get();
    final bySeries = <int, List<CalendarEntry>>{};
    for (final row in rows) {
      bySeries.putIfAbsent(row.seriesId!, () => []).add(row);
    }

    await transaction(() async {
      for (final list in bySeries.values) {
        final first = list.first;
        final last = list.last;
        final r = Recurrence.values.byName(first.recurrence);
        final newDates = recurrenceDates(
          first.date,
          r,
          until,
        ).where((d) => d.isAfter(last.date));
        for (final d in newDates) {
          await into(calendarEntriesTable).insert(
            CalendarEntriesTableCompanion.insert(
              date: d,
              title: last.title,
              amount: Value(last.amount),
              categoryId: Value(last.categoryId),
              accountId: Value(last.accountId),
              remindAt: Value(shiftReminder(last.date, last.remindAt, d)),
              recurrence: Value(last.recurrence),
              seriesId: Value(last.seriesId),
            ),
          );
        }
      }
    });
  }
}
