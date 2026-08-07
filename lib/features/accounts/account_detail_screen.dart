import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/accounts/account_form_sheet.dart';
import 'package:kaku/features/accounts/card_account_detail.dart';
import 'package:kaku/features/accounts/history_account_detail.dart';
import 'package:kaku/features/accounts/widgets/account_detail_skeleton.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class AccountDetailScreen extends ConsumerWidget {
  final int id;

  const AccountDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountByIdProvider(id));

    return account.when(
      loading: () => const AccountDetailSkeleton(),
      error: (e, _) => const SizedBox.shrink(),
      data: (account) {
        if (account == null) {
          return Scaffold(
            appBar: CustomAppBar(title: Text('Detalle de la cuenta')),
            body: ContentWidgetEmpty(
              title: '💸​',
              message: 'Cuenta no encontrada',
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: Text(account.name),
            defaultActions: false,
            actions: [
              TextButton.icon(
                onPressed: () => AppBottomSheet.show(
                  context,
                  title: 'Editar',
                  isFullScreen: true,
                  useRootNavigator: true,
                  child: AccountFormSheet(account: account),
                ),
                icon: Icon(Icons.edit),
                label: Text('Editar'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                CardAccountDetail(account: account),
                const SizedBox(height: 16),
                HistoryAccountDetail(account: account),
              ],
            ),
          ),
        );
      },
    );
  }
}
