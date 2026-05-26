import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/transactions/accounts_bottom_sheet.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';

class SelectedAccountGoal extends ConsumerWidget {
  const SelectedAccountGoal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selectedAccount = ref.watch(selectedAccountProvider);
    final activeAccounts = ref.watch(activeAccountsProvider).value;
    final account = activeAccounts?.length == 1
        ? activeAccounts![0]
        : activeAccounts
              ?.where((e) => selectedAccount != null && e.id == selectedAccount)
              .firstOrNull;

    return InkWell(
      onTap: activeAccounts?.length == 1
          ? null
          : () => AppBottomSheet.show(
              context,
              title: 'Cuentas',
              isFullScreen: true,
              child: AccountsBottomSheet(),
            ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.credit_card_rounded,
              size: 25,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              account?.name ?? 'Cuenta',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
