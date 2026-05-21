import 'package:flutter/material.dart';

class AccountDetailSkeleton extends StatelessWidget {
  const AccountDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 120,
      height: 300,
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
            width: 80,
            height: 150,
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
