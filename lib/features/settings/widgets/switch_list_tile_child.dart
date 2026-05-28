import 'package:flutter/material.dart';

class SwitchListTileChild extends StatelessWidget {
  final String label, subtitle;
  final bool value;
  final IconData icon;
  final Function(bool) onChanged;

  const SwitchListTileChild({
    super.key,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: _iconBox(icon, scheme.primary),
      title: Text(label, style: textTheme.titleSmall),
      subtitle: Text(subtitle, style: textTheme.bodySmall),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _iconBox(IconData icon, Color color) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}
