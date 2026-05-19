import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/shared/providers/profile_provider.dart';

class AppAvatar extends ConsumerWidget {
  final double radius;

  const AppAvatar({super.key, this.radius = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final accent = Theme.of(context).colorScheme.primary;

    if (profile.avatarPath != null) {
      final file = File(profile.avatarPath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: radius, backgroundImage: FileImage(file));
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: accent.withValues(alpha: 0.15),
      child: Text(
        profile.initials,
        style: TextStyle(
          color: accent,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
