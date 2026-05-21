import 'package:flutter/material.dart';
import 'package:kaku/features/accounts/account_form_sheet.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class AccountDetailScreen extends StatelessWidget {
  final int id;

  const AccountDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Detalle de Cuenta'),
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
      body: Center(child: Text('AccountDetailScreen')),
    );
  }
}
