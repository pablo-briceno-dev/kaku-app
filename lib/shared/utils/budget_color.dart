import 'package:flutter/material.dart';
import 'package:kaku/core/models/budget_progress.dart';

Color getBudgetColorForStatus(BudgetStatus status, ColorScheme cs) {
  return switch (status) {
    BudgetStatus.ok => cs.primary,
    BudgetStatus.warning => Colors.amber,
    BudgetStatus.overBudget => cs.error,
  };
}
