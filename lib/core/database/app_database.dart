import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kaku/core/database/daos/budgets_dao.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/database/tables/accounts_table.dart';
import 'package:kaku/core/database/tables/budgets_table.dart';
import 'package:kaku/core/database/tables/categories_table.dart';
import 'package:kaku/core/database/tables/goals_table.dart';
import 'package:kaku/core/database/tables/transactions_table.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AccountsTable,
    CategoriesTable,
    BudgetsTable,
    GoalsTable,
    TransactionsTable,
  ],
  daos: [AccountsDao, TransactionsDao, BudgetsDao, GoalsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Aquí irán las migraciones cuando actualice el schema
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultCategories(); // categorías por defecto
    },
  );

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      ('Comida', '🍔', '#FF6B6B'),
      ('Transporte', '🚌', '#4ECDC4'),
      ('Casa', '🏠', '#45B7D1'),
      ('Salud', '💊', '#96CEB4'),
      ('Ocio', '🎮', '#FFEAA7'),
      ('Educación', '📚', '#DDA0DD'),
    ];
    for (final (name, emoji, color) in defaults) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          name: name,
          emoji: Value(emoji),
          colorHex: Value(color),
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kaku_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
