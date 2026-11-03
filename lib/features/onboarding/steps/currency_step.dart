import 'package:flutter/material.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/l10n/app_localizations.dart';

class CurrencyStep extends StatelessWidget {
  final CurrencyType selected;
  final ValueChanged<CurrencyType> onChanged;

  const CurrencyStep({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('👋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingCurrencyTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingCurrencySubtitle,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: CurrencyType.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final currency = CurrencyType.values[i];
                final isSelected = currency == selected;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? cs.primary : cs.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  leading: Text(
                    currency.label,
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Text(currency.label),
                  subtitle: Text(currency.labelComplete(l10n)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: cs.primary)
                      : null,
                  onTap: () => onChanged(currency),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
