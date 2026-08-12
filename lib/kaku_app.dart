import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/router/app_router.dart';
import 'package:kaku/core/theme/app_theme.dart';
import 'package:kaku/shared/providers/theme_provider.dart';

class KakuApp extends ConsumerWidget {
  const KakuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themePref = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Kaku',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themePref.flutterThemeMode,
      theme: AppTheme.light(
        themePref.accent,
        customColor: themePref.customAccentColor,
      ),
      darkTheme: AppTheme.dark(
        themePref.accent,
        customColor: themePref.customAccentColor,
      ),
      localizationsDelegates: const [
        // AppLocalizations.delegate, // tus traducciones
        GlobalMaterialLocalizations.delegate, // widgets Material en español
        GlobalWidgetsLocalizations.delegate, // dirección de texto, etc.
        GlobalCupertinoLocalizations.delegate, // widgets iOS en español
      ],
      supportedLocales: const [
        Locale('es'), // español — idioma base
        Locale('en'), // inglés
      ],
    );
  }
}
