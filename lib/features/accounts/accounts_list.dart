import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/colors_plates.dart';
import 'package:kaku/core/models/account_type.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/shared/widgets/card_account_item.dart';
import 'package:kaku/features/accounts/widgets/account_skeleton.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';

class AccountsList extends ConsumerWidget {
  const AccountsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final activeAccountsAsync = ref.watch(activeAccountsProvider);

    return activeAccountsAsync.when(
      loading: () => SizedBox(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: 3,
          itemBuilder: (context, _) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: AccountSkeleton(),
          ),
        ),
      ),
      error: (_, __) => SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Error al cargar las cuentas',
            style: TextStyle(fontSize: 12, color: cs.error),
          ),
        ),
      ),
      data: (accounts) {
        if (accounts.isEmpty) {
          return const ContentWidgetEmpty(
            title: '💸​',
            message: 'Sin cuentas creadas',
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final accountData = accounts[index];
              return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CardAccountItem(
                      emoji: accountData.icon,
                      name: accountData.name,
                      type: AccountType.values[accountData.type],
                      color: hexToColor(accountData.colorHex),
                      balance: accountData.balance,
                      currencyType: CurrencyType.values.firstWhere(
                        (e) => e.label == accountData.currency,
                      ),
                      onTap: () => context.push(
                        AppRoutes.toAccountDetail(accountData.id),
                      ),
                      onLongPressStart: (details) async {
                        final result = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                          ),
                          items: [
                            const PopupMenuItem(
                              value: 'view-detail',
                              child: Text('Ver detalle'),
                            ),
                            const PopupMenuItem(
                              value: 'archive',
                              child: Text('Archivar o Inactivar'),
                            ),
                          ],
                        );

                        switch (result) {
                          case 'view-detail':
                            if (context.mounted) {
                              context.push(
                                AppRoutes.toAccountDetail(accountData.id),
                              );
                            }
                            break;
                          case 'archive':
                            final dao = ref.read(accountsDaoProvider);
                            dao.archiveAccount(accountData.id);
                            break;
                        }
                      },
                    ),
                  )
                  .animate(delay: Duration(milliseconds: index * 50))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.04, end: 0, duration: 300.ms);
            },
          ),
        );
      },
    );
  }
}
