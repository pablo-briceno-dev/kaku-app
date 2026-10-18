import 'package:flutter/material.dart';

class Stat extends StatelessWidget {
  final String label, value;
  final bool error;

  const Stat({
    super.key,
    required this.label,
    required this.value,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: error ? cs.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
