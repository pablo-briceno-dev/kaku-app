import 'package:drift/drift.dart';

// genera: Category + CategoriesTableCompanion
@DataClassName('Category')
class CategoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('📦'))();
  TextColumn get colorHex => text().withDefault(const Constant('#888888'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
}
