import 'package:flutter/material.dart';

class ListTileChild extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const ListTileChild({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: scheme.primary, size: 20),
      ),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: scheme.onSurface),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: scheme.onSurface, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
