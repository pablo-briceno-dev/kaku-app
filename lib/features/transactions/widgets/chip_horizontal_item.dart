import 'package:flutter/material.dart';

class ChipHorizontalItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const ChipHorizontalItem({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return Container(
      // width: 120,
      height: 40,
      decoration: BoxDecoration(
        color: (isSelected ? cs.primaryContainer : cs.surfaceContainerLow)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isSelected ? cs.primaryContainer : cs.surfaceContainerLow)
              .withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: ts.bodyMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
