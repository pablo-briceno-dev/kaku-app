import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaku/core/models/user_profile.dart';

class ProfileAvatar extends StatelessWidget {
  final UserProfile profile;
  final double radius;

  const ProfileAvatar({super.key, required this.profile, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: cs.primary.withAlpha(60),
        foregroundColor: cs.primary,
        backgroundImage:
            profile.avatarPath != null && profile.avatarPath!.isNotEmpty
            ? FileImage(File(profile.avatarPath!))
            : null,
        child: profile.avatarPath == null || profile.avatarPath!.isEmpty
            ? Text(
                profile.initials,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
