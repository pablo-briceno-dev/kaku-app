import 'package:flutter/material.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLocale = 'app_locale';

class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_load(_prefs));

  static Locale? _load(SharedPreferences prefs) {
    final code = prefs.getString(_kLocale);
    if (code == null) return null;
    final supported = AppLocalizations.supportedLocales.map(
      (l) => l.languageCode,
    );
    return supported.contains(code) ? Locale(code) : null;
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(ref.watch(sharedPrefsProvider)),
);
