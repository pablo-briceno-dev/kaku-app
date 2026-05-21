import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/features/transactions/widgets/toggle_app_bar.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class AddTransactionScreen extends ConsumerWidget {
  final int? accountId;

  const AddTransactionScreen({super.key, this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Nueva transacción'),
        defaultActions: false,
        actions: [ToggleAppBar()],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'MONTO · COP',
                  style: ts.titleLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: TextEditingController(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
                  decoration: const InputDecoration(
                    labelText: 'Saldo Inicial*',
                    hintText: r'$0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Expanded(child: AccountsList()),
          ],
        ),
      ),
    );
  }
}
