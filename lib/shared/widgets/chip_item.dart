import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChipItem extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Color? color;

  const ChipItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.primary.withValues(alpha: 0.15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ts.titleSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          Text(
            subtitle,
            style: ts.titleLarge?.copyWith(
              color: color ?? cs.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: (ts.titleLarge?.fontSize ?? 12) * 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
