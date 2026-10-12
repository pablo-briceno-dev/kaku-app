import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/helpers/app_snackbar.dart';
import 'package:kaku/core/l10n/category_l10n.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/core/models/transaction_type.dart';
import 'package:kaku/core/receipt_storage.dart';
import 'package:kaku/features/transactions/edit_transaction_sheet.dart';
import 'package:kaku/features/transactions/widgets/transaction_detail_list.dart';
import 'package:kaku/features/transactions/widgets/transaction_detail_skeleton.dart';
import 'package:kaku/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteTransactionConfirm),
        content: Text(l10n.deleteTransactionDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.btnCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.btnDelete),
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
        AppSnackbar.success(context, l10n.deleteTransactionSuccess);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final currencyPro = ref.watch(currencyProvider);
    final transactionAsync = ref.watch(transactionByIdProvider(id));

    return transactionAsync.when(
      data: (transaction) {
        if (transaction == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: Text(l10n.transactionTitle(plural: 0)),
            ),
            body: Center(
              child: ContentWidgetEmpty(
                title: '💱​',
                message: l10n.transactionNotFound,
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
          appBar: CustomAppBar(
            title: Text(l10n.transactionTitle(plural: 0)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Encabezado (Emoji, monto, categoría, tipo) ───
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
                      '${category != null ? '${category.displayName(context)} · ' : ''} ${DateFormatter.fullDateTime(transaction.date)}',
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
                        transactionType.label(l10n, 1),
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

              // ─── Parte scrolleable (lista + botones) ───
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TransactionDetailList(
                        list: [
                          TransactionDetailListConfig(
                            title: l10n.transactionDescriptionLabel,
                            subtitle:
                                transaction.description ??
                                category?.name ??
                                ' - ',
                          ),
                          TransactionDetailListConfig(
                            title: l10n.categoryTitle(isPlural: 0),
                            subtitle:
                                '${category?.emoji ?? ''} ${category?.displayName(context) ?? ' - '}',
                          ),
                          TransactionDetailListConfig(
                            title: l10n.accountsTitle(isPlural: 0),
                            subtitle:
                                '${account?.icon ?? ''} ${account?.name ?? ' - '}',
                          ),
                          TransactionDetailListConfig(
                            title: l10n.transactionDateCompleteLabel,
                            subtitle: context.dates.fullDateTime(
                              transaction.date,
                            ),
                          ),
                          TransactionDetailListConfig(
                            title: l10n.transactionRecurrentLabel,
                            subtitle: transaction.isRecurring
                                ? l10n.transactionIsRecurringLabel(
                                    recurring: 1,
                                  )
                                : l10n.transactionIsRecurringLabel(
                                    recurring: 0,
                                  ),
                          ),
                          TransactionDetailListConfig(
                            title: l10n.transactionReceiptLabel,
                            subtitle: transaction.receiptPath,
                            isImage: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Botones centrados y con espacio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.edit, color: cs.primary),
                              label: Text(l10n.btnEdit),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: cs.primary.withValues(
                                  alpha: 0.1,
                                ),
                                foregroundColor: cs.primary,
                                side: BorderSide(color: cs.primary),
                              ),
                              onPressed: () {
                                ref
                                        .watch(selectedAccountProvider.notifier)
                                        .state =
                                    transaction.accountId;
                                ref
                                    .watch(selectedCategoryProvider.notifier)
                                    .state = transaction
                                    .categoryId;
                                AppBottomSheet.show(
                                  context,
                                  title: l10n.transactionEditTitle(
                                    id: transaction.id,
                                  ),
                                  isFullScreen: true,
                                  useRootNavigator: true,
                                  child: EditTransactionSheet(
                                    transaction: transaction,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 150,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: Text(l10n.btnDelete),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.red.withValues(
                                  alpha: 0.1,
                                ),
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
                      const SizedBox(height: 20), // espacio extra al final
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (e, _) => Scaffold(
        appBar: CustomAppBar(title: Text(l10n.transactionTitle(plural: 0))),
        body: TransactionDetailSkeleton(),
      ),
      loading: () => Scaffold(
        appBar: CustomAppBar(title: Text(l10n.transactionTitle(plural: 0))),
        body: TransactionDetailSkeleton(),
      ),
    );
  }
}
