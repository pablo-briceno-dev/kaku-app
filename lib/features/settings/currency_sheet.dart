import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/shared/providers/ui_provider.dart';

class CurrencySheet extends ConsumerWidget {
  const CurrencySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyProv = ref.watch(currencyProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: CurrencyType.values.length,
        itemBuilder: (context, index) {
          final currency = CurrencyType.values[index];
          final selected = currency == currencyProv;

          return Material(
            type: MaterialType.transparency,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary.withValues(alpha: 0.12)
                      : scheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    currency.labelCompact,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
              title: Text(
                currency.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected ? scheme.primary : null,
                ),
              ),
              subtitle: Text(
                currency.labelComplete,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: selected
                  ? Icon(Icons.check_circle, color: scheme.primary, size: 20)
                  : const SizedBox(width: 20),
              onTap: () {
                ref.read(currencyProvider.notifier).setCurrency(currency);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
