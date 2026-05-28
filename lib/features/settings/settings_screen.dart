import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:kaku/features/settings/currency_sheet.dart';
import 'package:kaku/features/settings/profile_card.dart';
import 'package:kaku/features/settings/theme_color_sheet.dart';
import 'package:kaku/features/settings/widgets/list_tile_child.dart';
import 'package:kaku/features/settings/widgets/section_card.dart';
import 'package:kaku/features/settings/widgets/section_header.dart';
import 'package:kaku/features/settings/widgets/switch_list_tile_child.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);
    final categoriesAsync = ref.watch(getExpenseCategoriesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final budgetsProgress = ref.watch(budgetProgressProvider(selectedMonth));

    return Scaffold(
      appBar: CustomAppBar(title: Text('Configuración'), defaultActions: false),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          ProfileCard(),
          const SizedBox(height: 20),
          SectionHeader('Apariencia'),
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
                              MediaQuery.of(context).viewPadding.bottom + 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              SwitchListTileChild(
                label: 'Modo oscuro',
                subtitle:
                    'Activa el modo oscuro o desactivalo para usar el tema claro',
                icon: Icons.light_mode_outlined,
                value: themeMode.mode == AppThemeMode.dark,
                onChanged: (v) {
                  if (v) {
                    ref.read(themeProvider.notifier).setMode(AppThemeMode.dark);
                    return;
                  }
                  ref.read(themeProvider.notifier).setMode(AppThemeMode.light);
                },
              ),
            ],
          ),
          SectionHeader('Regional'),
          SectionCard(
            children: [
              ListTileChild(
                label: 'Moneda',
                subtitle: '${currency.label} - ${currency.labelComplete}',
                icon: Icons.monetization_on,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: 'Moneda',
                  useRootNavigator: false,
                  isFullScreen: false,
                  child: CurrencySheet(),
                ),
              ),
              const Divider(height: 1),
              ListTileChild(
                label: 'Categorías',
                subtitle: categoriesAsync.when(
                  data: (categories) => '${categories.length} activas',
                  error: (_, _) => '0 activas',
                  loading: () => 'Cargando...',
                ),
                icon: Icons.category,
                onTap: () {},
              ),
            ],
          ),
          SectionHeader('Presupuestos'),
          SectionCard(
            children: [
              ListTileChild(
                label: 'Presupuestos por categorías',
                subtitle:
                    '${DateFormatter.monthYear(selectedMonth.year, selectedMonth.month)} - ${budgetsProgress.when(data: (budgets) => '${budgets.length} configurados', error: (e, _) => '0 configurados', loading: () => 'Cargando...')}',
                icon: Icons.bar_chart,
                onTap: () {},
              ),
            ],
          ),
          SectionHeader('Datos'),
          SectionCard(
            children: [
              ListTileChild(
                label: 'Backup Google Drive',
                subtitle: 'Última sync: 2022-05-20',
                icon: Icons.backup,
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTileChild(
                label: 'Exportar datos',
                subtitle: 'CSV · PDF',
                icon: Icons.upload_file,
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTileChild(
                label: 'Almacenamiento local',
                subtitle: '14.2 MB · 32 fotos', // TODO: actualizar
                icon: Icons.storage,
                onTap: () {},
              ),
            ],
          ),
          SectionHeader('Seguridad'),
          SectionCard(
            children: [
              SwitchListTileChild(
                label: 'Biometría / FaceID',
                subtitle: 'Protege la app al abrirse',
                icon: Icons.security,
                value: true,
                onChanged: (v) {},
              ),
              const Divider(height: 1),
              SwitchListTileChild(
                label: 'Notificaciones',
                subtitle: 'Alertas de presupuesto',
                icon: Icons.notifications,
                value: true,
                onChanged: (v) {},
              ),
            ],
          ),
          SectionHeader('Zona peligrosa'),
          SectionCard(
            children: [
              ListTileChild(
                label: 'Borrar todos los datos',
                subtitle: 'Elimina todos los datos de la app',
                icon: Icons.delete,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 20),
        ],
      ),
    );
  }
}
