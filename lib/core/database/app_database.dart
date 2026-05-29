import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kaku/core/database/daos/accounts_dao.dart';
import 'package:kaku/core/database/daos/budgets_dao.dart';
import 'package:kaku/core/database/daos/categories_dao.dart';
import 'package:kaku/core/database/daos/goals_dao.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/database/tables/accounts_table.dart';
import 'package:kaku/core/database/tables/budgets_table.dart';
import 'package:kaku/core/database/tables/categories_table.dart';
import 'package:kaku/core/database/tables/goals_table.dart';
import 'package:kaku/core/database/tables/transactions_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AccountsTable,
    CategoriesTable,
    BudgetsTable,
    GoalsTable,
    TransactionsTable,
  ],
  daos: [
    AccountsDao, // CRUD de cuentas + balance
    TransactionsDao, // CRUD de transacciones + queries por mes
    BudgetsDao, // CRUD de presupuestos mensuales
    GoalsDao, // CRUD de metas + lógica de aportes
    CategoriesDao, // CRUD de categorías personalizadas
  ],
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
    onUpgrade: (Migrator m, int from, int to) async {},
  );

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      ('Comida', '🍔', '#FF6B6B', false),
      ('Transporte', '🚌', '#4ECDC4', false),
      ('Casa', '🏠', '#45B7D1', false),
      ('Salud', '💊', '#96CEB4', false),
      ('Ocio', '🎮', '#FFEAA7', false),
      ('Educación', '📚', '#DDA0DD', false),
      ('Compras', '🛍️', '#F39C12', false),
      ('Servicios', '💡', '#3498DB', false),

      // INGRESOS
      ('Salario', '💼', '#27AE60', true),
      ('Freelance', '💻', '#00B894', true),
      ('Ventas', '🛒', '#0984E3', true),
      ('Regalos', '🎁', '#E84393', true),
      ('Inversiones', '📈', '#6C5CE7', true),
      ('Otros ingresos', '💵', '#F1C40F', true),
    ];
    await into(categoriesTable).insert(
      CategoriesTableCompanion.insert(
        id: const Value(1),
        name: 'Ahorro',
        emoji: Value('💰'),
        colorHex: Value('#2ECC71'),
        isSystem: Value(true),
      ),
    );
    var count = 1;
    for (final (name, emoji, color, isIncome) in defaults) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          name: name,
          emoji: Value(emoji),
          colorHex: Value(color),
          isSystem: Value(false),
          sortOrder: Value(count),
          isIncome: Value(isIncome),
        ),
      );
      count++;
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
