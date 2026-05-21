import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/accounts_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [AccountsTable])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  // Stream de cuentas activas - se actualiza al crear/editar/archivar
  Stream<List<Account>> watchActiveAccounts() =>
      (select(accountsTable)..where((a) => a.isActive.equals(true))).watch();

  // Balance total consolidado de todas las cuentas activas
  Stream<double> watchTotalBalance() {
    final sum = accountsTable.balance.sum();
    return (selectOnly(accountsTable)
          ..addColumns([sum])
          ..where(accountsTable.isActive.equals(true)))
        .watchSingleOrNull()
        .map((row) => row?.read(sum) ?? 0.0);
  }

  // Obtener una cuenta por ID (para mostrar detalle)
  Stream<Account?> watchAccountById(int id) => (select(
    accountsTable,
  )..where((a) => a.id.equals(id))).watchSingleOrNull();

  // Insertar cuenta nueva
  Future<int> insertAccount(AccountsTableCompanion account) =>
      into(accountsTable).insert(account);

  // Actualizar (nombre, color, tipo, etc)
  Future<bool> updateAccount(Account account) =>
      update(accountsTable).replace(account);

  // Actualizar solo el balance (se llama después de cada transacción)
  Future<void> updateBalance(int accountId, double newBalance) =>
      (update(accountsTable)..where((a) => a.id.equals(accountId))).write(
        AccountsTableCompanion(balance: Value(newBalance)),
      );

  // Archivar cuenta (no eliminar si tiene transacciones)
  Future<void> archiveAccount(int id) =>
      (update(accountsTable)..where((a) => a.id.equals(id))).write(
        const AccountsTableCompanion(isActive: Value(false)),
      );
}
