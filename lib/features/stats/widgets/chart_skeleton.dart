import 'package:flutter/material.dart';

class ChartSkeleton extends StatelessWidget {
  final double height;

  const ChartSkeleton({super.key, required this.height});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
