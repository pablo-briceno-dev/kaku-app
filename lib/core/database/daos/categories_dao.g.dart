// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $AccountsTableTable get accountsTable => attachedDatabase.accountsTable;
  $GoalsTableTable get goalsTable => attachedDatabase.goalsTable;
  $TransactionsTableTable get transactionsTable =>
      attachedDatabase.transactionsTable;
  CategoriesDaoManager get managers => CategoriesDaoManager(this);
}

class CategoriesDaoManager {
  final _$CategoriesDaoMixin _db;
  CategoriesDaoManager(this._db);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$AccountsTableTableTableManager get accountsTable =>
      $$AccountsTableTableTableManager(_db.attachedDatabase, _db.accountsTable);
  $$GoalsTableTableTableManager get goalsTable =>
      $$GoalsTableTableTableManager(_db.attachedDatabase, _db.goalsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(
        _db.attachedDatabase,
        _db.transactionsTable,
      );
}
