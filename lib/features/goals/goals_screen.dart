import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/goals/goal_form_sheet.dart';
import 'package:kaku/features/goals/goals_list.dart';
import 'package:kaku/features/goals/widgets/goals_list_skeleton.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsActiveAsync = ref.watch(activeGoalsProvider);

    return goalsActiveAsync.when(
      loading: () => Scaffold(
        appBar: CustomAppBar(
          title: Text('Metas'),
          defaultActions: true,
          actions: [
            TextButton.icon(
              onPressed: () => AppBottomSheet.show(
                context,
                title: 'Nueva Meta',
                useRootNavigator: true,
                isFullScreen: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GoalFormSheet(),
                      SizedBox(
                        height: MediaQuery.of(context).viewPadding.bottom + 30,
                      ),
                    ],
                  ),
                ),
              ),
              icon: Icon(Icons.add),
              label: Text('Nueva'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GoalsListSkeleton(),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (goals) {
        if (goals.isEmpty) {
          return Scaffold(
            appBar: CustomAppBar(
              title: Text('Metas'),
              defaultActions: true,
              actions: [
                TextButton.icon(
                  onPressed: () => AppBottomSheet.show(
                    context,
                    title: 'Nueva Meta',
                    useRootNavigator: true,
                    isFullScreen: true,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GoalFormSheet(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewPadding.bottom + 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  icon: Icon(Icons.add),
                  label: Text('Nueva'),
                ),
              ],
            ),
            body: const ContentWidgetEmpty(
              title: '🎯',
              message: 'Sin metas activas',
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: Text('Metas'),
            defaultActions: true,
            actions: [
              TextButton.icon(
                onPressed: () => AppBottomSheet.show(
                  context,
                  title: 'Nueva Meta',
                  useRootNavigator: true,
                  isFullScreen: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GoalFormSheet(),
                        SizedBox(
                          height:
                              MediaQuery.of(context).viewPadding.bottom + 30,
                        ),
                      ],
                    ),
                  ),
                ),
                icon: Icon(Icons.add),
                label: Text('Nueva'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: GoalsList(
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
              ),
            ),
          ),
        );
      },
    );
  }
}
