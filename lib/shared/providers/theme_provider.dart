import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kAccent = 'theme_accent';
const String _kMode = 'theme_mode';
const String _kCustomAccentColor = 'theme_custom_accent';

// StateNotifier: gestiona el estado y persiste cambios
class ThemeNotifier extends StateNotifier<ThemePreference> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs)
    : super(
        ThemePreference.fromMap({
          'accent': _prefs.getString(_kAccent),
          'mode': _prefs.getString(_kMode),
          'customAccentColor': _prefs.getString(_kCustomAccentColor),
        }),
      );

  Future<void> setAccent(AppAccent accent) async {
    debugPrint('setAccent: $accent');
    state = state.copyWith(accent: accent, customAccentColor: null);
    await _prefs.setString(_kAccent, accent.name);
    await _prefs.remove(_kCustomAccentColor);
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _prefs.setString(_kMode, mode.name);
  }

  Future<void> setCustomAccentColor(Color color) async {
    state = state.copyWith(customAccentColor: color);
    await _prefs.setString(
      _kCustomAccentColor,
      color.toARGB32().toRadixString(16).padLeft(8, '0'),
    );
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Inicializado en main()'),
);

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemePreference>(
  (ref) => ThemeNotifier(ref.watch(sharedPrefsProvider)),
);
