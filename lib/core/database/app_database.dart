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
import 'package:kaku/core/l10n/default_category.dart';
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
  int get schemaVersion => 4;

  // Aquí irán las migraciones cuando actualice el schema
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultCategories(); // categorías por defecto
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1 && to == 2) {
        // Agregar columna transferId a la tabla de transacciones
        await m.addColumn(transactionsTable, transactionsTable.transferId);
      }
      if (from == 2 && to == 3) {
        await m.addColumn(transactionsTable, transactionsTable.unitPrice);
        await m.addColumn(transactionsTable, transactionsTable.quantity);

        await customStatement(
          'UPDATE transactions_table SET unit_price = amount WHERE unit_price = 0;',
        );
      }
      if (from == 3 && to == 4) {
        await m.addColumn(categoriesTable, categoriesTable.systemKey);
        const nameToKey = [
          ('Ahorro', 'savings'),
          ('Comida', 'food'),
          ('Transporte', 'transport'),
          ('Casa', 'home'),
          ('Salud', 'health'),
          ('Ocio', 'leisure'),
          ('Educación', 'education'),
          ('Compras', 'shopping'),
          ('Servicios', 'services'),
          ('Salario', 'salary'),
          ('Freelance', 'freelance'),
          ('Ventas', 'sales'),
          ('Regalos', 'gifts'),
          ('Inversiones', 'investments'),
          ('Otros ingresos', 'otherIncome'),
        ];
        var count = 1;
        for (final (name, key) in nameToKey) {
          await customStatement(
            'UPDATE categories_table SET system_key = ?  WHERE id = ?',
            [key, count],
          );
          count++;
        }
      }
    },
  );

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      (DefaultCategory.food, 'Comida', '🍔', '#FF6B6B', false),
      (DefaultCategory.transport, 'Transporte', '🚌', '#4ECDC4', false),
      (DefaultCategory.home, 'Casa', '🏠', '#45B7D1', false),
      (DefaultCategory.health, 'Salud', '💊', '#96CEB4', false),
      (DefaultCategory.leisure, 'Ocio', '🎮', '#FFEAA7', false),
      (DefaultCategory.education, 'Educación', '📚', '#DDA0DD', false),
      (DefaultCategory.shopping, 'Compras', '🛍️', '#F39C12', false),
      (DefaultCategory.services, 'Servicios', '💡', '#3498DB', false),

      // INGRESOS
      (DefaultCategory.salary, 'Salario', '💼', '#27AE60', true),
      (DefaultCategory.freelance, 'Freelance', '💻', '#00B894', true),
      (DefaultCategory.sales, 'Ventas', '🛒', '#0984E3', true),
      (DefaultCategory.gifts, 'Regalos', '🎁', '#E84393', true),
      (DefaultCategory.investments, 'Inversiones', '📈', '#6C5CE7', true),
      (DefaultCategory.otherIncome, 'Otros ingresos', '💵', '#F1C40F', true),
    ];
    await into(categoriesTable).insert(
      CategoriesTableCompanion.insert(
        id: const Value(1),
        name: 'Ahorro',
        emoji: Value('💰'),
        colorHex: Value('#2ECC71'),
        isSystem: Value(true),
        systemKey: Value(DefaultCategory.savings.name),
      ),
    );
    var count = 1;
    for (final (key, name, emoji, color, isIncome) in defaults) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          name: name,
          systemKey: Value(key.name),
          emoji: Value(emoji),
          colorHex: Value(color),
          isSystem: Value(true),
          sortOrder: Value(count),
          isIncome: Value(isIncome),
        ),
      );
      count++;
    }
  }

  Future<void> deleteEverything() async {
    await transaction(() async {
      // Orden importante: primero las tablas con foreign keys
      await delete(transactionsTable).go();
      await delete(budgetsTable).go();
      await delete(goalsTable).go();
      await delete(accountsTable).go();
      // Las categorías del sistema (id=999) se recrean al iniciar
      await delete(categoriesTable).go();

      await _seedDefaultCategories();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kaku_app.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}
