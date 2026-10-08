import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/date_formatter.dart';
import 'package:kaku/core/l10n/date_context_x.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/theme_model.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/features/settings/backup_sheet.dart';
import 'package:kaku/features/settings/currency_sheet.dart';
import 'package:kaku/features/settings/danger_zone_sheet.dart';
import 'package:kaku/features/settings/export_sheet.dart';
import 'package:kaku/features/settings/local_backup_sheet.dart';
import 'package:kaku/features/settings/notifications_toggle.dart';
import 'package:kaku/features/settings/profile_card.dart';
import 'package:kaku/features/settings/security/biometric_toggle.dart';
import 'package:kaku/features/settings/storage_sheet.dart';
import 'package:kaku/features/settings/theme_color_sheet.dart';
import 'package:kaku/features/settings/widgets/list_tile_child.dart';
import 'package:kaku/features/settings/widgets/section_card.dart';
import 'package:kaku/features/settings/widgets/section_header.dart';
import 'package:kaku/features/settings/widgets/switch_list_tile_child.dart';
import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/providers/database_provider.dart';
import 'package:kaku/shared/providers/theme_provider.dart';
import 'package:kaku/shared/providers/ui_provider.dart';
import 'package:kaku/shared/services/premium_service.dart';
import 'package:kaku/shared/widgets/app_bottom_sheet.dart';
import 'package:kaku/shared/widgets/custom_app_bar.dart';
import 'package:kaku/shared/widgets/premium_gate.dart';

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
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(l10n.settingsTitle),
        defaultActions: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          ProfileCard(),
          const SizedBox(height: 20),
          SectionHeader(l10n.appearanceTitle),
          SectionCard(
            children: [
              ListTileChild(
                label: l10n.themeTitle,
                subtitle: themeMode.accent.label,
                icon: Icons.palette,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: l10n.themeTitle,
                  subtitle: l10n.themeSubtitle,
                  useRootNavigator: true,
                  isFullScreen: false,
                  child: ThemeColorSheet(),
                ),
              ),
              const Divider(height: 1),
              SwitchListTileChild(
                label: l10n.themeModeTitle,
                subtitle: l10n.themeModeSubtitle,
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
          SectionHeader(l10n.regionalTitle),
          SectionCard(
            children: [
              ListTileChild(
                label: l10n.currencyTitle,
                subtitle: '${currency.label} - ${currency.labelComplete(l10n)}',
                icon: Icons.monetization_on,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: l10n.currencyTitle,
                  useRootNavigator: false,
                  isFullScreen: false,
                  child: CurrencySheet(),
                ),
              ),
              const Divider(height: 1),
              ListTileChild(
                label: l10n.categoriesTitle(femenine: true),
                subtitle: categoriesAsync.when(
                  data: (categories) =>
                      l10n.countActiveCategories(count: categories.length),
                  error: (_, _) => l10n.countActiveCategories(count: 0),
                  loading: () => l10n.loading,
                ),
                icon: Icons.category,
                onTap: () => context.push(AppRoutes.categories),
              ),
            ],
          ),
          SectionHeader(l10n.budgetTitle),
          SectionCard(
            children: [
              ListTileChild(
                label: l10n.budgetByCategoryTitle,
                subtitle: l10n.budgetByCategorySubtitle(
                  monthYear: context.dates.monthYear(
                    selectedMonth.year,
                    selectedMonth.month,
                  ),
                  count: budgetsProgress.when(
                    data: (budgets) => budgets.length,
                    error: (e, _) => 0,
                    loading: () => 0,
                  ),
                ),
                icon: Icons.bar_chart,
                onTap: () => context.push(AppRoutes.budgets),
              ),
            ],
          ),
          SectionHeader(l10n.dataTitle),
          SectionCard(
            children: [
              PremiumGate(
                feature: PremiumFeature.backupDrive,
                showLockBadge: true,
                child: ListTileChild(
                  label: l10n.backupGoogleDriveTitle,
                  subtitle: backupSubtitle.when(
                    data: (date) {
                      if (date == null) return l10n.notSynced;
                      return l10n.syncLastBackup(context.dates.relative(date));
                    },
                    error: (e, _) => l10n.notSynced,
                    loading: () => l10n.loading,
                  ),
                  icon: Icons.backup,
                  onTap: () => AppBottomSheet.show(
                    context,
                    title: l10n.backupTitle,
                    child: const BackupSheet(),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTileChild(
                label: l10n.backupLocalTitle,
                subtitle: l10n.backupSubtitle,
                icon: Icons.save_outlined,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: l10n.backupLocalTitle,
                  child: const LocalBackupSheet(),
                ),
              ),
              const Divider(height: 1),
              ListTileChild(
                label: l10n.exportTitle,
                subtitle: l10n.exportSubtitle,
                icon: Icons.upload_file,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: l10n.exportTitle,
                  child: const ExportSheet(),
                ),
              ),
              const Divider(height: 1),
              ListTileChild(
                label: l10n.storageLocalTitle,
                subtitle: storageSubtitle.when(
                  data: (info) {
                    if (info == null) return l10n.storageNoReceipts;
                    return l10n.storageSummary(
                      size: info.sizeLabel,
                      count: info.count,
                    );
                  },
                  error: (e, _) => l10n.notAvailable,
                  loading: () => l10n.loading,
                ),
                icon: Icons.storage,
                onTap: () => AppBottomSheet.show(
                  context,
                  title: l10n.storageLocalTitle,
                  child: const StorageSheet(),
                ),
              ),
            ],
          ),
          SectionHeader(l10n.securityTitle),
          SectionCard(
            children: [
              PremiumGate(
                feature: PremiumFeature.pinLock,
                showLockBadge: true,
                child: BiometricToggle(),
              ),
              const Divider(height: 1),
              NotificationsToggle(),
            ],
          ),
          SectionHeader(l10n.dangerZoneTitle),
          SectionCard(
            children: [
              ListTileChild(
                label: l10n.deleteDataAllTitle,
                subtitle: l10n.deleteDataAllSubtitle,
                icon: Icons.delete,
                onTap: () => AppBottomSheet.show(
                  context,
                  child: const DangerZoneSheet(),
                ),
              ),
            ],
          ),
          SectionHeader(l10n.aboutTitle),
          SectionCard(
            children: [
              ListTileChild(
                label: l10n.versionTitle,
                subtitle: packageInfoAsync.when(
                  data: (info) => '${info.version} (${info.buildNumber})',
                  error: (_, _) => l10n.notAvailable,
                  loading: () => l10n.loading,
                ),
                icon: Icons.info_outline,
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 20),
        ],
      ),
    );
  }
}
