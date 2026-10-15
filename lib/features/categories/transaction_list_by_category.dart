import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/features/dashboard/widgets/transactions_list_skeleton.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/content_widget_empty.dart';
import 'package:kaku/shared/widgets/transaction_item.dart';

class TransactionListByCategory extends ConsumerStatefulWidget {
  final int categoryId;
  const TransactionListByCategory({super.key, required this.categoryId});

  @override
  ConsumerState<TransactionListByCategory> createState() =>
      _TransactionListByCategoryState();
}

class _TransactionListByCategoryState
    extends ConsumerState<TransactionListByCategory> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_maybeLoadMore);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _position?.removeListener(_maybeLoadMore);
    super.dispose();
  }

  CategoryTxArgs get _args {
    final month = ref.read(
      selectedMonthProvider,
    ); // ajusta si no es un DateTime
    return (
      categoryId: widget.categoryId,
      year: month.year,
      month: month.month,
    );
  }

  void _maybeLoadMore() {
    final pos = _position;
    if (pos == null || !mounted) return;
    if (pos.extentAfter < 300) {
      ref.read(categoryTxProvider(_args).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final args = (categoryId: widget.categoryId, year: null, month: null);
    final txAsync = ref.watch(categoryTxProvider(args));

    return txAsync.when(
      loading: () => const TransactionsListSkeleton(),
      error: (e, _) => const SizedBox.shrink(),
      data: (page) {
        if (page.items.isEmpty) {
          return ContentWidgetEmpty(
            title: '🫙',
            message: l10n.transactionEmpty,
          );
        }

        // Agrupar por día (la consulta ya viene ordenada por fecha desc)
        final grouped = <String, List<TransactionWithCategory>>{};
        for (final tx in page.items) {
          final key = DateFormatter.groupKey(tx.transaction.date);
          grouped.putIfAbsent(key, () => []).add(tx);
        }

        // Si la primera página no llena la pantalla no hay scroll que lo dispare
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ...tu encabezado "Transacciones" igual que antes
            ...grouped.entries.map((entry) {
              final date = DateTime.parse(entry.key);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      context.dates.relative(date),
                      style: ts.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...entry.value.map((tx) => TransactionItem(txWithCat: tx)),
                  const SizedBox(height: 8),
                ],
              );
            }),
            if (page.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
