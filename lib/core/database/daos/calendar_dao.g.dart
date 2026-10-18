// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_dao.dart';

// ignore_for_file: type=lint
mixin _$CalendarDaoMixin on DatabaseAccessor<AppDatabase> {
  $CalendarEntriesTableTable get calendarEntriesTable =>
      attachedDatabase.calendarEntriesTable;
  $MonthlyLimitsTableTable get monthlyLimitsTable =>
      attachedDatabase.monthlyLimitsTable;
  CalendarDaoManager get managers => CalendarDaoManager(this);
}

class CalendarDaoManager {
  final _$CalendarDaoMixin _db;
  CalendarDaoManager(this._db);
  $$CalendarEntriesTableTableTableManager get calendarEntriesTable =>
      $$CalendarEntriesTableTableTableManager(
        _db.attachedDatabase,
        _db.calendarEntriesTable,
      );
  $$MonthlyLimitsTableTableTableManager get monthlyLimitsTable =>
      $$MonthlyLimitsTableTableTableManager(
        _db.attachedDatabase,
        _db.monthlyLimitsTable,
      );
}
