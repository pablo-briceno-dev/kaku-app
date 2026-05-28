import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/accounts_table.dart';
import 'package:kaku/core/database/tables/goals_table.dart';
import 'package:kaku/core/database/tables/transactions_table.dart';
import 'package:kaku/core/models/transaction_type.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [GoalsTable, TransactionsTable, AccountsTable])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  // Stream de metas activas (no completadas), ordenadas por % de progreso desc
  Stream<List<Goal>> watchActiveGoals() =>
      (select(goalsTable)..where((g) => g.isCompleted.equals(false))).watch();

  // Stream de metas completadas (para pantalla de historial / logros)
  Stream<List<Goal>> watchCompletedGoals() =>
      (select(goalsTable)..where((g) => g.isCompleted.equals(true))).watch();

  // Crear nueva meta
  Future<int> insertGoal(GoalsTableCompanion goal) =>
      into(goalsTable).insert(goal);

  // Aportar a una meta: suma el aporte y marca como completada si llega al 100%
  Future<void> contribute({
    required int goalId,
    required int accountId,
    required double amount,
  }) async {
    await transaction(() async {
      // 1. Suma el aporte a la meta
      final goal = await (select(
        goalsTable,
      )..where((g) => g.id.equals(goalId))).getSingle();

      final newSaved = (goal.savedAmount + amount)
          .clamp(0, goal.targetAmount)
          .toDouble();
      final isNowComplete = newSaved >= goal.targetAmount;

      await (update(goalsTable)..where((g) => g.id.equals(goalId))).write(
        GoalsTableCompanion(
          savedAmount: Value(newSaved),
          isCompleted: Value(isNowComplete),
        ),
      );

      // 2. Crear transacción en el historial
      await into(transactionsTable).insert(
        TransactionsTableCompanion.insert(
          amount: amount,
          type: TransactionType.expense.name, // sale de la cuenta
          accountId: accountId,
          goalId: Value(goalId),
          categoryId: const Value(999),
          description: Value('Aporte a meta: ${goal.name}'),
          date: DateTime.now(),
        ),
      );

      // 3. Descuenta del saldo de la cuenta
      final account = await (select(
        accountsTable,
      )..where((a) => a.id.equals(accountId))).getSingle();
      await (update(accountsTable)..where((a) => a.id.equals(accountId))).write(
        AccountsTableCompanion(balance: Value(account.balance - amount)),
      );
    });
  }

  // Eliminar meta
  Future<int> deleteGoal(int id) async {
    return await transaction(() async {
      // 1. Obtener todas las transacciones asociadas a la meta
      final transactions = await (select(
        transactionsTable,
      )..where((t) => t.goalId.equals(id))).get();
      // 2. Eliminar todas las transacciones asociadas a la meta
      // y actualizar el saldo de la cuenta
      for (var transaction in transactions) {
        final account = await (select(
          accountsTable,
        )..where((a) => a.id.equals(transaction.accountId))).getSingle();
        final newBalance = account.balance + transaction.amount;
        await (update(accountsTable)..where((a) => a.id.equals(transaction.accountId))).write(
          AccountsTableCompanion(balance: Value(newBalance)),
        );
        await delete(transactionsTable).delete(transaction);
      }
      
      return (delete(goalsTable)..where((g) => g.id.equals(id))).go();
    });
  }

  // Editar nombre, emoji o monto objetivo
  Future<bool> updateGoal(Goal goal) => update(goalsTable).replace(goal);

  // Stream de metas activas y completadas (para pantalla de historial / logros)
  Stream<List<Goal>> watchAllGoals() => (select(goalsTable)).watch();
}
