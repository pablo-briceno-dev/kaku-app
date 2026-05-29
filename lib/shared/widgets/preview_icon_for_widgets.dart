import 'package:flutter/material.dart';

class PreviewIconForWidgets extends StatelessWidget {
  final Color color;
  final String icon;
  final String? label;
  final String? subtitle;
  final double size;

  const PreviewIconForWidgets({
    super.key,
    required this.color,
    required this.icon,
    this.label,
    this.subtitle,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.1), width: 5),
          ),
          child: Center(
            child: Text(icon, style: ts.titleLarge?.copyWith(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 8),
        if (label != null)
          Text(
            label!,
            style: ts.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        if (subtitle != null) Text(subtitle!),
      ],
    );
  }
}
