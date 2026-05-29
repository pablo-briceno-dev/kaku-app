import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/features/transactions/horizontal_chips_categories.dart';
import 'package:kaku/features/transactions/selected_account.dart';
import 'package:kaku/features/transactions/widgets/toggle_app_bar.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/date_picker_field.dart';
import 'package:kaku/shared/widgets/receipt_picker.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int? accountId;

  const AddTransactionScreen({super.key, this.accountId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = CurrencyFormatter.format(
      0,
      ref.read(currencyProvider),
    );
  }

  bool _validatedButton(
    double amount,
    double accountBalance,
    TransactionType type,
    int? selectedAccount,
  ) {
    if (amount == 0) {
      debugPrint('amount == 0');
      return true;
    }
    if (selectedAccount == null) {
      debugPrint('selectedAccount == null');
      return true;
    }
    if (type == TransactionType.expense && amount > accountBalance) {
      debugPrint('type == TransactionType.expense && amount < accountBalance');
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final currency = ref.watch(currencyProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedType = ref.watch(addTransactionTypeProvider);
    final selectedAccount = ref.watch(selectedAccountProvider);
    final activeAccountsAsync = ref.watch(activeAccountsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Nueva transacción'),
        defaultActions: false,
        actions: [ToggleAppBar()],
      ),
      body: activeAccountsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => const SizedBox.shrink(),
        data: (activeAccounts) {
          if (activeAccounts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: ContentWidgetEmpty(
                  title: '🏧​',
                  message:
                      'Registra al menos una cuenta para poder crear transacciones',
                ),
              ),
            );
          }
          final account = activeAccounts
              .where(
                (ac) => selectedAccount != null && ac.id == selectedAccount,
              )
              .firstOrNull;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [CurrencyFormatter.inputFormatter(currency)],
                  decoration: InputDecoration(
                    labelText: 'MONTO · ${currency.label}',
                    hintText: r'$0',
                    labelStyle: ts.titleLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  style: TextStyle(fontSize: 45),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: cs.outline),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATEGORÍA',
                        style: ts.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      HorizontalChipsCategories(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textAlign: TextAlign.start,
                  maxLength: 100,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'DESCRIPCIÓN'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DatePickerField(
                        selectedDate: _selectedDate,
                        onChanged: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: SelectedAccount()),
                  ],
                ),
                const SizedBox(height: 16),
                ReceiptPicker(
                  initialPath: _receiptPath,
                  onChanged: (path) => setState(() => _receiptPath = path),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _validatedButton(
                          CurrencyFormatter.parse(
                            _amountController.text,
                            currency,
                          ),
                          account?.balance ?? 0.0,
                          selectedType,
                          selectedAccount,
                        )
                        ? null
                        : () async {
                            final dao = ref.read(transactionsDaoProvider);
                            await dao.insertTransaction(
                              TransactionsTableCompanion.insert(
                                type: selectedType.name,
                                amount: CurrencyFormatter.parse(
                                  _amountController.text,
                                  currency,
                                ),
                                description: drift.Value(
                                  _descriptionController.text,
                                ),
                                categoryId: drift.Value(selectedCategory),
                                accountId: selectedAccount!,
                                receiptPath: drift.Value(_receiptPath),
                                date: _selectedDate,
                              ),
                            );
                            final accountDao = ref.read(accountsDaoProvider);
                            await accountDao.updateBalance(
                              account!.id,
                              account.balance +
                                  BudgetCalculator.balanceDelta(
                                    selectedType,
                                    CurrencyFormatter.parse(
                                      _amountController.text,
                                      currency,
                                    ),
                                  ),
                            );

                            if (context.mounted) {
                              AppSnackbar.success(
                                context,
                                '${selectedType.label} guardado',
                              );
                              Navigator.pop(context);
                            }
                          },
                    child: Text('Guardar ${selectedType.label}'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
