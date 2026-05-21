import 'package:flutter/material.dart';

class CardAccountTypeConfig {
  final String icon;
  final String title;
  final Color? color;

  const CardAccountTypeConfig({
    required this.icon,
    required this.title,
    this.color,
  });
}

class CardAccountType extends StatelessWidget {
  final CardAccountTypeConfig cardConfig;
  final bool isSelected;
  final VoidCallback? onTap;

  const CardAccountType({
    super.key,
    required this.cardConfig,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? (cardConfig.color ?? cs.primary).withValues(alpha: 0.15)
              : cs.onSurfaceVariant.withValues(alpha: 0.15),
          border: isSelected
              ? Border.all(
                  color: (cardConfig.color ?? cs.primary).withValues(
                    alpha: 0.1,
                  ),
                  width: 4,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(cardConfig.icon, style: ts.titleLarge?.copyWith(fontSize: 30)),
            Text(
              cardConfig.title,
              style: ts.titleLarge?.copyWith(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
