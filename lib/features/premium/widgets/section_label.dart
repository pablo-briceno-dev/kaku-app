import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({super.key, required this.label});
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        fontSize:      10,
        letterSpacing: 0.14,
        fontWeight:    FontWeight.w700,
        color:         cs.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}