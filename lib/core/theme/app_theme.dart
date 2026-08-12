import 'package:flutter/material.dart';
import 'package:kaku/core/models/theme_model.dart';

abstract class AppTheme {
  // Tema Oscuro
  static ThemeData dark(AppAccent accent, {Color? customColor}) {
    final pref = ThemePreference(accent: accent, mode: AppThemeMode.dark, customAccentColor: customColor);
    final seed = pref.accentColor;
    final bgColor = pref.darkBackground;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ).copyWith(
          // Sobreescribe los colores clave con los de tu diseño
          surface: bgColor,
          surfaceContainer: Color.lerp(bgColor, seed, 0.05)!,
          primary: seed,
          onPrimary: _contrastFor(seed),
          secondary: seed.withValues(alpha: 0.7),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgColor,
        indicatorColor: seed.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: seed);
          }
          return IconThemeData(color: seed.withValues(alpha: 0.4));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? seed
              : seed.withValues(alpha: 0.4);
          return TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seed,
        foregroundColor: _contrastFor(seed),
        elevation: 4,
      ),
      // Cards
      cardTheme: CardThemeData(
        color: Color.lerp(bgColor, seed, 0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: seed.withValues(alpha: 0.08)),
        ),
      ),
      // EleatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: _contrastFor(seed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      // InputDecoration (campos de texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: seed.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
      ),
    );
  }

  // Tema Claro
  static ThemeData light(AppAccent accent, {Color? customColor}) {
    final seed = ThemePreference(
      accent: accent,
      mode: AppThemeMode.light,
      customAccentColor: customColor,
    ).accentColor;

    final darkSeed = HSLColor.fromColor(seed)
        .withLightness((HSLColor.fromColor(seed).lightness - 0.2).clamp(0, 1))
        .toColor();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkSeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F8FC),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkSeed.withValues(alpha: 0.12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkSeed,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Devuelve negro o blanco según el brillo del color de fondo
  static Color _contrastFor(Color bg) =>
      ThemeData.estimateBrightnessForColor(bg) == Brightness.light
      ? const Color(0xFF0A0A14)
      : Colors.white;
}
