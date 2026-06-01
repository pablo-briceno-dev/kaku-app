import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/app.dart';
import 'package:kaku/features/settings/biometric_lock_screen.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:kaku/shared/services/backup_service.dart';
import 'package:kaku/shared/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final prefs = await SharedPreferences.getInstance();

  await BackupService.initialize();
  await NotificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: BiometricLockScreen(child: KakuApp()),
    ),
  );
}
