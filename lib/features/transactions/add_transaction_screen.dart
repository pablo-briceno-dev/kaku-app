import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/features/transactions/widgets/toggle_app_bar.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int? accountId;

  const AddTransactionScreen({super.key, this.accountId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final controllers = <String, TextEditingController>{
    'amount': TextEditingController(),
    'type': TextEditingController(),
    'description': TextEditingController(),
    'date': TextEditingController(),
    'accountId': TextEditingController(),
    'categoryId': TextEditingController(),
    'receiptPath': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    controllers['amount']?.text = CurrencyFormatter.format(
      100,
      ref.read(currencyProvider),
    );
    controllers['type']?.text = 'expense';
    controllers['description']?.text = '';
    controllers['date']?.text = DateFormatter.fullDateTime(DateTime.now());
    controllers['accountId']?.text = widget.accountId?.toString() ?? '';

    // controllers['amount']?.addListener(_refresh);
    // controllers['type']?.addListener(_refresh);
    // controllers['description']?.addListener(_refresh);
    // controllers['date']?.addListener(_refresh);
    // controllers['accountId']?.addListener(_refresh);
    // controllers['categoryId']?.addListener(_refresh);
    // controllers['receiptPath']?.addListener(_refresh);
  }

  // void _refresh() {
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  controller: controllers['amount'],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
                  decoration: const InputDecoration(hintText: r'$0'),
                  style: TextStyle(fontSize: 45),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 2),
            const SizedBox(height: 16),
            Text(
              'CATEGORÍA',
              style: ts.titleMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
