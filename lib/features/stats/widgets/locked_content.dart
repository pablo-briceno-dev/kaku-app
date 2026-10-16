import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/l10n/app_localizations.dart';

class LockedContent extends ConsumerWidget {
  final Widget child;

  const LockedContent({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Opacity(opacity: 0.6, child: child),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, color: cs.primary),
                const SizedBox(height: 8),
                Text(
                  l10n.statsIncomeExpenseLocked,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => context.push(AppRoutes.premium),
                  child: Text(l10n.btnViewPremium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
