import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kAccent = 'theme_accent';
const String _kMode = 'theme_mode';

// StateNotifier: gestiona el estado y persiste cambios
class ThemeNotifier extends StateNotifier<ThemePreference> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs)
    : super(
        ThemePreference.fromMap({
          'accent': _prefs.getString(_kAccent),
          'mode': _prefs.getString(_kMode),
        }),
      );

  Future<void> setAccent(AppAccent accent) async {
    state = state.copyWith(accent: accent);
    await _prefs.setString(_kAccent, accent.name);
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _prefs.setString(_kMode, mode.name);
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Inicializado en main()'),
);

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemePreference>(
  (ref) => ThemeNotifier(ref.watch(sharedPrefsProvider)),
);
