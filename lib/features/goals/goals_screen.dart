import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/goals/goal_form_sheet.dart';
import 'package:kaku/features/goals/goals_list.dart';
import 'package:kaku/features/goals/widgets/goals_list_skeleton.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final allGoalsAsync = ref.watch(allGoalsProvider);
    final activeGoalsAsync = ref.watch(activeGoalsProvider);
    final completedGoalsAsync = ref.watch(completedGoalsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metas'),
            Row(
              children: [
                activeGoalsAsync.when(
                  data: (activeGoal) => Text(
                    '${activeGoal.length} activas · ',
                    style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  error: (e, _) => Text(
                    '0 activas · ',
                    style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  loading: () => Text(
                    'Cargando...',
                    style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                completedGoalsAsync.when(
                  data: (completedGoal) => Text(
                    '${completedGoal.length} completadas',
                    style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  error: (e, _) => Text(
                    '0 completadas',
                    style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  loading: () => Text(
                    'Cargando...',
                    style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
        defaultActions: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final blocked = await PremiumLimitChecker.check(
                context: context,
                feature: PremiumFeature.unlimitedGoals,
                currentCount: activeGoalsAsync.when(
                  data: (goals) => goals.length,
                  error: (e, _) => 0,
                  loading: () => 0,
                ),
                limit: PremiumLimits.maxGoals,
              );
              if (blocked) return;

              if (context.mounted) {
                AppBottomSheet.show(
                  context,
                  title: 'Nueva Meta',
                  useRootNavigator: true,
                  isFullScreen: true,
                  child: GoalFormSheet(),
                );
              }
            },
            icon: Icon(Icons.add),
            label: Text('Nueva'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: allGoalsAsync.when(
            loading: () => GoalsListSkeleton(),
            error: (e, _) => const SizedBox.shrink(),
            data: (goals) {
              if (goals.isEmpty) {
                return const ContentWidgetEmpty(
                  title: '🎯',
                  message: 'Sin metas activas',
                );
              }
              return GoalsList(
                goals: goals
                    .map(
                      (goal) => GoalsListConfig(
                        id: goal.id,
                        emoji: goal.emoji,
                        name: goal.name,
                        isCompleted: goal.isCompleted,
                        targetAmount: goal.targetAmount,
                        savedAmount: goal.savedAmount,
                        type: goal.type,
                        deadline: goal.deadline,
                        createdAt: goal.createdAt,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
