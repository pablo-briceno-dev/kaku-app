import 'package:drift/drift.dart';

// genera: Goal + GoalsTableCompanion
@DataClassName('Goal')
class GoalsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('🎯'))();
  RealColumn get targetAmount => real()(); // meta total
  RealColumn get savedAmount => real().withDefault(const Constant(0.0))();
  // normal || challenge
  TextColumn get type => text().withDefault(const Constant('normal'))();
  DateTimeColumn get deadline => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
