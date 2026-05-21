import 'package:drift/drift.dart';

// Genera: Account (data class) + AccountsTableCompanion
@DataClassName('Account')
class AccountsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  // cash, debit, credit, savings - Se insertará el index
  IntColumn get type => integer().withDefault(const Constant(1))();
  // COP, USD, EUR
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get colorHex => text().withDefault(const Constant('#7cffd4'))();
  //? Talvéz se pueda añadir el nombre del icono
  TextColumn get icon => text().withDefault(const Constant('💳'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
