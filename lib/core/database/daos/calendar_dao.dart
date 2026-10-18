import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/calendar_entries_table.dart';
import 'package:kaku/core/models/entry_status.dart';

part 'calendar_dao.g.dart';

@DriftAccessor(tables: [CalendarEntriesTable])
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
}
