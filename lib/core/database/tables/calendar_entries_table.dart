import 'package:drift/drift.dart';

@DataClassName("CalendarEntry")
class CalendarEntriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()(); // el día, a medianoche
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get note => text().nullable()();
  RealColumn get amount => real().nullable()(); // null = nota simple
  IntColumn get categoryId => integer().nullable()();
  IntColumn get accountId => integer().nullable()();
  DateTimeColumn get remindAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant("pending"))();
  IntColumn get transactionId => integer().nullable()(); // se llena al pagarlo
}
