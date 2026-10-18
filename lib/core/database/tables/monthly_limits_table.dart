import 'package:drift/drift.dart';

@DataClassName("MonthlyLimit")
class MonthlyLimitsTable extends Table {
  IntColumn get period => integer()(); // año*100 + mes, p. ej. 202610
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {period};
}
