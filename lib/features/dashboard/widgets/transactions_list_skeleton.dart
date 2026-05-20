import 'package:flutter/material.dart';

class TransactionsListSkeleton extends StatelessWidget {
  const TransactionsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
