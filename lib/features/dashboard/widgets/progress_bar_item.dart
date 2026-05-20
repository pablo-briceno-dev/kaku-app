import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/budget_progress.dart';

class ProgressBarItem extends StatelessWidget {
  final String emoji;
  final String title;
  final double progress;
  final BudgetStatus status;
  final VoidCallback? onTap;

  const ProgressBarItem({
    super.key,
    required this.emoji,
    required this.title,
    required this.progress,
    this.status = BudgetStatus.ok,
    this.onTap,
  });

  static const double fixedHeight = 132;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (status) {
      BudgetStatus.ok => cs.primary,
      BudgetStatus.warning => Colors.amber,
      BudgetStatus.overBudget => cs.error,
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        height: fixedHeight,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.primary.withAlpha(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _EmojiText(emoji),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // Barra de progreso
            LinearProgressIndicator(
              value: progress,
              color: color,
              minHeight: 7,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            // Porcentaje — tamaño fijo
            Text(
              CurrencyFormatter.percentage(progress * 100),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para el emoji con tamaño fijo.
// Evita que el emoji use el TextTheme del dispositivo
// (que puede variar según accesibilidad / escala de fuente).
class _EmojiText extends StatelessWidget {
  final String emoji;
  const _EmojiText(this.emoji);

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: const TextStyle(
        fontSize: 22,
        // height 1.0 elimina el line-height extra que añade Flutter
        // a los emojis, haciendo el alto exactamente 22px.
        height: 1.0,
      ),
    );
  }
}
