import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class UpcomingEventItem extends ConsumerWidget {
  final DateTime date;
  final String title;
  final double? amount;

  const UpcomingEventItem({
    super.key,
    required this.date,
    required this.title,
    this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);

    return Row(
      children: [
        Icon(Icons.event_rounded, size: 15),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Text(
            context.dates.relative(date),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: amount != null ? 1 : 2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                amount != null
                    ? CurrencyFormatter.format(amount!, currency)
                    : '',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
