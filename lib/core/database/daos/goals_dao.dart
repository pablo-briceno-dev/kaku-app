import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/goals_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [GoalsTable])
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
  Future<void> contribute(int goalId, double amount) async {
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
  }

  // Eliminar meta
  Future<int> deleteGoal(int id) => (delete(goalsTable)..where((g) => g.id.equals(id))).go();

  // Editar nombre, emoji o monto objetivo
  Future<bool> updateGoal(Goal goal) => update(goalsTable).replace(goal);
}
