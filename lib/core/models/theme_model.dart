import 'package:flutter/material.dart';

enum AppAccent {
  aurora, // Verde esmeralda #7CFFD4
  dusk, // Naranja cálido #FF9F7C
  violet, // Púrpura #C87CFF
  mono, // Gris plateado #B0B0C8
  ocean; // Azul celeste #7CB8FF

  String get label {
    switch (this) {
      case AppAccent.aurora:
        return 'Aurora';
      case AppAccent.dusk:
        return 'Dusk';
      case AppAccent.violet:
        return 'Violet';
      case AppAccent.mono:
        return 'Mono';
      case AppAccent.ocean:
        return 'Ocean';
    }
  }

  Color get color {
    switch (this) {
      case AppAccent.aurora:
        return Color(0xFF7CFFD4);
      case AppAccent.dusk:
        return Color(0xFFFF9F7C);
      case AppAccent.violet:
        return Color(0xFFC87CFF);
      case AppAccent.mono:
        return Color(0xFFB0B0C8);
      case AppAccent.ocean:
        return Color(0xFF7CB8FF);
    }
  }
}

enum AppThemeMode { dark, light, system }

class ThemePreference {
  final AppAccent accent;
  final AppThemeMode mode;
  final Color? customAccentColor;

  const ThemePreference({
    this.accent = AppAccent.aurora,
    this.mode = AppThemeMode.dark,
    this.customAccentColor,
  });

  ThemePreference copyWith({
    AppAccent? accent,
    AppThemeMode? mode,
    Color? customAccentColor,
  }) => ThemePreference(
    accent: accent ?? this.accent,
    mode: mode ?? this.mode,
    customAccentColor: customAccentColor ?? this.customAccentColor,
  );

  // Color principal del acento (para botones, barras de progreso, FAB)
  Color get accentColor => customAccentColor ?? _accentColorFromEnum;

  Color get _accentColorFromEnum => const {
    AppAccent.aurora: Color(0xFF7CFFD4),
    AppAccent.dusk: Color(0xFFFF9F7C),
    AppAccent.violet: Color(0xFFC87CFF),
    AppAccent.mono: Color(0xFFB0B0C8),
    AppAccent.ocean: Color(0xFF7CB8FF),
  }[accent]!;

  // Color de fondo principal (modo oscuro)
  Color get darkBackground {
    if (customAccentColor != null) {
      final hsl = HSLColor.fromColor(customAccentColor!);
      return hsl.withLightness(0.06).withSaturation(0.3).toColor();
    }

    return const {
      AppAccent.aurora: Color(0xFF0A1814),
      AppAccent.dusk: Color(0xFF120C07),
      AppAccent.violet: Color(0xFF0E0818),
      AppAccent.mono: Color(0xFF0F0F0F),
      AppAccent.ocean: Color(0xFF060E1C),
    }[accent]!;
  }

  // Nombre legible para mostrar en la UI de Settings
  String get accentLabel => const {
    AppAccent.aurora: 'Aurora',
    AppAccent.dusk: 'Dusk',
    AppAccent.violet: 'Violet',
    AppAccent.mono: 'Mono',
    AppAccent.ocean: 'Ocean',
  }[accent]!;

  String get modeLabel => const {
    AppThemeMode.dark: 'Oscuro',
    AppThemeMode.light: 'Claro',
    AppThemeMode.system: 'Sistema',
  }[mode]!;

  // Convierte al ThemeMode de Flutter (para MaterialApp.themeMode)
  ThemeMode get flutterThemeMode => const {
    AppThemeMode.dark: ThemeMode.dark,
    AppThemeMode.light: ThemeMode.light,
    AppThemeMode.system: ThemeMode.system,
  }[mode]!;

  // Serialización para SharedPreferences
  Map<String, String> toMap() => {
    'accent': accent.name, // 'aurora', etc
    'mode': mode.name,
    if (customAccentColor != null)
      'customAccentColor': customAccentColor!
          .toARGB32()
          .toRadixString(16)
          .padLeft(8, '0'),
  };

  factory ThemePreference.fromMap(Map<String, String?> map) {
    final customHex = map['customAccentColor'];
    final customColor = customHex != null
        ? Color(int.parse(customHex, radix: 16))
        : null;

    return ThemePreference(
      accent: AppAccent.values.firstWhere(
        (e) => e.name == map['accent'],
        orElse: () => AppAccent.aurora,
      ),
      mode: AppThemeMode.values.firstWhere(
        (e) => e.name == map['mode'],
        orElse: () => AppThemeMode.dark,
      ),
      customAccentColor: customColor,
    );
  }
}
