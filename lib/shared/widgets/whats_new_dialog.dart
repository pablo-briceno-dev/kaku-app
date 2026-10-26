import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/services/notification_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> showWhatsNewDialog(BuildContext context) async {
  final info = await PackageInfo.fromPlatform();
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;

  final goCalendar = await showDialog<bool>(
    context: context,
    builder: ((ctx) => AlertDialog(
      icon: const Icon(Icons.calendar_month, size: 32),
      title: Text(l10n.whatsNewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.whatsNewVersion(info.version),
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            _Bullet(Icons.event_note_outlined, l10n.whatsNewCalendar),
            _Bullet(
              Icons.notifications_active_outlined,
              l10n.whatsNewReminders,
            ),
            _Bullet(Icons.widgets_outlined, l10n.whatsNewWidget),
            const SizedBox(height: 16),
            Text(
              l10n.whatsNewPremiumNote,
              style: Theme.of(
                ctx,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.whatsNewDismiss),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.whatsNewTry),
        ),
      ],
    )),
  );

  // Tocar fuera de la ventana cuenta como "Ahora no"
  if (goCalendar == true && context.mounted) {
    context.go(withFreshToken(AppRoutes.toPersonal(initialTab: 'calendar')));
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Bullet(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
