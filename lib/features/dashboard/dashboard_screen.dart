import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/models/budget_progress.dart';
import 'package:kaku/features/dashboard/budget_bar.dart';
import 'package:kaku/features/dashboard/card_balance.dart';
import 'package:kaku/features/dashboard/month_navigator.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/profile_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final budgetProgress =
        ref.watch(budgetProgressProvider(selectedMonth)).value ??
        [
          BudgetProgress(
            budget: Budget(
              id: 0,
              categoryId: 1,
              limitAmount: 1000,
              month: 05,
              year: 2026,
              rollover: false,
            ),
            category: Category(
              id: 1,
              name: 'test',
              emoji: '🍔',
              colorHex: '#FF6B6B',
              isDefault: true,
              isIncome: false,
            ),
            spent: 0.0,
          ),
        ];

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Hola, ${profile.displayName} 👋',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonthNavigator(),
            const SizedBox(height: 16),
            // Tarjeta de balance
            CardBalance(),
            const SizedBox(height: 16),
            BudgetBar(
              emoji: '💰',
              title: 'Saldo disponible',
              progress: 0.72,
              status: BudgetStatus.ok,
            ),
          ],
        ),
      ),
    );
  }
}
