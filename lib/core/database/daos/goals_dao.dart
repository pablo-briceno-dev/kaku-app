import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/database/tables/goals_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [GoalsTable])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  // Stream de metas activas (no completadas), ordenadas por % de progreso desc
  Stream<List<Goal>> watchActiveGoals() =>
      (select(goalsTable)..where((g) => g.isCompleted.equals(true))).watch();
}
