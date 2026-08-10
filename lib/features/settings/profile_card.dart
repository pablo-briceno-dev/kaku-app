import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/settings/profile_sheet.dart';
import 'package:kaku/features/settings/widgets/profile_avatar.dart';
import 'package:kaku/shared/providers/premium_provider.dart';
import 'package:kaku/shared/providers/profile_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final profile = ref.watch(profileProvider);
    final premiumAsync = ref.watch(premiumNotifierProvider);

    return InkWell(
      onTap: () => AppBottomSheet.show(
        context,
        title: 'Editar perfil',
        useRootNavigator: true,
        isFullScreen: true,
        child: ProfileSheet(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(flex: 1, child: ProfileAvatar(profile: profile)),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      // color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${profile.displayName.toLowerCase().replaceAll(' ', '.')}@kaku',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: premiumAsync.when(
                data: (premium) =>
                    premium ? null : () => context.push(AppRoutes.premium),
                loading: () => null,
                error: (_, _) =>
                    () => context.push(AppRoutes.premium),
              ),
              label: Text(
                premiumAsync.when(
                  data: (premium) => premium ? '✓ Premium' : 'Free',
                  error: (e, _) => 'Free',
                  loading: () => '...',
                ),
              ),
              icon: Icon(
                premiumAsync.when(
                  data: (premium) => premium
                      ? Icons.check_circle
                      : Icons.arrow_forward_ios_rounded,
                  loading: () => Icons.arrow_forward_ios_rounded,
                  error: (_, _) => Icons.arrow_forward_ios_rounded,
                ),
                size: 20,
                color: premiumAsync.when(
                  data: (premium) => premium ? Colors.green : cs.primary,
                  loading: () => cs.primary,
                  error: (_, _) => cs.primary,
                ),
              ),
              iconAlignment: IconAlignment.end,
              style: OutlinedButton.styleFrom(
                backgroundColor: cs.primary.withAlpha(60),
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.primary, width: 2),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
