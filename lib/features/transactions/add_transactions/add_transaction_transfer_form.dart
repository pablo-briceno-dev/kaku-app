import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/features/transactions/selected_account.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/date_picker_field.dart';

class AddTransactionTransferForm extends ConsumerStatefulWidget {
  const AddTransactionTransferForm({super.key});

  @override
  ConsumerState<AddTransactionTransferForm> createState() =>
      _AddTransactionTransferFormState();
}

class _AddTransactionTransferFormState
    extends ConsumerState<AddTransactionTransferForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _toAccountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final currency = ref.watch(currencyProvider);
    final selectedType = ref.watch(addTransactionTypeProvider);
    final fromAccount = ref.watch(selectedAccountProvider);
    final activeAccountsAsync = ref.watch(activeAccountsProvider);

    return activeAccountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (activeAccounts) {
        if (activeAccounts.isEmpty || activeAccounts.length < 2) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: ContentWidgetEmpty(
                title: '🏧​',
                message:
                    'Registra al menos dos cuentas para poder crear transferencias',
              ),
            ),
          );
        }

        final sourceAccount = activeAccounts
            .where((ac) => fromAccount != null && ac.id == fromAccount)
            .firstOrNull;
        final destinationAccount = activeAccounts
            .where(
              (ac) =>
                  _toAccountController.text.isNotEmpty &&
                  ac.id == int.tryParse(_toAccountController.text),
            )
            .firstOrNull;

        return Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                        inputFormatters: [
                          CurrencyFormatter.inputFormatter(currency),
                        ],
                        decoration: InputDecoration(
                          labelText: 'MONTO · ${currency.label}',
                          hintText: r'$0',
                          labelStyle: ts.titleLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo requerido';
                          }
                          if (CurrencyFormatter.parse(value, currency) <= 0) {
                            return 'Debe ser mayor a 0';
                          }
                          if (CurrencyFormatter.parse(value, currency) >
                              (sourceAccount?.balance ?? 0.0)) {
                            return 'Saldo insuficiente';
                          }
                          return null;
                        },
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
                              'CUENTA DESTINO',
                              style: ts.titleMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FormField<int>(
                              validator: (_) {
                                if (_toAccountController.text.isEmpty) {
                                  return 'Seleccione una cuenta destino';
                                }
                                if (int.tryParse(_toAccountController.text) ==
                                    fromAccount) {
                                  return 'La cuenta destino no debe ser igual a la cuenta origen';
                                }
                                return null;
                              },
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectedAccount(
                                      accountId: int.tryParse(
                                        _toAccountController.text,
                                      ),
                                      onTap: (accountId) {
                                        _toAccountController.text = accountId
                                            .toString();

                                        field.didChange(accountId);
                                      },
                                    ),

                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 12,
                                        ),
                                        child: Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'CUENTA ORIGEN',
                              style: ts.titleMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FormField<int>(
                              validator: (_) {
                                if (_toAccountController.text.isEmpty) {
                                  return 'Seleccione una cuenta origen';
                                }
                                if (int.tryParse(_toAccountController.text) ==
                                    fromAccount) {
                                  return 'La cuenta origen no debe ser igual a la cuenta destino';
                                }
                                return null;
                              },
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectedAccount(
                                      accountId: fromAccount,
                                      onTap: (accountId) =>
                                          ref
                                                  .read(
                                                    selectedAccountProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              accountId,
                                    ),

                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 12,
                                        ),
                                        child: Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
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
                      DatePickerField(
                        mode: DatePickerFieldMode.past,
                        selectedDate: _selectedDate,
                        onChanged: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final valid =
                                _formKey.currentState?.validate() ?? false;

                            if (!valid) return;

                            await ref
                                .read(transactionsDaoProvider)
                                .createTransfer(
                                  fromAccountId: fromAccount!,
                                  toAccountId: int.tryParse(
                                    _toAccountController.text,
                                  )!,
                                  amount: CurrencyFormatter.parse(
                                    _amountController.text,
                                    currency,
                                  ),
                                  fromBalance: sourceAccount!.balance,
                                  toBalance: destinationAccount!.balance,
                                  description: _descriptionController.text,
                                  date: _selectedDate,
                                );

                            if (_receiptPath != null) {
                              ref
                                  .read(storageRefreshSignalProvider.notifier)
                                  .state++;
                            }

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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
