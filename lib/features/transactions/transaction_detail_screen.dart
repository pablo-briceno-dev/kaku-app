import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/core/receipt_storage.dart';
import 'package:kaku/features/transactions/edit_transaction_sheet.dart';
import 'package:kaku/features/transactions/widgets/transaction_detail_list.dart';
import 'package:kaku/features/transactions/widgets/transaction_detail_skeleton.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final int id;

  const TransactionDetailScreen({super.key, required this.id});

  void _onDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
    double balanced,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('Esta acción no se puede deshacer. ¿Eliminar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ReceiptStorage.delete(transaction.receiptPath);
      ref.read(transactionsDaoProvider).deleteTransaction(id);
      final reversedDelta = BudgetCalculator.balanceDelta(
        TransactionType.values.firstWhere((e) => e.name == transaction.type),
        transaction.amount,
      );
      ref
          .read(accountsDaoProvider)
          .updateBalance(
            transaction.accountId,
            balanced + (reversedDelta * -1),
          );

      if (context.mounted) {
        AppSnackbar.success(context, 'Transacción eliminada');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final currencyPro = ref.watch(currencyProvider);
    final transactionAsync = ref.watch(transactionByIdProvider(id));

    return transactionAsync.when(
      data: (transaction) {
        if (transaction == null) {
          return Scaffold(
            appBar: CustomAppBar(title: Text('Transacción')),
            body: Center(
              child: ContentWidgetEmpty(
                title: '💱​',
                message: 'La transacción no es correcta',
              ),
            ),
          );
        }

        final transactionType = TransactionType.values.firstWhere(
          (e) => e.name == transaction.type,
        );
        final category = ref
            .watch(categoryByIdProvider(transaction.categoryId))
            .value;
        final account = ref
            .watch(accountByIdProvider(transaction.accountId))
            .value;

        return Scaffold(
          appBar: CustomAppBar(title: Text('Transacción')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color:
                            (transactionType == TransactionType.expense
                                    ? Colors.red
                                    : Colors.green)
                                .withValues(alpha: 0.15),
                      ),
                      child: category != null
                          ? Center(
                              child: Text(
                                category.emoji,
                                style: TextStyle(fontSize: 40),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.withSign(
                        transaction.amount,
                        currency: currencyPro,
                        type: transactionType,
                      ),
                      style: TextStyle(
                        fontSize: 50,
                        color:
                            (transactionType == TransactionType.expense
                                    ? Colors.red
                                    : Colors.green)
                                .withValues(alpha: 0.76),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${category != null ? '${category.name} · ' : ''} ${DateFormatter.fullDateTime(transaction.date)}',
                      style: TextStyle(
                        fontSize: 15,
                        color: cs.onSurface.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:
                            (transactionType == TransactionType.expense
                                    ? Colors.red
                                    : Colors.green)
                                .withValues(alpha: 0.15),
                        border: Border.all(
                          color:
                              (transactionType == TransactionType.expense
                                      ? Colors.red
                                      : Colors.green)
                                  .withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        transactionType.label,
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              (transactionType == TransactionType.expense
                                      ? Colors.red
                                      : Colors.green)
                                  .withValues(alpha: 0.76),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TransactionDetailList(
                list: [
                  TransactionDetailListConfig(
                    title: 'Descripción',
                    subtitle:
                        transaction.description ?? category?.name ?? ' - ',
                  ),
                  TransactionDetailListConfig(
                    title: 'Categoría',
                    subtitle:
                        '${category?.emoji ?? ''} ${category?.name ?? ' - '}',
                  ),
                  TransactionDetailListConfig(
                    title: 'Cuenta',
                    subtitle:
                        '${account?.icon ?? ''} ${account?.name ?? ' - '}',
                  ),
                  TransactionDetailListConfig(
                    title: 'Fecha y hora',
                    subtitle: DateFormatter.fullDateTime(transaction.date),
                  ),
                  TransactionDetailListConfig(
                    title: 'Recurrente',
                    subtitle: transaction.isRecurring ? 'Si' : 'No',
                  ),
                  TransactionDetailListConfig(
                    title: 'Foto de recibo',
                    subtitle: transaction.receiptPath,
                    isImage: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.edit, color: cs.primary),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: cs.primary.withValues(alpha: 0.1),
                        foregroundColor: cs.primary,
                        side: BorderSide(color: cs.primary),
                      ),
                      onPressed: () {
                        ref.watch(selectedAccountProvider.notifier).state =
                            transaction.accountId;
                        ref.watch(selectedCategoryProvider.notifier).state =
                            transaction.categoryId;
                        AppBottomSheet.show(
                          context,
                          title: 'Editar transacción #${transaction.id}',
                          isFullScreen: true,
                          useRootNavigator: true,
                          child: EditTransactionSheet(transaction: transaction),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _onDelete(
                        context,
                        ref,
                        transaction,
                        account?.balance ?? 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      error: (e, _) => Scaffold(
        appBar: CustomAppBar(title: Text('Transacción')),
        body: TransactionDetailSkeleton(),
      ),
      loading: () => Scaffold(
        appBar: CustomAppBar(title: Text('Transacción')),
        body: TransactionDetailSkeleton(),
      ),
    );
  }
}
