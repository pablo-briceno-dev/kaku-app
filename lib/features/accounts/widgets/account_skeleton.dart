import 'package:flutter/material.dart';

class AccountSkeleton extends StatelessWidget {
  const AccountSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 120,
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.onSurface.withAlpha(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Placeholder del emoji
          Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          // Placeholder del nombre
          Container(
            width: 80,
            height: 45,
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Spacer(),
          // Placeholder del porcentaje
          Container(
            width: 50,
            height: 45,
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
