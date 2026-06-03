import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/database/daos/transactions_dao.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/models/transaction_type.dart';

class SlideAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const SlideAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class TransactionItem extends StatelessWidget {
  final TransactionWithCategory txWithCat; // TransactionWithCategory
  final VoidCallback? onTap;
  final List<SlideAction>? slideActions;

  const TransactionItem({
    super.key,
    required this.txWithCat,
    this.onTap,
    this.slideActions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tx = txWithCat.transaction;
    final cat = txWithCat.category;

    final transactionType = TransactionType.values
        .where((type) => type.name == tx.type)
        .first;
    final amountColor = transactionType.color;
    final amountPrefix = transactionType.prefix;

    final hasActions = slideActions != null && slideActions!.isNotEmpty;

    Widget buildIcon() {
      if (tx.type == TransactionType.transfer.name) {
        return Icon(Icons.swap_horiz_rounded, color: cs.secondary);
      }
      return Text(cat?.emoji ?? '💸', style: const TextStyle(fontSize: 18));
    }

    Widget item = Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cs.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: buildIcon(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description ?? cat?.name ?? 'Sin descripción',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      // color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (cat != null) cat.name,
                      DateFormatter.relativeShort(tx.date),
                    ].join(' · '),
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix${CurrencyFormatter.compact(tx.amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );

    if (!hasActions) {
      return InkWell(onTap: onTap, child: item);
    }

    return Slidable(
      // key único por transacción para que Slidable no confunda
      // los ítems al hacer scroll
      key: ValueKey(tx.id),

      // Las acciones salen por la derecha (desliza a la izquierda)
      endActionPane: ActionPane(
        // Animación: los botones salen desde el borde derecho
        motion: const DrawerMotion(),

        // El tamaño del panel = proporción del ancho del item.
        // Con 2 acciones: 0.4 (40%) queda bien visualmente.
        // Con 3 acciones: usa 0.55
        extentRatio: slideActions!.length == 1
            ? 0.22
            : slideActions!.length == 2
            ? 0.40
            : 0.55,

        children: slideActions!.map((action) {
          return CustomSlidableAction(
            onPressed: (_) => action.onTap(),
            backgroundColor: action.color.withValues(alpha: 0.12),
            foregroundColor: action.color,
            borderRadius: BorderRadius.circular(12),
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, size: 20),
                const SizedBox(height: 4),
                Text(
                  action.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),

      child: InkWell(onTap: onTap, child: item),
    );
  }
}
