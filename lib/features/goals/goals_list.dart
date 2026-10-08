import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/features/goals/contribute_goal_sheet.dart';
import 'package:kaku/features/goals/goal_form_sheet.dart';
import 'package:kaku/features/goals/widgets/card_goal.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/utils/undo_delete.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';

class GoalsListConfig {
  final int id;
  final String emoji;
  final String name;
  final DateTime? deadline;
  final bool isCompleted;
  final double targetAmount;
  final double savedAmount;
  final String type;
  final DateTime createdAt;

  const GoalsListConfig({
    required this.id,
    required this.emoji,
    required this.name,
    this.deadline,
    required this.isCompleted,
    required this.targetAmount,
    required this.savedAmount,
    required this.type,
    required this.createdAt,
  });
}

class GoalsList extends ConsumerWidget {
  final List<GoalsListConfig> goals;

  const GoalsList({super.key, required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthOneTransactions = ref
        .watch(
          monthTransactionsProvider((
            month: selectedMonth.month,
            year: selectedMonth.year,
          )),
        )
        .value;
    final monthTwoTransactions = ref
        .watch(
          monthTransactionsProvider((
            month: selectedMonth.month - 1,
            year: selectedMonth.year,
          )),
        )
        .value;
    final monthThreeTransactions = ref
        .watch(
          monthTransactionsProvider((
            month: selectedMonth.month - 2,
            year: selectedMonth.year,
          )),
        )
        .value;
    final List<double> monthlySurpluses = [
      ...?monthOneTransactions?.map((tx) {
        if (tx.transaction.type == TransactionType.expense.name) {
          return -tx.transaction.amount;
        }
        return tx.transaction.amount;
      }),
      ...?monthTwoTransactions?.map((tx) {
        if (tx.transaction.type == TransactionType.expense.name) {
          return -tx.transaction.amount;
        }
        return tx.transaction.amount;
      }),
      ...?monthThreeTransactions?.map((tx) {
        if (tx.transaction.type == TransactionType.expense.name) {
          return -tx.transaction.amount;
        }
        return tx.transaction.amount;
      }),
    ];
    final avgMonthlySavings = BudgetCalculator.avgMonthlySavings(
      monthlySurpluses,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: goals.map((goal) {
        final goalRemaining = BudgetCalculator.goalRemaining(
          goal.savedAmount,
          goal.targetAmount,
        );
        return Column(
          children: [
            CardGoal(
              emoji: goal.emoji,
              name: goal.name,
              targetAmount: CurrencyFormatter.compact(
                goal.targetAmount,
                currency,
              ),
              savedAmount: CurrencyFormatter.compact(
                goal.savedAmount,
                currency,
              ),
              progress: (goal.savedAmount / goal.targetAmount) * 100,
              estimate: (goal.savedAmount / goal.targetAmount) * 100 == 100
                  ? l10n.goalComplete
                  : BudgetCalculator.getEstimatedSavingTime(
                      context,
                      goalRemaining,
                      avgMonthlySavings,
                      deadline: goal.deadline,
                    ),
              onTap: () => AppBottomSheet.show(
                context,
                title: l10n.goalEditTitle(name: goal.name),
                useRootNavigator: true,
                isFullScreen: true,
                child: GoalFormSheet(
                  goal: goal,
                  defaultName: l10n.newGoalTitle,
                ),
              ),
              onContribute: () => AppBottomSheet.show(
                context,
                title: l10n.contributeGoal,
                useRootNavigator: true,
                isFullScreen: true,
                child: ContributeGoalSheet(
                  goalId: goal.id,
                  targetAmount: goal.targetAmount,
                  savedAmount: goal.savedAmount,
                  emoji: goal.emoji,
                  name: goal.name,
                ),
              ),
              onDelete: () => showUndoDelete(
                context: context,
                label: l10n.goalDeleting,
                onDelete: () => _onDelete(ref, goal),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _onDelete(WidgetRef ref, GoalsListConfig goal) async {
    await ref.read(goalsDaoProvider).deleteGoal(goal.id);
  }
}
