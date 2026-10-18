import 'package:kaku/l10n/app_localizations.dart';
import 'package:kaku/shared/services/premium_service.dart';

extension PremiumBlockReasonX on PremiumBlockReason {
  String label(AppLocalizations l10n) {
    return switch (this) {
      PremiumBlockReason.backupDrive => l10n.premiumBlockedBackupDrive,
      PremiumBlockReason.exportPdfWithReceipts =>
        l10n.premiumBlockedExportPdfWithReceipts,
      PremiumBlockReason.exportCustomRange =>
        l10n.premiumBlockedExportCustomRange,
      PremiumBlockReason.viewHistory => l10n.premiumBlockedViewHistory,
      PremiumBlockReason.pinLock => l10n.premiumBlockedPinLock,
      PremiumBlockReason.unlimitedGoals => l10n.premiumBlockedUnlimitedGoals(
        PremiumLimits.maxGoals,
      ),
      PremiumBlockReason.unlimitedBudgets =>
        l10n.premiumBlockedUnlimitedBudgets(PremiumLimits.maxBudgets),
      PremiumBlockReason.unlimitedCategories =>
        l10n.premiumBlockedUnlimitedCategories(
          PremiumLimits.maxCustomCategories,
        ),
      PremiumBlockReason.unlimitedCalendarReminders =>
        l10n.premiumBlockedUnlimitedReminders(
          PremiumLimits.maxCalendarReminders,
        ),
      PremiumBlockReason.blockedCalendarLimit =>
        l10n.premiumBlockedCalendarLimit,
      PremiumBlockReason.blockedCalendarRecurring =>
        l10n.premiumBlockedCalendarRecurring,
    };
  }
}
