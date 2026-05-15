import 'package:drift/drift.dart';

// Genera: Account (data class) + AccountsTableCompanion
@DataClassName('Account')
class AccountsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get type => text().withDefault(
    const Constant('cash'),
  )(); // cash, debit, credit, savings
  TextColumn get currency =>
      text().withDefault(const Constant('USD'))(); // COP, USD, EUR
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get colorHex => text().withDefault(const Constant('#7cffd4'))();
  TextColumn get icon => text().withDefault(
    const Constant('💳'),
  )(); //? Talvéz se pueda añadir el nombre del icono
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
