import 'package:flutter/material.dart';
import 'package:kaku/features/accounts/account_form_sheet.dart';
import 'package:kaku/features/accounts/accounts_list.dart';
import 'package:kaku/features/accounts/card_balance_accounts.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Mis Cuentas'),
        defaultActions: true,
        actions: [
          TextButton.icon(
            onPressed: () => AppBottomSheet.show(
              context,
              title: 'Nueva Cuenta',
              isFullScreen: true,
              child: SingleChildScrollView(child: AccountFormSheet()),
            ),
            icon: Icon(Icons.add),
            label: Text('Nueva'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CardBalanceAccounts(),
            const SizedBox(height: 16),
            Expanded(child: AccountsList()),
          ],
        ),
      ),
    );
  }
}
