import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/personal/goals/goal_form_sheet.dart';
import 'package:kaku/features/personal/goals/goals_list.dart';
import 'package:kaku/features/personal/goals/widgets/goals_list_skeleton.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';

class GoalsView extends ConsumerStatefulWidget {
  const GoalsView({super.key});

  @override
  ConsumerState<GoalsView> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allGoalsAsync = ref.watch(allGoalsProvider);
    final activeGoalsAsync = ref.watch(activeGoalsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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
              title: l10n.newGoalTitle,
              useRootNavigator: true,
              isFullScreen: true,
              child: GoalFormSheet(defaultName: l10n.newGoalTitle),
            );
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: allGoalsAsync.when(
            loading: () => GoalsListSkeleton(),
            error: (e, _) => const SizedBox.shrink(),
            data: (goals) {
              if (goals.isEmpty) {
                return ContentWidgetEmpty(
                  title: '🎯',
                  message: l10n.goalsNoActive,
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
