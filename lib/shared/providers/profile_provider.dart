import 'package:kaku/core/models/user_profile.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;

  ProfileNotifier(this._prefs)
    : super(
        UserProfile.fromPrefs({
          'profile_name': _prefs.getString('profile_name'),
          'profile_avatar_path': _prefs.getString('profile_avatar_path'),
          'profile_is_premium': _prefs.getString('profile_is_premium'),
        }),
      );

  Future<void> setName(String name) async {
    state = state.copyWith(name: name);
    await _prefs.setString('profile_name', name);
  }

  Future<void> setAvatar(String avatarPath) async {
    state = state.copyWith(avatarPath: avatarPath);
    await _prefs.setString('profile_avatar_path', avatarPath);
  }

  Future<void> removeAvatar() async {
    state = UserProfile(name: state.name, isPremium: state.isPremium);
    await _prefs.remove('profile_avatar_path');
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>(
  (ref) => ProfileNotifier(ref.watch(sharedPrefsProvider)),
);
