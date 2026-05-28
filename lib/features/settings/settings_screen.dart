import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:kaku/features/settings/profile_card.dart';
import 'package:kaku/features/settings/theme_color_sheet.dart';
import 'package:kaku/features/settings/widgets/list_tile_child.dart';
import 'package:kaku/features/settings/widgets/section_card.dart';
import 'package:kaku/features/settings/widgets/section_header.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(title: Text('Configuración'), defaultActions: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(),
              const SizedBox(height: 20),
              SectionHeader(title: 'Apariencia'),
              SectionCard(
                children: [
                  ListTileChild(
                    label: 'Tema de color',
                    subtitle: themeMode.accent.label,
                    icon: Icons.palette,
                    onTap: () => AppBottomSheet.show(
                      context,
                      title: 'Tema de color',
                      subtitle: 'Elige el color de acento de la app',
                      useRootNavigator: true,
                      isFullScreen: false,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ThemeColorSheet(),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).viewPadding.bottom +
                                  30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: themeMode.mode == AppThemeMode.dark,
                    onChanged: (v) {
                      if (v) {
                        ref
                            .read(themeProvider.notifier)
                            .setMode(AppThemeMode.dark);
                        return;
                      }
                      ref
                          .read(themeProvider.notifier)
                          .setMode(AppThemeMode.light);
                    },
                    secondary: _iconBox(
                      Icons.light_mode_outlined,
                      colorScheme.primary,
                    ),
                    title: Text('Modo oscuro', style: textTheme.titleSmall),
                    subtitle: Text(
                      'Activa el modo oscuro o desactivalo para usar el tema claro',
                      style: textTheme.bodySmall,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}
