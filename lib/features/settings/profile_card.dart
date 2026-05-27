import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/features/settings/widgets/profile_avatar.dart';
import 'package:kaku/shared/providers/profile_provider.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final profile = ref.watch(profileProvider);

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: ProfileAvatar(profile: profile)),
            const SizedBox(width: 8),
            Expanded(
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
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {},
              label: Text(profile.isPremium ? 'Premium' : 'Gratis'),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: cs.primary,
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
