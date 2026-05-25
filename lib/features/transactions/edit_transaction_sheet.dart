import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/features/transactions/horizontal_chips_categories.dart';
import 'package:kaku/features/transactions/selected_account.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/date_picker_field.dart';
import 'package:kaku/shared/widgets/receipt_picker.dart';

class EditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _receiptPath = widget.transaction.receiptPath;
    _amountController.text = CurrencyFormatter.format(
      widget.transaction.amount,
      ref.read(currencyProvider),
    );
    _descriptionController.text = widget.transaction.description ?? '';
    _selectedDate = widget.transaction.date;

    _amountController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _validatedButton(
    int? selectedAccount,
    int? selectedCategory,
    double amount,
    double accountBalance,
  ) {
    if (amount != 0 &&
        widget.transaction.amount != amount &&
        amount <= accountBalance) {
      return false;
    } else if (widget.transaction.categoryId != selectedCategory) {
      return false;
    } else if (widget.transaction.description != _descriptionController.text) {
      return false;
    } else if (!isSameDate(widget.transaction.date, _selectedDate)) {
      return false;
    } else if (widget.transaction.accountId != selectedAccount) {
      return false;
    } else if (widget.transaction.receiptPath != _receiptPath) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final currency = ref.watch(currencyProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final transactionTypeSelected = ref.watch(addTransactionTypeProvider);
    final selectedAccount = ref.watch(selectedAccountProvider);
    final activeAccountsAsync = ref.watch(activeAccountsProvider);

    return activeAccountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (activeAccounts) {
        if (activeAccounts.isEmpty) {
          return Center(
            child: Text(
              'No tienes ninguna cuenta activa. Registra al menos una cuenta para poder crear transacciones.',
              style: ts.bodyLarge?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          );
        }
        final account = activeAccounts
            .where((ac) => selectedAccount != null && ac.id == selectedAccount)
            .firstOrNull;

        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CurrencyFormatter.inputFormatter(currency),
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        if (CurrencyFormatter.parse(value) > account!.balance) {
                          return 'No tienes suficiente saldo';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'MONTO · ${currency.label}',
                        // hintText: r'$0',
                        labelStyle: ts.titleLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 45,
                        color: transactionTypeSelected.color,
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'DESCRIPCIÓN',
                      ),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _validatedButton(
                              selectedAccount,
                              selectedCategory,
                              CurrencyFormatter.parse(_amountController.text),
                              account?.balance ?? 0.0,
                            )
                            ? null
                            : () async {
                                final accountsDao = ref.read(
                                  accountsDaoProvider,
                                );
                                final transactionsDao = ref.read(
                                  transactionsDaoProvider,
                                );
                                final differenceAmount =
                                    CurrencyFormatter.parse(
                                      _amountController.text,
                                    ) -
                                    widget.transaction.amount;
                                if (widget.transaction.accountId !=
                                    selectedAccount) {
                                  final newAccount = activeAccounts
                                      .where(
                                        (ac) =>
                                            selectedAccount != null &&
                                            ac.id == selectedAccount,
                                      )
                                      .firstOrNull;
                                  accountsDao.updateBalance(
                                    account!.id,
                                    account.balance +
                                        (BudgetCalculator.balanceDelta(
                                              transactionTypeSelected,
                                              CurrencyFormatter.parse(
                                                _amountController.text,
                                              ),
                                            ) *
                                            -1),
                                  );
                                  accountsDao.updateBalance(
                                    newAccount!.id,
                                    newAccount.balance +
                                        BudgetCalculator.balanceDelta(
                                          transactionTypeSelected,
                                          CurrencyFormatter.parse(
                                            _amountController.text,
                                          ),
                                        ),
                                  );
                                } else {
                                  final newBalanceDelta =
                                      account!.balance +
                                      BudgetCalculator.balanceDelta(
                                        transactionTypeSelected,
                                        differenceAmount,
                                      );
                                  accountsDao.updateBalance(
                                    account.id,
                                    newBalanceDelta,
                                  );
                                }
                                await transactionsDao.updateTransaction(
                                  Transaction(
                                    id: widget.transaction.id,
                                    amount: CurrencyFormatter.parse(
                                      _amountController.text,
                                    ),
                                    description: _descriptionController.text,
                                    type: widget.transaction.type,
                                    date: _selectedDate,
                                    accountId: selectedAccount!,
                                    isRecurring: widget.transaction.isRecurring,
                                    createdAt: widget.transaction.createdAt,
                                    receiptPath: _receiptPath,
                                    categoryId: selectedCategory,
                                  ),
                                );
                                if (context.mounted) {
                                  AppSnackbar.success(
                                    context,
                                    'Cambios guardados',
                                  );
                                  Navigator.pop(context);
                                }
                              },
                        child: const Text('Guardar cambios'),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
