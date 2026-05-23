import 'package:flutter/material.dart';

class TransactionDetailSkeleton extends StatelessWidget {
  const TransactionDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.onSurface.withAlpha(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Placeholder del emoji
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: cs.onSurface.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 150,
                height: 20,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.onSurface.withAlpha(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 170,
                height: 20,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.onSurface.withAlpha(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 90,
                height: 30,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.onSurface.withAlpha(10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 150,
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.onSurface.withAlpha(10),
              ),
            ),
            const Spacer(),
            Container(
              width: 150,
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.onSurface.withAlpha(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 150,
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.onSurface.withAlpha(10),
              ),
            ),
            const Spacer(),
            Container(
              width: 150,
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.onSurface.withAlpha(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 150,
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.onSurface.withAlpha(10),
              ),
            ),
            const Spacer(),
            Container(
              width: 150,
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.onSurface.withAlpha(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
      ],
    );
  }
}
