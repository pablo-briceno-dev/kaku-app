import 'package:flutter/material.dart';
import 'package:kaku/features/accounts/account_form_sheet.dart';
import 'package:kaku/features/accounts/accounts_list.dart';
import 'package:kaku/features/accounts/card_balance_accounts.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(l10n.myAccounts),
        defaultActions: true,
        actions: [
          TextButton.icon(
            onPressed: () => AppBottomSheet.show(
              context,
              title: l10n.accountNew,
              useRootNavigator: true,
              isFullScreen: true,
              child: AccountFormSheet(),
            ),
            icon: Icon(Icons.add),
            label: Text(l10n.btnNew(femenine: true)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
