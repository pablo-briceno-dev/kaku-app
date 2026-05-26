import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';

class CardGoal extends StatelessWidget {
  final String emoji;
  final String name;
  final String targetAmount;
  final String savedAmount;
  final double progress;
  final String estimate;
  final VoidCallback onTap;
  final VoidCallback onContribute;
  final VoidCallback onDelete;

  const CardGoal({
    super.key,
    required this.emoji,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.progress,
    required this.estimate,
    required this.onTap,
    required this.onContribute,
    required this.onDelete,
  });

  Color _obtainColor(double progress, ColorScheme cs) {
    if (progress >= 0.9) {
      return Colors.green;
    } else if (progress < 0.9) {
      return cs.primary;
    } else {
      return cs.primaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: cs.onPrimaryContainer.withAlpha(60),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: ts.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$savedAmount de $targetAmount',
                      style: ts.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.percentage(progress),
                      style: ts.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _obtainColor(progress, cs),
                      ),
                    ),
                    Text(
                      estimate,
                      style: ts.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              minHeight: 8.0,
              value: progress,
              color: _obtainColor(progress, cs),
              backgroundColor: cs.onPrimaryContainer.withAlpha(60),
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.add, color: _obtainColor(progress, cs)),
                  label: const Text(
                    'Aportar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _obtainColor(
                      progress,
                      cs,
                    ).withValues(alpha: 0.1),
                    foregroundColor: _obtainColor(progress, cs),
                    side: BorderSide(color: _obtainColor(progress, cs)),
                  ),
                  onPressed: onContribute,
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: Icon(Icons.delete, color: cs.error),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: cs.error.withAlpha(10),
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error, width: 1),
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
