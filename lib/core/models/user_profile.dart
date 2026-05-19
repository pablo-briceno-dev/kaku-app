class UserProfile {
  final String? name;
  final String? avatarPath;
  final bool isPremium;

  const UserProfile({this.name, this.avatarPath, this.isPremium = false});

  UserProfile copyWith({String? name, String? avatarPath, bool? isPremium}) =>
      UserProfile(
        name: name ?? this.name,
        avatarPath: avatarPath ?? this.avatarPath,
        isPremium: isPremium ?? this.isPremium,
      );

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    return "Usuario";
  }

  String get initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Map<String, String> toMap() => {
    'profile_name': ?name,
    'profile_avatar_path': ?avatarPath,
    'profile_is_premium': isPremium.toString(),
  };

  factory UserProfile.fromPrefs(Map<String, String?> map) => UserProfile(
    name: map['profile_name'],
    avatarPath: map['profile_avatar_path'],
    isPremium: map['profile_is_premium'] == 'true',
  );
}
