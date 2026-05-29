import 'package:flutter/material.dart';

class CategoriesEmptyState extends StatelessWidget {
  const CategoriesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🗂️', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          const Text(
            'Sin categorías',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Toca "+ Nueva" para crear tu primera categoría',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
