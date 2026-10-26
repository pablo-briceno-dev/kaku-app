import 'package:shared_preferences/shared_preferences.dart';

class WhatsNewService {
  //? Cambiar este id cuando haya otra novedad que anunciar
  static const currentId = 'calendar_1';
  static const _key = 'whats_new_seen';
  static bool _shownThisSession = false;

  static Future<bool> shouldShow({required bool hasExistingData}) async {
    if (_shownThisSession) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_key) == currentId) return false;

    // Instalación nueva: no hay nada que descubrir, se marca como visto en silencio
    if (!hasExistingData) {
      await prefs.setString(_key, currentId);
      return false;
    }

    return true;
  }

  static Future<void> markSeen() async {
    _shownThisSession = true;
    (await SharedPreferences.getInstance()).setString(_key, currentId);
  }
}
