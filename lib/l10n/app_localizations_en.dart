// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get currencyCopLabel => 'Colombian peso';

  @override
  String get currencyUsdLabel => 'US dollar';

  @override
  String get currencyEurLabel => 'Euro';

  @override
  String get currencyArsLabel => 'Argentine peso';

  @override
  String get currencyMxnLabel => 'Mexican peso';

  @override
  String get currencySelect => 'Currency';

  @override
  String get accentAurora => 'Aurora';

  @override
  String get accentDusk => 'Dusk';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentMono => 'Monochrome';

  @override
  String get accentOcean => 'Ocean';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get userDisplayName => 'User';

  @override
  String get appShellTabDashboard => 'Home';

  @override
  String get appShellTabStats => 'Statistics';

  @override
  String get appShellTabPersonal => 'Plan';

  @override
  String get appShellTabAccounts => 'Accounts';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get calendarTabSubtitle => 'Program your expenses';

  @override
  String get calendarAddEntry => 'Add';

  @override
  String get calendarEntryTitleLabel => 'Title';

  @override
  String get calendarEntryAmountLabel => 'Estimated amount (empty = note)';

  @override
  String get calendarEmptyDay => 'Nothing scheduled for this day';

  @override
  String get calendarPlannedExpense => 'Planned expense';

  @override
  String get calendarNote => 'Note';

  @override
  String get calendarMarkPaid => 'Mark as paid';

  @override
  String get calendarSkip => 'Skip';

  @override
  String get calendarEntryCategoryLabel => 'Category (optional)';

  @override
  String get calendarEntryAccountLabel => 'Account (optional)';

  @override
  String get calendarReminderToggle => 'Remind me';

  @override
  String calendarReminderFreeHint(int max) {
    return 'Free plan: up to $max active reminders';
  }

  @override
  String get calendarReminderSameDay => 'Same day';

  @override
  String get calendarReminderDayBefore => '1 day before';

  @override
  String get calendarReminderInPast => 'The reminder time has already passed';

  @override
  String get calendarReminderChannel => 'Payment reminders';

  @override
  String calendarReminderBody(String amount, String date) {
    return 'Planned expense of $amount on $date';
  }

  @override
  String calendarReminderBodyNote(String date) {
    return 'Note for $date';
  }

  @override
  String premiumBlockedUnlimitedReminders(int max) {
    return 'You have reached the free plan limit of $max reminders.';
  }

  @override
  String get budgetCalculatorSavingsRateMenorCero =>
      'You spent more than you earned';

  @override
  String get budgetCalculatorSavingsRateMenor20 => 'You can do better';

  @override
  String get budgetCalculatorSavingsRateMenor50 => 'You\'re doing well 👍';

  @override
  String get budgetCalculatorSavingsRateMayor50 => 'Great month 🎉';

  @override
  String estimateTimeMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String estimateTimeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get noEstimate => 'No estimate';

  @override
  String get securityBiometrics => 'Screen lock';

  @override
  String get securityBiometricsSubtitle =>
      'Choose how you want to protect your app';

  @override
  String get securityPin => 'PIN';

  @override
  String get securityFingerprint => 'Fingerprint';

  @override
  String get securityFaceId => 'Face ID';

  @override
  String get securityUnlockConfirm =>
      'Confirm your identity to turn off the lock';

  @override
  String get securityError => 'Your identity could not be verified.';

  @override
  String get biometricLockTitle => 'Kaku locked';

  @override
  String get biometricLockSubtitle => 'Use your biometrics to continue';

  @override
  String get biometricLockUnlock => 'Unlock';

  @override
  String get biometricLockVerifying => 'Verifying...';

  @override
  String get biometricAuthReason => 'Confirm your identity to access Kaku';

  @override
  String get biometricEnableSubtitle => 'On · Asked when opening the app';

  @override
  String get biometricDisableSubtitle =>
      'Off · The app won\'t ask for confirmation';

  @override
  String get biometricNotConfigured => 'Could not be set up';

  @override
  String get errorLoadLockMethods => 'Error loading lock methods';

  @override
  String get enableBiometricLockReason => 'Enable biometric lock';

  @override
  String errorEnableBiometricLock(String name) {
    return 'Could not enable: $name';
  }

  @override
  String get biometricAuthFailed => 'Authentication failed. Please try again.';

  @override
  String get biometricAuthUnlocking => 'Unlocking...';

  @override
  String get createPin => 'Create PIN';

  @override
  String get createPinSubtitle => 'Choose a 4-digit PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get confirmPinSubtitle => 'Enter the PIN again';

  @override
  String get pinMismatch => 'PINs don\'t match';

  @override
  String get pinMismatchSubtitle => 'The PINs don\'t match. Please try again.';

  @override
  String get pinConfirmTitle => 'Enter your PIN';

  @override
  String pinIncorrect(int attempts) {
    return 'Incorrect PIN ($attempts failed attempts)';
  }

  @override
  String get pinIncorrectSubtitle => 'Incorrect PIN. Please try again.';

  @override
  String get securityTitle => 'Security';

  @override
  String get notSynced => 'Not synced';

  @override
  String syncLastBackup(String relative) {
    return 'Last sync: $relative';
  }

  @override
  String get exportCsvHeader =>
      'Date,Description,Category,Type,Quantity,Unit price,Total';

  @override
  String get exportPdfHeader =>
      'Date,Description,Category,Type,Qty.,Unit price,Total';

  @override
  String get exportUncategorized => 'Uncategorized';

  @override
  String get exportBalance => 'Balance';

  @override
  String get exportDate => 'Date';

  @override
  String get exportDescription => 'Description';

  @override
  String get exportCategory => 'Category';

  @override
  String get exportType => 'Type';

  @override
  String get exportAmount => 'Qty.';

  @override
  String get exportUnitPrice => 'Unit price';

  @override
  String get exportTotal => 'Total';

  @override
  String exportReportTitle(String period) {
    return 'Kaku - Report $period';
  }

  @override
  String get exportCsvShareText => 'Kaku - Transactions export';

  @override
  String exportReceiptTitle(String desc) {
    return 'Receipt - $desc';
  }

  @override
  String get exportTitle => 'Export data';

  @override
  String get exportSubtitle => 'CSV · PDF';

  @override
  String get exportCsvLabel => 'CSV';

  @override
  String get exportCsvDecription =>
      'CSV: Opens in Excel or Google Sheets for detailed analysis.';

  @override
  String get exportPdfBasicLabel => 'Basic PDF';

  @override
  String get exportPdfBasicDecription =>
      'Basic PDF: Clean transactions table, ready to print.';

  @override
  String get exportPdfWithReceiptsLabel => 'PDF with receipts';

  @override
  String get exportPdfWithReceiptsDecription =>
      'PDF with receipts: Full PDF with attached photos. 👑 Premium';

  @override
  String get thisMonthLabel => 'Current month';

  @override
  String get last3MonthsLabel => 'Last 3 months';

  @override
  String get thisYearLabel => 'This year';

  @override
  String get customRangeLabel => 'Custom range';

  @override
  String backupShareText(String date) {
    return 'Kaku Backup — $date';
  }

  @override
  String get backupGoogleDriveTitle => 'Google Drive backup';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupLocalTitle => 'Local backup';

  @override
  String get backupSubtitle => 'Free · Share the file wherever you want';

  @override
  String backupConnectedAs(Object email) {
    return '✅ Connected as $email';
  }

  @override
  String get backupConnectFailed => 'Could not connect to Google';

  @override
  String get backupCompleted => '✅ Backup completed — DB + encrypted receipts';

  @override
  String get backupSignInFirst => 'Sign in with Google first';

  @override
  String get backupDbNotFound => 'Database not found';

  @override
  String get backupErrorGeneric =>
      'Error creating the backup. Please try again.';

  @override
  String get restoreDialogTitle => 'Restore backup';

  @override
  String get restoreDialogContent =>
      'All current data will be replaced with the data from the backup.\n\nThis action cannot be undone.';

  @override
  String get restoreDialogCancel => 'Cancel';

  @override
  String get restoreDialogConfirm => 'Restore';

  @override
  String get restoreSuccess => '✅ Data restored successfully';

  @override
  String get restoreNoBackupFound => 'No backup found in Drive';

  @override
  String get restoreErrorGeneric => 'Error restoring. Please try again.';

  @override
  String get backupIncludesTitle => 'The backup includes:';

  @override
  String get backupIncludesDatabase =>
      'Database (transactions, accounts, goals)';

  @override
  String get backupIncludesReceipts => 'Receipt photos';

  @override
  String get backupIncludesEncryption =>
      'AES-256 encryption with your Google account';

  @override
  String get backupIncludesEncryptionLocal =>
      'AES-256 encryption with the password you entered';

  @override
  String get backupSignOut => 'Sign out';

  @override
  String get backupConnectGoogle => 'Connect with Google';

  @override
  String get backupUploading => 'Uploading...';

  @override
  String get backupDoNow => 'Back up now';

  @override
  String get backupRestoring => 'Restoring...';

  @override
  String get backupRestoreFromDrive => 'Restore from Drive';

  @override
  String get passwordNotEmpty => 'Password cannot be empty';

  @override
  String get backupGenerateSuccess => '✅ Backup created successfully';

  @override
  String get backupPermissionDenied => 'No permission to access storage';

  @override
  String get selectedFileBackup => 'Select the Kaku backup file';

  @override
  String get backupFileNotFound => 'Backup file not found';

  @override
  String get backupFileNotValid =>
      'The file is not a valid Kaku backup or is corrupted';

  @override
  String get backupMessageShare =>
      'The file is saved on your device. You can move it to Google Drive, WhatsApp or wherever you prefer using the Share button. The password is required to decrypt (restore) and encrypt the backup file.';

  @override
  String get backupBtnCreating => 'Creating backup...';

  @override
  String get backupBtnCreateShare => 'Create and share backup';

  @override
  String get backupBtnRestore => 'Restore from .zip file';

  @override
  String get backupBtnRestoring => 'Restoring...';

  @override
  String notifBudgetExceededTitle(String emoji) {
    return '$emoji Budget exceeded';
  }

  @override
  String notifBudgetWarningTitle(String emoji, String percent) {
    return '$emoji Budget at $percent%';
  }

  @override
  String notifBudgetExceededBody(String spent, String limit, String category) {
    return 'You spent $spent of $limit on $category this month';
  }

  @override
  String notifBudgetWarningBody(String spent, String limit, String category) {
    return 'You\'re at $spent of $limit on $category';
  }

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifActivatingBudget => 'On · Budget alerts';

  @override
  String get notifDeactivatingBudget => 'Off';

  @override
  String get notifPermissionTitle => 'Notification permission';

  @override
  String get notifPermissionSubtitle =>
      'Kaku needs permission to send you alerts when you get close to a budget limit.\n\nEnable it in your device Settings.';

  @override
  String get premiumBlockedBackupDrive =>
      'Google Drive backup is a premium feature.\nWith the free plan you can make a local backup.';

  @override
  String get premiumBlockedExportPdfWithReceipts =>
      'PDF with receipt images is a premium feature.\nWith the free plan you can export CSV or basic PDF.';

  @override
  String get premiumBlockedExportCustomRange =>
      'Custom date range is a premium feature.\nWith the free plan you can export the current month.';

  @override
  String get premiumBlockedViewHistory =>
      'History older than one month is a premium feature.';

  @override
  String get premiumBlockedPinLock =>
      'PIN or biometric lock is a premium feature.';

  @override
  String premiumBlockedUnlimitedGoals(Object max) {
    return 'You have reached the free plan limit of $max goals.';
  }

  @override
  String premiumBlockedUnlimitedBudgets(Object max) {
    return 'You have reached the free plan limit of $max budgets.';
  }

  @override
  String premiumBlockedUnlimitedCategories(Object max) {
    return 'You have reached the free plan limit of $max custom categories.';
  }

  @override
  String permissionTitle(String source) {
    return '$source permission';
  }

  @override
  String permissionDesc(String source) {
    return 'Kaku needs access to your $source to attach receipts. Enable it in your device Settings.';
  }

  @override
  String messageNoReceipt(String source) {
    return 'Could not open the $source';
  }

  @override
  String get attachedReceipt => 'Attached receipt';

  @override
  String receiptName(String name) {
    return 'Receipt · $name';
  }

  @override
  String get toPinchToZoom => 'Pinch to zoom';

  @override
  String get receiptNotFound => 'Could not load the receipt';

  @override
  String get formRequired => 'Required field';

  @override
  String get formName => 'Name';

  @override
  String get formBalanceInitial => 'Initial balance';

  @override
  String get formColor => 'Color';

  @override
  String get formIcon => 'Icon';

  @override
  String get formAmountMajor => 'Must be greater than 0';

  @override
  String get formContributeMajorTotal =>
      'You can\'t contribute more than the total';

  @override
  String get formAccountNoBalance => 'Account has insufficient balance';

  @override
  String get formLimitMajor => 'Enter a limit greater than 0';

  @override
  String formMajorOrEqual(int value) {
    return 'Must be greater than or equal to $value';
  }

  @override
  String get formPassword => 'Password';

  @override
  String accountsTitle(int isPlural) {
    String _temp0 = intl.Intl.pluralLogic(
      isPlural,
      locale: localeName,
      other: 'Account',
      one: 'Accounts',
    );
    return '$_temp0';
  }

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeDebit => 'Debit';

  @override
  String get accountTypeCredit => 'Credit';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountDetail => 'Account details';

  @override
  String get accountNotFound => 'Account not found';

  @override
  String get myAccountName => 'My account';

  @override
  String get accountType => 'Account type';

  @override
  String get accountBalanceMessage =>
      'This is your account\'s current balance. Future transactions will adjust this value';

  @override
  String get accountUpdateSuccess => 'Account updated';

  @override
  String get accountCreateSuccess => 'Account created';

  @override
  String get accountArchiveSuccess => 'Account archived';

  @override
  String get accountsErrorLoading => 'Error loading accounts';

  @override
  String get accountsNotCreated => 'You haven\'t created any accounts';

  @override
  String get myAccounts => 'My accounts';

  @override
  String get accountNew => 'New account';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get accountInflow => 'Inflow';

  @override
  String get accountOutflow => 'Outflow';

  @override
  String get balanceTotal => 'Total balance';

  @override
  String accountsActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active accounts',
      one: '1 active account',
    );
    return '$_temp0';
  }

  @override
  String get thisMonth => 'this month';

  @override
  String get savings => 'Savings';

  @override
  String categoriesTitle(int isPlural) {
    String _temp0 = intl.Intl.pluralLogic(
      isPlural,
      locale: localeName,
      other: 'Category',
      one: 'Categories',
    );
    return '$_temp0';
  }

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryLeisure => 'Leisure';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categorySavings => 'Savings';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryFreelance => 'Freelance';

  @override
  String get categorySales => 'Sales';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryInvestments => 'Investments';

  @override
  String get categoryOtherIncome => 'Other income';

  @override
  String get notSetBudgetCategory => 'No budget set for this category';

  @override
  String spentInMonth(String month) {
    return 'Spent in $month';
  }

  @override
  String get categoryLimit => 'Limit';

  @override
  String categorySpentUsed(String spent) {
    return '$spent used';
  }

  @override
  String categorySpentLeft(String spent) {
    return '$spent left';
  }

  @override
  String get categoryEmptyTitle => 'No categories';

  @override
  String get categoryEmptySubtitle =>
      'Tap \'+ New\' to create your first category';

  @override
  String get errorLoadCategories => 'Error loading categories';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get categoryNotFound => 'Category not found';

  @override
  String get categoryEditSuccess => 'Category updated';

  @override
  String get categoryCreateSuccess => 'Category created';

  @override
  String get categoryDeactivateTitle => 'Deactivate category';

  @override
  String categoryDeactivateSubtitle(
    String emoji,
    String category,
    int txCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      txCount,
      locale: localeName,
      other: '$txCount associated transactions',
      one: '1 associated transaction',
    );
    return '$emoji $category has $_temp0.\n\nOnce deactivated, it will no longer appear when adding expenses, but existing transactions are kept.';
  }

  @override
  String get categoryNotDeleted => 'Cannot be deleted';

  @override
  String categoryNotDeletedSubtitle(
    String emoji,
    String category,
    int txCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      txCount,
      locale: localeName,
      other: '$txCount associated transactions',
      one: '1 associated transaction',
    );
    return '$emoji $category has $_temp0.\n\nTo avoid losing your history, you can only deactivate it. It will remain visible in past transactions but won\'t appear when adding new expenses.';
  }

  @override
  String get categoryDeleteConfirm => 'Delete category';

  @override
  String categoryDeleteConfirmSubtitle(String emoji, String category) {
    return 'Delete $emoji $category?\n\nThis category has no transactions, so it can be permanently deleted.';
  }

  @override
  String countActiveCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active categories',
      one: '1 active category',
    );
    return '$_temp0';
  }

  @override
  String categoryTitle(int isPlural) {
    String _temp0 = intl.Intl.pluralLogic(
      isPlural,
      locale: localeName,
      other: 'Category',
      one: 'Categories',
    );
    return '$_temp0';
  }

  @override
  String get availableBalance => 'Available balance';

  @override
  String get welcomeToKaku => 'Welcome to Kaku 👋';

  @override
  String get welcomeToKakuSubtitle => 'Your pocket, under control';

  @override
  String welcomeToKakuName(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get errorLoadBudget => 'Error loading budgets';

  @override
  String bannerStateExceeded(String spent, String budget, String over) {
    return 'You\'ve spent $spent and your limit was $budget. You went over by $over this month.';
  }

  @override
  String bannerStateCritical(String avg, String projection, String over) {
    return 'At this pace ($avg/day) you\'ll spend $projection this month, $over more than your budget.';
  }

  @override
  String bannerStateWarning(String projection, String budget) {
    return 'At the current pace you could reach $projection this month vs your budget of $budget.';
  }

  @override
  String bannerStateNearEnd(int daysLeft, String percentage) {
    return '$daysLeft days left and you\'ve already used $percentage of your budget.';
  }

  @override
  String get bannerConfigExceeded => 'Budget exceeded';

  @override
  String get bannerConfigCritical => 'You\'re going to exceed your budget';

  @override
  String get bannerConfigWarning => 'Check your spending pace';

  @override
  String get bannerConfigNearEnd => 'Almost at the monthly limit';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get contributeGoal => 'Contribute to goal';

  @override
  String get btnContribute => 'Contribute';

  @override
  String get contributeAll => 'All';

  @override
  String leftToContribute(String amount) {
    return '$amount left to complete';
  }

  @override
  String get amountContributeToday => 'Amount to contribute today';

  @override
  String get newProgress => 'New progress';

  @override
  String get contributeSuccess => 'Contribution made';

  @override
  String get btnConfirmContribute => 'Confirm contribution';

  @override
  String get newGoalTitle => 'New goal';

  @override
  String nameGoal(String name) {
    return 'Goal: $name';
  }

  @override
  String get amountGoal => 'Target amount';

  @override
  String get dateGoal => 'Deadline (optional)';

  @override
  String get dateGoalMessage =>
      'If you don\'t enter a date, the system will use your savings history to estimate when you could reach your goal.';

  @override
  String get goalUpdateSuccess => 'Goal updated';

  @override
  String get goalCreateSuccess => 'Goal created';

  @override
  String get btnUpdateGoal => 'Update goal';

  @override
  String get btnCreateGoal => 'Create goal';

  @override
  String goalEditTitle(String name) {
    return 'Edit goal $name';
  }

  @override
  String get goalCompleteSuccess => 'Goal completed';

  @override
  String get goalDeleting => 'Deleting goal';

  @override
  String goalsActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active · ',
      one: '1 active · ',
    );
    return '$_temp0';
  }

  @override
  String goalComplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed',
      one: '1 completed',
    );
    return '$_temp0';
  }

  @override
  String get goalsNoActive => 'No active goals';

  @override
  String get premiumSubtitle => 'Take your finances\nto the next level';

  @override
  String get premiumContent =>
      'All the tools you need to\nhave full control of your money.';

  @override
  String get premiumPaymentTitle => '✨ ONE-TIME PAYMENT — NO SUBSCRIPTION';

  @override
  String get premiumPaymentSubtitle => 'forever · pay once';

  @override
  String get premiumUnlockKaku => 'Unlock Kaku Premium';

  @override
  String get welcomeToPremium => '🎉 Welcome to Kaku Premium!';

  @override
  String get billingPending =>
      'Payment pending. We\'ll notify you when it\'s confirmed.';

  @override
  String get billingProductNotFound =>
      'Product not found in the store. Check your connection and try again.';

  @override
  String get billingFailed => 'Error processing the payment. Please try again.';

  @override
  String get labelUnlockTitle => 'EVERYTHING YOU UNLOCK';

  @override
  String get billingRestorePurchase => 'Restore purchase';

  @override
  String get billingCodePromo => 'Have a discount code?';

  @override
  String get billingNoteLegal =>
      'One-time payment · No subscription · No recurring charges';

  @override
  String get verifyingPurchase => 'Verifying purchase...';

  @override
  String get verifyingPurchaseSuccess => '✅ Purchase restored successfully';

  @override
  String get billingRestorePurchaseNotFound =>
      'No previous purchase found linked to your Google account.';

  @override
  String get billingRestorePurchaseError =>
      'Error restoring. Please try again.';

  @override
  String get premiumFeatureBackupDrive => 'Automatic backup to Google Drive';

  @override
  String get premiumFeatureBackupDriveSubtitle =>
      'Sync your database and receipts to the cloud with one tap';

  @override
  String get premiumFeatureExportPdf => 'PDF with receipt photos';

  @override
  String get premiumFeatureExportPdfSubtitle =>
      'Export full reports with the attached images of each purchase';

  @override
  String get premiumFeatureExportCustomRange => 'Custom date range';

  @override
  String get premiumFeatureExportCustomRangeSubtitle =>
      'Export any time period, not just the current month';

  @override
  String get premiumFeatureUnlimitedGoals => 'Unlimited goals';

  @override
  String get premiumFeatureUnlimitedGoalsSubtitle =>
      'Create all the savings goals you need with no restrictions';

  @override
  String get premiumFeatureUnlimitedBudgets => 'Unlimited budgets';

  @override
  String get premiumFeatureUnlimitedBudgetsSubtitle =>
      'Set limits for all your categories, not just 3';

  @override
  String get premiumFeatureUnlimitedCategories => 'Unlimited custom categories';

  @override
  String get premiumFeatureUnlimitedCategoriesSubtitle =>
      'Organize your expenses with as many categories as you want';

  @override
  String get premiumFeaturePinLock => 'PIN or biometric lock';

  @override
  String get premiumFeaturePinLockSubtitle =>
      'Protect your financial information with fingerprint, Face ID or your own PIN';

  @override
  String get premiumFeatureViewHistory => 'Full statistics history';

  @override
  String get premiumFeatureViewHistorySubtitle =>
      'Analyze your spending patterns in any past period';

  @override
  String get redeemCodeErrorInvalid => 'Invalid code. Check it and try again.';

  @override
  String get redeemCodeErrorAlreadyUsed =>
      'This code has already been redeemed on this device.';

  @override
  String get redeemCode => 'Redeem code';

  @override
  String get redeemCodeSubtitle => 'Enter your discount or premium access code';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeTitle => 'Color theme';

  @override
  String get themeSubtitle => 'Choose the app\'s accent color';

  @override
  String get themeModeTitle => 'Dark mode';

  @override
  String get themeModeSubtitle =>
      'Turn dark mode on, or turn it off to use the light theme';

  @override
  String get regionalTitle => 'Regional';

  @override
  String get currencyTitle => 'Currency';

  @override
  String get budgetsSectionTitle => 'Budgets';

  @override
  String get budgetByCategoryTitle => 'Budgets by category';

  @override
  String budgetByCategorySubtitle(num count, Object monthYear) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configured',
      one: '1 configured',
    );
    return '$monthYear - $_temp0';
  }

  @override
  String get dataTitle => 'Data';

  @override
  String get storageLocalTitle => 'Local storage';

  @override
  String get storageNoReceipts => 'No saved receipts';

  @override
  String storageSummary(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$size · $_temp0';
  }

  @override
  String get dangerZoneTitle => 'Danger zone';

  @override
  String get deleteDataAllTitle => 'Delete all data';

  @override
  String get deleteDataAllSubtitle => 'Removes all app data';

  @override
  String get aboutTitle => 'About';

  @override
  String get versionTitle => 'Version';

  @override
  String get deleteText => 'DELETE';

  @override
  String get errorDeletingData => 'Error deleting data';

  @override
  String get messageDataAllDeleted =>
      'This action is permanent and irreversible. All Kaku data will be removed from your device.';

  @override
  String get titleDeleteList => 'The following will be permanently deleted:';

  @override
  String get deleteListTransactions => 'All transactions';

  @override
  String get deleteListAccounts => 'All accounts';

  @override
  String get deleteListGoals => 'All goals and contributions';

  @override
  String get deleteListBudgets => 'All budgets';

  @override
  String get deleteListCategories => 'All custom categories';

  @override
  String get deleteListReceipts => 'All receipt photos';

  @override
  String get deleteListSettings => 'All app settings';

  @override
  String get writeWordDeleted => 'Type DELETE to confirm';

  @override
  String get selectedDatesRange => 'Select a date range';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String thisYear(int year) {
    return 'Year $year';
  }

  @override
  String get rangeCustom => 'Custom range';

  @override
  String get formatTitle => 'Format';

  @override
  String get csvDecription => 'To open in Excel or Google Sheets.';

  @override
  String get pdfBasic => 'Basic PDF';

  @override
  String get pdfBasicDecription => 'Transactions table without photos.';

  @override
  String get pdfWithReceipts => 'PDF with receipt photos';

  @override
  String get pdfWithReceiptsDecription => 'Full PDF with attached photos.';

  @override
  String get periodTitle => 'Period';

  @override
  String get rangeTitle => 'Date range';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the app language';

  @override
  String get languageSystem => 'Device language';

  @override
  String budgetTitle(int plural) {
    String _temp0 = intl.Intl.pluralLogic(
      plural,
      locale: localeName,
      other: 'Budget',
      one: 'Budgets',
    );
    return '$_temp0';
  }

  @override
  String get deleteBudgetConfirm => 'Delete budget';

  @override
  String deleteBudgetConfirmSubtitle(String emoji, String category) {
    return 'Delete the budget for $emoji $category for this month?';
  }

  @override
  String get limitMonth => 'Monthly limit';

  @override
  String get acumulateSurplus => 'Roll over surplus';

  @override
  String get acumulateSurplusSubtitle =>
      'If you spend less than planned, the surplus is added to next month.';

  @override
  String get acumulateBudget => 'Roll over budget';

  @override
  String get btnCreateBudget => 'Create budget';

  @override
  String get budgetTotal => 'Total budget';

  @override
  String get budgetWornOut => 'Spent';

  @override
  String get budgetAvailable => 'Available';

  @override
  String get unlimited => 'No limit';

  @override
  String budgetWornOutDescription(String spent) {
    return 'Spent: $spent';
  }

  @override
  String budgetRemainingOrExceeded(int remaining, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Exceeded',
      one: 'Left',
    );
    return '$_temp0 $amount';
  }

  @override
  String get editBudget => 'Edit budget';

  @override
  String get createBudget => 'New budget';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileEmailLabel => 'Email (Read only)';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get storageClearReceipts => 'Clear receipts';

  @override
  String storageReceiptsCleared(int count, String size) {
    return '$count receipt photos ($size) will be deleted from the device.\n\nTransactions are kept but will no longer have an attached photo.';
  }

  @override
  String get storageReceiptsLabel => 'Receipt photos';

  @override
  String storageReceiptsSummary(int count, String size) {
    return '$count receipt photos · $size';
  }

  @override
  String get storageNoteInfo =>
      'Photos are saved in the app\'s private storage and never leave your device.';

  @override
  String get storageCleaning => 'Clearing...';

  @override
  String storageClearedInfo(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receipts will be deleted ($size)',
      one: 'One receipt will be deleted',
      zero: 'No receipts to clear',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsEmptyThisMonth => 'No statistics for this month or period';

  @override
  String get statsTotalLabel => 'Total';

  @override
  String get statsMonthLabel => 'Month';

  @override
  String get statsQuarterLabel => 'Quarter';

  @override
  String get statsYearLabel => 'Year';

  @override
  String get statsDonutTitle => 'Breakdown';

  @override
  String statsDonutSubtitle(String monthName) {
    return 'By category · $monthName';
  }

  @override
  String get statsTrendTitle => 'Trend';

  @override
  String get statsTrendSubtitle => 'Last 6 months';

  @override
  String get statsTrendMonthVsPreviousTitle => 'Month vs previous';

  @override
  String statsTrendMonthVsPreviousSubtitle(
    String previousLabel,
    String currentLabel,
  ) {
    return '$previousLabel vs $currentLabel';
  }

  @override
  String get statsExpensesDiaryTitle => 'Daily spending';

  @override
  String statsExpensesDiarySubtitle(int daysInMonth) {
    String _temp0 = intl.Intl.pluralLogic(
      daysInMonth,
      locale: localeName,
      other: '$daysInMonth days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get statsLast3MonthsTitle => 'Last 3 months';

  @override
  String get statsLast3MonthsSubtitle => 'Total spending per month';

  @override
  String get statsLastYearTitle => 'Last 12 months';

  @override
  String get statsTrend6MonthsTitle => 'Trend · Last 6 months';

  @override
  String get statsTrend6MonthsSubtitle =>
      'Unlock Premium to see your full spending history.';

  @override
  String statsDailyBarChartTitle(String avg) {
    return 'Average: $avg/day';
  }

  @override
  String statsDailyBarChartTooltip(int day, String money) {
    return 'Day $day\n$money';
  }

  @override
  String get statsDailyBarChartAverage => 'Average';

  @override
  String get statsMonthComparationExpense => 'You spent';

  @override
  String statsMonthComparationLegend(String percent, int improved) {
    String _temp0 = intl.Intl.pluralLogic(
      improved,
      locale: localeName,
      other: 'more',
      one: 'less',
    );
    return '$percent% $_temp0';
  }

  @override
  String get statsIncomeExpenseTitle => 'Income vs expenses';

  @override
  String statsIncomeExpenseSubtitle(int months) {
    return 'Last $months months';
  }

  @override
  String statsIncomeExpenseNet(String amount) {
    return 'Period net: $amount';
  }

  @override
  String get statsIncomeExpenseLocked => 'Available with Premium';

  @override
  String get premiumFeatureIncomeExpense => 'Income vs expenses chart';

  @override
  String get premiumFeatureIncomeExpenseSubtitle =>
      'Compare what comes in and what goes out each month';

  @override
  String get transactionTypeFilterAll => 'All';

  @override
  String get transactionTypeFilterByCategory => 'By category';

  @override
  String transactionTypeExpense(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expenses',
      one: 'Expense',
    );
    return '$_temp0';
  }

  @override
  String transactionTypeIncome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Income',
      one: 'Income',
    );
    return '$_temp0';
  }

  @override
  String transactionTypeTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Transfers',
      one: 'Transfer',
    );
    return '$_temp0';
  }

  @override
  String get transactionsHistoryEmpty => 'Transaction history is empty';

  @override
  String transactionTitle(int plural) {
    String _temp0 = intl.Intl.pluralLogic(
      plural,
      locale: localeName,
      other: 'Transaction',
      one: 'Transactions',
    );
    return '$_temp0';
  }

  @override
  String transactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get transactionEmpty => 'No transactions';

  @override
  String transactionTotalLabel(String currency) {
    return 'Total · $currency';
  }

  @override
  String get transactionDescriptionLabel => 'Description';

  @override
  String get transactionExpenseSaved => 'Expense saved';

  @override
  String get transactionIncomeSaved => 'Income saved';

  @override
  String get transactionTransferSaved => 'Transfer saved';

  @override
  String get transactionSavedGeneric => 'Transaction saved';

  @override
  String get transactionExpenseBtnSaved => 'Save expense';

  @override
  String get transactionIncomeBtnSaved => 'Save income';

  @override
  String get transactionTransferBtnSaved => 'Save transfer';

  @override
  String get transactionBtnSavedGeneric => 'Save transaction';

  @override
  String get addTransactionTitle => 'New transaction';

  @override
  String get transferMessageEmpty =>
      'Register at least two accounts to be able to create transfers';

  @override
  String transferAmountLabel(String currency) {
    return 'Quantity or Amount · $currency';
  }

  @override
  String get transferAccountDestinationLabel => 'Destination account';

  @override
  String get transferAccountOriginLabel => 'Source account';

  @override
  String get transferAccountDestEmpty => 'Select a destination account';

  @override
  String get transferAccountOriginEmpty => 'Select a source account';

  @override
  String get transferAccountDestEqualOrigin =>
      'The destination account must not be the same as the source account';

  @override
  String get transferAccountOriginEqualDest =>
      'The source account must not be the same as the destination account';

  @override
  String get deleteTransactionConfirm => 'Delete transaction';

  @override
  String get deleteTransactionDesc => 'This action cannot be undone. Delete?';

  @override
  String get deleteTransactionSuccess => 'Transaction deleted';

  @override
  String get transactionNotFound => 'Transaction not found';

  @override
  String get messageTransactionAccountEmpty =>
      'Register at least one account to be able to create transactions';

  @override
  String amountOrValueUnit(String currency) {
    return 'Amount or unit value · $currency';
  }

  @override
  String get amountLabel => 'Quantity';

  @override
  String get valueUnitLabel => 'Unit value';

  @override
  String get viewReceipt => 'View receipt';

  @override
  String get receiptEmpty => 'No receipt';

  @override
  String get totalTransactionsLabel => 'Total';

  @override
  String get transactionDateCompleteLabel => 'Date and time';

  @override
  String get transactionRecurrentLabel => 'Recurring';

  @override
  String transactionIsRecurringLabel(int recurring) {
    String _temp0 = intl.Intl.pluralLogic(
      recurring,
      locale: localeName,
      other: 'No',
      one: 'Yes',
    );
    return '$_temp0';
  }

  @override
  String get transactionReceiptLabel => 'Receipt photo';

  @override
  String transactionEditTitle(int id) {
    return 'Edit transaction #$id';
  }

  @override
  String get transactionDeletingLabel => 'Deleting transaction';

  @override
  String get balance => 'Balance';

  @override
  String get errorInsufficientFunds =>
      'Insufficient funds for this transaction';

  @override
  String get errorAccountNotFound => 'Account not found';

  @override
  String get errorInvalidAmount => 'Invalid amount';

  @override
  String get errorNetworkError => 'Network error';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get undo => 'Undo';

  @override
  String get btnClose => 'Close';

  @override
  String get archived => 'Archived';

  @override
  String get btnConfiguration => 'Settings';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnViewPremium => 'View Premium';

  @override
  String get btnOpenSettings => 'Open Settings';

  @override
  String get btnResetZoom => 'Reset zoom';

  @override
  String get btnAdd => 'Add';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnUpdate => 'Update';

  @override
  String get btnCreate => 'Create';

  @override
  String get btnArchive => 'Archive or Deactivate';

  @override
  String get btnViewDetail => 'View details';

  @override
  String btnNew(int femenine) {
    String _temp0 = intl.Intl.pluralLogic(
      femenine,
      locale: localeName,
      other: 'New',
      one: 'New',
    );
    return '$_temp0';
  }

  @override
  String get btnDeactivate => 'Deactivate';

  @override
  String get btnActivate => 'Activate';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnUnderstood => 'Got it';

  @override
  String get btnDisableInstead => 'Deactivate instead';

  @override
  String get btnRetry => 'Retry';

  @override
  String get btnSave => 'Save';

  @override
  String get btnClear => 'Clear';

  @override
  String get btnSaveChanges => 'Save changes';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get emojiLabel => 'Emoji';

  @override
  String get emojiHint => 'Choose an emoji';

  @override
  String get emojiHintSearch => 'Search emoji...';

  @override
  String get premiumLimitReached => 'Limit reached';

  @override
  String get camera => 'Camera';

  @override
  String get galery => 'Gallery';

  @override
  String get selectedColor => 'Select a color';

  @override
  String get noDescription => 'No description';

  @override
  String get history => 'History';

  @override
  String get preview => 'Preview';

  @override
  String get average => 'Average';

  @override
  String get majorSpending => 'Highest expense';

  @override
  String get viewAll => 'View all';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get notAvailable => 'Not available';

  @override
  String get generatingLabel => 'Generating...';

  @override
  String get localeEn => 'English';

  @override
  String get localeEs => 'Spanish';

  @override
  String get selectMonthYear => 'Select month and year';
}
