import 'package:flutter/material.dart';

class BudgetBarSkeleton extends StatelessWidget {
  final double height;

  const BudgetBarSkeleton({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 120,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.onSurface.withAlpha(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder del emoji
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          // Placeholder del nombre
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          // Placeholder de la barra
          Container(
            width: double.infinity,
            height: 7,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          // Placeholder del porcentaje
          Container(
            width: 32,
            height: 14,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
