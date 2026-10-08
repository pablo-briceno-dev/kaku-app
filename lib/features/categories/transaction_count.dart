import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';

class TransactionCount extends ConsumerWidget {
  final int categoryId;

  const TransactionCount({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<int>(
      future: ref.read(transactionsDaoProvider).countByCategory(categoryId),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Text(
          l10n.transactionCount(count: count),
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        );
      },
    );
  }
}
