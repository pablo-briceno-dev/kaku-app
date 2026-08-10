import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/dashboard/card_balance_dashboard.dart';
import 'package:kaku/features/dashboard/horizontal_progress_bars.dart';
import 'package:kaku/features/dashboard/month_navigator.dart';
import 'package:kaku/features/dashboard/projection_banner.dart';
import 'package:kaku/features/dashboard/transactions_list.dart';
import 'package:kaku/shared/providers/profile_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:upgrader/upgrader.dart';

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

    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(seconds: 10),
        debugLogging: true,
        debugDisplayAlways: true,
      ),
      child: Scaffold(
        appBar: CustomAppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName == "Usuario"
                    ? 'Bienvenido a Kaku 👋'
                    : 'Hola, ${profile.displayName} 👋',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tu bolsillo, bajo control',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          defaultActions: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonthNavigator(),
              const SizedBox(height: 16),
              CardBalanceDashboard(), // Tarjeta de balance
              const SizedBox(height: 16),
              HorizontalProgressBars(), // Barras de progreso horizontales
              const SizedBox(height: 16),
              ProjectionBanner(),
              const SizedBox(height: 16),
              TransactionsList(),
            ],
          ),
        ),
      ),
    );
  }
}
