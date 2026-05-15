import 'package:drift/drift.dart';
import 'package:kaku/core/database/app_database.dart';

part 'goals_dao.g.dart';

class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);
}
