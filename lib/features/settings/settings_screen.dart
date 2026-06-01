import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/settings/backup_sheet.dart';
import 'package:kaku/features/settings/biometric_toggle.dart';
import 'package:kaku/features/settings/currency_sheet.dart';
import 'package:kaku/features/settings/export_sheet.dart';
import 'package:kaku/features/settings/notifications_toggle.dart';
import 'package:kaku/features/settings/profile_card.dart';
import 'package:kaku/features/settings/storage_sheet.dart';
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
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final budgetsProgress = ref.watch(budgetProgressProvider(selectedMonth));
    final backupSubtitle = ref.watch(lastBackupSubtitleProvider);
    final storageSubtitle = ref.watch(storageSubtitleProvider);

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
                  child: ThemeColorSheet(),
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
                onTap: () => context.push(AppRoutes.categories),
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
                onTap: () => context.push(AppRoutes.budgets),
              ),
            ],
          ),
          SectionHeader('Datos'),
          SectionCard(
            children: [
              ListTileChild(
                label: 'Backup Google Drive',
                subtitle: backupSubtitle.when(
                  data: (s) => s,
                  error: (e, _) => 'Sin sincronizar',
                  loading: () => 'Cargando...',
                ),
                icon: Icons.backup,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: 'Backup',
                  child: const BackupSheet(),
                ),
              ),
              const Divider(height: 1),
              ListTileChild(
                label: 'Exportar datos',
                subtitle: 'CSV · PDF',
                icon: Icons.upload_file,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: 'Exportar datos',
                  child: const ExportSheet(),
                ),
              ),
              const Divider(height: 1),
              ListTileChild(
                label: 'Almacenamiento local',
                subtitle: storageSubtitle.when(
                  data: (s) => s,
                  error: (e, _) => 'No disponible',
                  loading: () => 'Cargando...',
                ),
                icon: Icons.storage,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: 'Almacenamiento',
                  child: const StorageSheet(),
                ),
              ),
            ],
          ),
          SectionHeader('Seguridad'),
          SectionCard(
            children: [
              BiometricToggle(),
              // SwitchListTileChild(
              //   label: 'Biometría / FaceID',
              //   subtitle: 'Protege la app al abrirse',
              //   icon: Icons.security,
              //   value: true,
              //   onChanged: (v) {},
              // ),
              const Divider(height: 1),
              NotificationsToggle(),
              // SwitchListTileChild(
              //   label: 'Notificaciones',
              //   subtitle: 'Alertas de presupuesto',
              //   icon: Icons.notifications,
              //   value: true,
              //   onChanged: (v) {},
              // ),
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
