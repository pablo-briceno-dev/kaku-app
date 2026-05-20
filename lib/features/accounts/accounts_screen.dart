import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/accounts/card_balance_accounts.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Mis Cuentas'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.newAccount),
            icon: Icon(Icons.add),
            label: Text('Nueva'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [CardBalanceAccounts()]),
      ),
    );
  }
}
