import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @currencyCopLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso colombiano'**
  String get currencyCopLabel;

  /// No description provided for @currencyUsdLabel.
  ///
  /// In es, this message translates to:
  /// **'Dólar estadounidense'**
  String get currencyUsdLabel;

  /// No description provided for @currencyEurLabel.
  ///
  /// In es, this message translates to:
  /// **'Euro'**
  String get currencyEurLabel;

  /// No description provided for @currencyArsLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso argentino'**
  String get currencyArsLabel;

  /// No description provided for @currencyMxnLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso mexicano'**
  String get currencyMxnLabel;

  /// No description provided for @currencySelect.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currencySelect;

  /// No description provided for @accentAurora.
  ///
  /// In es, this message translates to:
  /// **'Aurora'**
  String get accentAurora;

  /// No description provided for @accentDusk.
  ///
  /// In es, this message translates to:
  /// **'Atardecer'**
  String get accentDusk;

  /// No description provided for @accentViolet.
  ///
  /// In es, this message translates to:
  /// **'Violeta'**
  String get accentViolet;

  /// No description provided for @accentMono.
  ///
  /// In es, this message translates to:
  /// **'Monocromático'**
  String get accentMono;

  /// No description provided for @accentOcean.
  ///
  /// In es, this message translates to:
  /// **'Océano'**
  String get accentOcean;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @userDisplayName.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get userDisplayName;

  /// No description provided for @appShellTabDashboard.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get appShellTabDashboard;

  /// No description provided for @appShellTabStats.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get appShellTabStats;

  /// No description provided for @appShellTabPersonal.
  ///
  /// In es, this message translates to:
  /// **'Planificar'**
  String get appShellTabPersonal;

  /// No description provided for @appShellTabAccounts.
  ///
  /// In es, this message translates to:
  /// **'Cuentas'**
  String get appShellTabAccounts;

  /// No description provided for @calendarTab.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendarTab;

  /// No description provided for @calendarTabSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Programa tus gastos'**
  String get calendarTabSubtitle;

  /// No description provided for @calendarAddEntry.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get calendarAddEntry;

  /// No description provided for @calendarEntryTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get calendarEntryTitleLabel;

  /// No description provided for @calendarEntryAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto estimado (vacío = nota)'**
  String get calendarEntryAmountLabel;

  /// No description provided for @calendarEmptyDay.
  ///
  /// In es, this message translates to:
  /// **'Nada programado para este día'**
  String get calendarEmptyDay;

  /// No description provided for @calendarPlannedExpense.
  ///
  /// In es, this message translates to:
  /// **'Gasto programado'**
  String get calendarPlannedExpense;

  /// No description provided for @calendarNote.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get calendarNote;

  /// No description provided for @calendarMarkPaid.
  ///
  /// In es, this message translates to:
  /// **'Marcar como pagado'**
  String get calendarMarkPaid;

  /// No description provided for @calendarSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get calendarSkip;

  /// No description provided for @calendarEntryCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría (opcional)'**
  String get calendarEntryCategoryLabel;

  /// No description provided for @calendarEntryAccountLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuenta (opcional)'**
  String get calendarEntryAccountLabel;

  /// No description provided for @calendarReminderToggle.
  ///
  /// In es, this message translates to:
  /// **'Recordarme'**
  String get calendarReminderToggle;

  /// No description provided for @calendarReminderFreeHint.
  ///
  /// In es, this message translates to:
  /// **'Plan gratis: hasta {max} recordatorios activos'**
  String calendarReminderFreeHint(int max);

  /// No description provided for @calendarReminderSameDay.
  ///
  /// In es, this message translates to:
  /// **'El mismo día'**
  String get calendarReminderSameDay;

  /// No description provided for @calendarReminderDayBefore.
  ///
  /// In es, this message translates to:
  /// **'1 día antes'**
  String get calendarReminderDayBefore;

  /// No description provided for @calendarReminderInPast.
  ///
  /// In es, this message translates to:
  /// **'La hora del recordatorio ya pasó'**
  String get calendarReminderInPast;

  /// No description provided for @calendarReminderChannel.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de pagos'**
  String get calendarReminderChannel;

  /// No description provided for @calendarReminderBody.
  ///
  /// In es, this message translates to:
  /// **'Gasto programado de {amount} para el {date}'**
  String calendarReminderBody(String amount, String date);

  /// No description provided for @calendarReminderBodyNote.
  ///
  /// In es, this message translates to:
  /// **'Nota para el {date}'**
  String calendarReminderBodyNote(String date);

  /// No description provided for @premiumBlockedUnlimitedReminders.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al límite de {max} recordatorios del plan gratis.'**
  String premiumBlockedUnlimitedReminders(int max);

  /// No description provided for @calendarLimitTitle.
  ///
  /// In es, this message translates to:
  /// **'Límite del mes'**
  String get calendarLimitTitle;

  /// No description provided for @calendarLimitLocked.
  ///
  /// In es, this message translates to:
  /// **'Límite mensual y gasto sugerido por día'**
  String get calendarLimitLocked;

  /// No description provided for @calendarLimitEmpty.
  ///
  /// In es, this message translates to:
  /// **'Define cuánto quieres gastar este mes'**
  String get calendarLimitEmpty;

  /// No description provided for @calendarLimitSet.
  ///
  /// In es, this message translates to:
  /// **'Definir límite'**
  String get calendarLimitSet;

  /// No description provided for @calendarLimitAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Límite mensual · {currency}'**
  String calendarLimitAmountLabel(String currency);

  /// No description provided for @calendarLimitCarryNote.
  ///
  /// In es, this message translates to:
  /// **'Se mantiene en los meses siguientes hasta que lo cambies. Escribe 0 para quitarlo.'**
  String get calendarLimitCarryNote;

  /// No description provided for @calendarLimitSpent.
  ///
  /// In es, this message translates to:
  /// **'Gastado'**
  String get calendarLimitSpent;

  /// No description provided for @calendarLimitPlanned.
  ///
  /// In es, this message translates to:
  /// **'Programado'**
  String get calendarLimitPlanned;

  /// No description provided for @calendarLimitAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get calendarLimitAvailable;

  /// No description provided for @calendarLimitDaily.
  ///
  /// In es, this message translates to:
  /// **'Puedes gastar ≈ {amount} por día'**
  String calendarLimitDaily(String amount);

  /// No description provided for @calendarLimitExceeded.
  ///
  /// In es, this message translates to:
  /// **'Superaste el límite por {amount}'**
  String calendarLimitExceeded(String amount);

  /// No description provided for @calendarRepeatLabel.
  ///
  /// In es, this message translates to:
  /// **'Repetir'**
  String get calendarRepeatLabel;

  /// No description provided for @calendarRepeatNone.
  ///
  /// In es, this message translates to:
  /// **'Una vez'**
  String get calendarRepeatNone;

  /// No description provided for @calendarRepeatWeekly.
  ///
  /// In es, this message translates to:
  /// **'Cada semana'**
  String get calendarRepeatWeekly;

  /// No description provided for @calendarRepeatMonthly.
  ///
  /// In es, this message translates to:
  /// **'Cada mes'**
  String get calendarRepeatMonthly;

  /// No description provided for @calendarDeleteSeries.
  ///
  /// In es, this message translates to:
  /// **'Eliminar esta y las siguientes'**
  String get calendarDeleteSeries;

  /// No description provided for @premiumFeatureLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Función premium'**
  String get premiumFeatureLockedTitle;

  /// No description provided for @premiumBlockedCalendarLimit.
  ///
  /// In es, this message translates to:
  /// **'El límite mensual con gasto sugerido por día es una función premium.'**
  String get premiumBlockedCalendarLimit;

  /// No description provided for @premiumBlockedCalendarRecurring.
  ///
  /// In es, this message translates to:
  /// **'Los gastos recurrentes son una función premium.'**
  String get premiumBlockedCalendarRecurring;

  /// No description provided for @premiumFeatureCalendarPlus.
  ///
  /// In es, this message translates to:
  /// **'Calendario Plus'**
  String get premiumFeatureCalendarPlus;

  /// No description provided for @premiumFeatureCalendarPlusSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios ilimitados, gastos recurrentes y límite mensual con gasto sugerido por día'**
  String get premiumFeatureCalendarPlusSubtitle;

  /// No description provided for @budgetCalculatorSavingsRateMenorCero.
  ///
  /// In es, this message translates to:
  /// **'Gastaste más de lo que ganaste'**
  String get budgetCalculatorSavingsRateMenorCero;

  /// No description provided for @budgetCalculatorSavingsRateMenor20.
  ///
  /// In es, this message translates to:
  /// **'Puedes mejorar'**
  String get budgetCalculatorSavingsRateMenor20;

  /// No description provided for @budgetCalculatorSavingsRateMenor50.
  ///
  /// In es, this message translates to:
  /// **'Vas bien 👍'**
  String get budgetCalculatorSavingsRateMenor50;

  /// No description provided for @budgetCalculatorSavingsRateMayor50.
  ///
  /// In es, this message translates to:
  /// **'Buen mes 🎉'**
  String get budgetCalculatorSavingsRateMayor50;

  /// No description provided for @estimateTimeMonths.
  ///
  /// In es, this message translates to:
  /// **'{months, plural, =1{1 mes} other{{months} meses}}'**
  String estimateTimeMonths(int months);

  /// No description provided for @estimateTimeDays.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1{1 día} other{{days} días}}'**
  String estimateTimeDays(int days);

  /// No description provided for @noEstimate.
  ///
  /// In es, this message translates to:
  /// **'Sin estimación'**
  String get noEstimate;

  /// No description provided for @securityBiometrics.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo de pantalla'**
  String get securityBiometrics;

  /// No description provided for @securityBiometricsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige cómo quieres proteger tu app'**
  String get securityBiometricsSubtitle;

  /// No description provided for @securityPin.
  ///
  /// In es, this message translates to:
  /// **'PIN'**
  String get securityPin;

  /// No description provided for @securityFingerprint.
  ///
  /// In es, this message translates to:
  /// **'Huella digital'**
  String get securityFingerprint;

  /// No description provided for @securityFaceId.
  ///
  /// In es, this message translates to:
  /// **'Face ID'**
  String get securityFaceId;

  /// No description provided for @securityUnlockConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu identidad para desactivar el bloqueo'**
  String get securityUnlockConfirm;

  /// No description provided for @securityError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar tu identidad.'**
  String get securityError;

  /// No description provided for @biometricLockTitle.
  ///
  /// In es, this message translates to:
  /// **'Kaku bloqueado'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usa tu biometría para continuar'**
  String get biometricLockSubtitle;

  /// No description provided for @biometricLockUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get biometricLockUnlock;

  /// No description provided for @biometricLockVerifying.
  ///
  /// In es, this message translates to:
  /// **'Verificando...'**
  String get biometricLockVerifying;

  /// No description provided for @biometricAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu identidad para acceder a Kaku'**
  String get biometricAuthReason;

  /// No description provided for @biometricEnableSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activo · Se pide al abrir la app'**
  String get biometricEnableSubtitle;

  /// No description provided for @biometricDisableSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inactivo · La app no pide confirmación'**
  String get biometricDisableSubtitle;

  /// No description provided for @biometricNotConfigured.
  ///
  /// In es, this message translates to:
  /// **'No se logró configurar'**
  String get biometricNotConfigured;

  /// No description provided for @errorLoadLockMethods.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar métodos de bloqueo'**
  String get errorLoadLockMethods;

  /// No description provided for @enableBiometricLockReason.
  ///
  /// In es, this message translates to:
  /// **'Activar bloqueo biométrico'**
  String get enableBiometricLockReason;

  /// No description provided for @errorEnableBiometricLock.
  ///
  /// In es, this message translates to:
  /// **'No se logró activar: {name}'**
  String errorEnableBiometricLock(String name);

  /// No description provided for @biometricAuthFailed.
  ///
  /// In es, this message translates to:
  /// **'Autenticación fallida. Intenta de nuevo.'**
  String get biometricAuthFailed;

  /// No description provided for @biometricAuthUnlocking.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueando...'**
  String get biometricAuthUnlocking;

  /// No description provided for @createPin.
  ///
  /// In es, this message translates to:
  /// **'Crear PIN'**
  String get createPin;

  /// No description provided for @createPinSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige un PIN de 4 dígitos'**
  String get createPinSubtitle;

  /// No description provided for @confirmPin.
  ///
  /// In es, this message translates to:
  /// **'Confirmar PIN'**
  String get confirmPin;

  /// No description provided for @confirmPinSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el PIN nuevamente'**
  String get confirmPinSubtitle;

  /// No description provided for @pinMismatch.
  ///
  /// In es, this message translates to:
  /// **'PIN no coincide'**
  String get pinMismatch;

  /// No description provided for @pinMismatchSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los PIN no coinciden. Intenta de nuevo.'**
  String get pinMismatchSubtitle;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu PIN'**
  String get pinConfirmTitle;

  /// No description provided for @pinIncorrect.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto ({attempts} intentos fallidos)'**
  String pinIncorrect(int attempts);

  /// No description provided for @pinIncorrectSubtitle.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto. Intenta de nuevo.'**
  String get pinIncorrectSubtitle;

  /// No description provided for @securityTitle.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get securityTitle;

  /// No description provided for @notSynced.
  ///
  /// In es, this message translates to:
  /// **'Sin sincronizar'**
  String get notSynced;

  /// No description provided for @syncLastBackup.
  ///
  /// In es, this message translates to:
  /// **'Última sincronización: {relative}'**
  String syncLastBackup(String relative);

  /// No description provided for @exportCsvHeader.
  ///
  /// In es, this message translates to:
  /// **'Fecha,Descripción,Categoría,Tipo,Cantidad,M.Unitario,Total'**
  String get exportCsvHeader;

  /// No description provided for @exportPdfHeader.
  ///
  /// In es, this message translates to:
  /// **'Fecha,Descripción,Categoría,Tipo,Cant.,M. Unit.,Total'**
  String get exportPdfHeader;

  /// No description provided for @exportUncategorized.
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get exportUncategorized;

  /// No description provided for @exportBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get exportBalance;

  /// No description provided for @exportDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get exportDate;

  /// No description provided for @exportDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get exportDescription;

  /// No description provided for @exportCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get exportCategory;

  /// No description provided for @exportType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get exportType;

  /// No description provided for @exportAmount.
  ///
  /// In es, this message translates to:
  /// **'Cant.'**
  String get exportAmount;

  /// No description provided for @exportUnitPrice.
  ///
  /// In es, this message translates to:
  /// **'M. Unit.'**
  String get exportUnitPrice;

  /// No description provided for @exportTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get exportTotal;

  /// No description provided for @exportReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Kaku - Reporte {period}'**
  String exportReportTitle(String period);

  /// No description provided for @exportCsvShareText.
  ///
  /// In es, this message translates to:
  /// **'Kaku - Exportación de transacciones'**
  String get exportCsvShareText;

  /// No description provided for @exportReceiptTitle.
  ///
  /// In es, this message translates to:
  /// **'Recibo - {desc}'**
  String exportReceiptTitle(String desc);

  /// No description provided for @exportTitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get exportTitle;

  /// No description provided for @exportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'CSV · PDF'**
  String get exportSubtitle;

  /// No description provided for @exportCsvLabel.
  ///
  /// In es, this message translates to:
  /// **'CSV'**
  String get exportCsvLabel;

  /// No description provided for @exportCsvDecription.
  ///
  /// In es, this message translates to:
  /// **'CSV: Abre en Excel o Google Sheets para análisis detallado.'**
  String get exportCsvDecription;

  /// No description provided for @exportPdfBasicLabel.
  ///
  /// In es, this message translates to:
  /// **'PDF básico'**
  String get exportPdfBasicLabel;

  /// No description provided for @exportPdfBasicDecription.
  ///
  /// In es, this message translates to:
  /// **'PDF básico: Tabla de transacciones limpia, lista para imprimir.'**
  String get exportPdfBasicDecription;

  /// No description provided for @exportPdfWithReceiptsLabel.
  ///
  /// In es, this message translates to:
  /// **'PDF con recibos'**
  String get exportPdfWithReceiptsLabel;

  /// No description provided for @exportPdfWithReceiptsDecription.
  ///
  /// In es, this message translates to:
  /// **'PDF con recibos: PDF completo con fotos adjuntas. 👑 Premium'**
  String get exportPdfWithReceiptsDecription;

  /// No description provided for @thisMonthLabel.
  ///
  /// In es, this message translates to:
  /// **'Mes actual'**
  String get thisMonthLabel;

  /// No description provided for @last3MonthsLabel.
  ///
  /// In es, this message translates to:
  /// **'Últimos 3 meses'**
  String get last3MonthsLabel;

  /// No description provided for @thisYearLabel.
  ///
  /// In es, this message translates to:
  /// **'Este año'**
  String get thisYearLabel;

  /// No description provided for @customRangeLabel.
  ///
  /// In es, this message translates to:
  /// **'Rango personalizado'**
  String get customRangeLabel;

  /// No description provided for @backupShareText.
  ///
  /// In es, this message translates to:
  /// **'Copia de Seguridad de Kaku — {date}'**
  String backupShareText(String date);

  /// No description provided for @backupGoogleDriveTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad Google Drive'**
  String get backupGoogleDriveTitle;

  /// No description provided for @backupTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get backupTitle;

  /// No description provided for @backupLocalTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad local'**
  String get backupLocalTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gratis · Comparte el archivo donde quieras'**
  String get backupSubtitle;

  /// No description provided for @backupConnectedAs.
  ///
  /// In es, this message translates to:
  /// **'✅ Conectado como {email}'**
  String backupConnectedAs(Object email);

  /// No description provided for @backupConnectFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con Google'**
  String get backupConnectFailed;

  /// No description provided for @backupCompleted.
  ///
  /// In es, this message translates to:
  /// **'✅ Copia de Seguridad completado — DB + recibos cifrados'**
  String get backupCompleted;

  /// No description provided for @backupSignInFirst.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión con Google primero'**
  String get backupSignInFirst;

  /// No description provided for @backupDbNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la base de datos'**
  String get backupDbNotFound;

  /// No description provided for @backupErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al realizar la copia de seguridad. Intenta de nuevo.'**
  String get backupErrorGeneric;

  /// No description provided for @restoreDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurar copia de seguridad'**
  String get restoreDialogTitle;

  /// No description provided for @restoreDialogContent.
  ///
  /// In es, this message translates to:
  /// **'Se reemplazarán todos los datos actuales con los de la copia de seguridad.\n\nEsta acción no se puede deshacer.'**
  String get restoreDialogContent;

  /// No description provided for @restoreDialogCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get restoreDialogCancel;

  /// No description provided for @restoreDialogConfirm.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restoreDialogConfirm;

  /// No description provided for @restoreSuccess.
  ///
  /// In es, this message translates to:
  /// **'✅ Datos restaurados correctamente'**
  String get restoreSuccess;

  /// No description provided for @restoreNoBackupFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró ninguna copia de seguridad en Drive'**
  String get restoreNoBackupFound;

  /// No description provided for @restoreErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al restaurar. Intenta de nuevo.'**
  String get restoreErrorGeneric;

  /// No description provided for @backupIncludesTitle.
  ///
  /// In es, this message translates to:
  /// **'La copia de seguridad incluye:'**
  String get backupIncludesTitle;

  /// No description provided for @backupIncludesDatabase.
  ///
  /// In es, this message translates to:
  /// **'Base de datos (transacciones, cuentas, metas)'**
  String get backupIncludesDatabase;

  /// No description provided for @backupIncludesReceipts.
  ///
  /// In es, this message translates to:
  /// **'Fotos de recibos'**
  String get backupIncludesReceipts;

  /// No description provided for @backupIncludesEncryption.
  ///
  /// In es, this message translates to:
  /// **'Cifrado AES-256 con tu cuenta de Google'**
  String get backupIncludesEncryption;

  /// No description provided for @backupIncludesEncryptionLocal.
  ///
  /// In es, this message translates to:
  /// **'Cifrado AES-256 con la contraseña ingresada'**
  String get backupIncludesEncryptionLocal;

  /// No description provided for @backupSignOut.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get backupSignOut;

  /// No description provided for @backupConnectGoogle.
  ///
  /// In es, this message translates to:
  /// **'Conectar con Google'**
  String get backupConnectGoogle;

  /// No description provided for @backupUploading.
  ///
  /// In es, this message translates to:
  /// **'Subiendo...'**
  String get backupUploading;

  /// No description provided for @backupDoNow.
  ///
  /// In es, this message translates to:
  /// **'Realizar copia de seguridad ahora'**
  String get backupDoNow;

  /// No description provided for @backupRestoring.
  ///
  /// In es, this message translates to:
  /// **'Restaurando...'**
  String get backupRestoring;

  /// No description provided for @backupRestoreFromDrive.
  ///
  /// In es, this message translates to:
  /// **'Restaurar desde Drive'**
  String get backupRestoreFromDrive;

  /// No description provided for @passwordNotEmpty.
  ///
  /// In es, this message translates to:
  /// **'La contraseña no puede estar vacía'**
  String get passwordNotEmpty;

  /// No description provided for @backupGenerateSuccess.
  ///
  /// In es, this message translates to:
  /// **'✅ Copia de seguridad generada correctamente'**
  String get backupGenerateSuccess;

  /// No description provided for @backupPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso para acceder al almacenamiento'**
  String get backupPermissionDenied;

  /// No description provided for @selectedFileBackup.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el archivo de la copia de seguridad de Kaku'**
  String get selectedFileBackup;

  /// No description provided for @backupFileNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el archivo de copia de seguridad'**
  String get backupFileNotFound;

  /// No description provided for @backupFileNotValid.
  ///
  /// In es, this message translates to:
  /// **'El archivo no es una copia de seguridad válida de Kaku o está dañado'**
  String get backupFileNotValid;

  /// No description provided for @backupMessageShare.
  ///
  /// In es, this message translates to:
  /// **'El archivo se guarda en tu dispositivo. Puedes moverlo a Google Drive, WhatsApp o donde prefieras usando el botón Compartir. La contraseña es necesaria para descifrarlo (restaurar) y cifrar el archivo de copia de seguridad.'**
  String get backupMessageShare;

  /// No description provided for @backupBtnCreating.
  ///
  /// In es, this message translates to:
  /// **'Creando copia de seguridad...'**
  String get backupBtnCreating;

  /// No description provided for @backupBtnCreateShare.
  ///
  /// In es, this message translates to:
  /// **'Crear y compartir copia de seguridad'**
  String get backupBtnCreateShare;

  /// No description provided for @backupBtnRestore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar desde archivo .zip'**
  String get backupBtnRestore;

  /// No description provided for @backupBtnRestoring.
  ///
  /// In es, this message translates to:
  /// **'Restaurando...'**
  String get backupBtnRestoring;

  /// No description provided for @notifBudgetExceededTitle.
  ///
  /// In es, this message translates to:
  /// **'{emoji} Presupuesto excedido'**
  String notifBudgetExceededTitle(String emoji);

  /// No description provided for @notifBudgetWarningTitle.
  ///
  /// In es, this message translates to:
  /// **'{emoji} Presupuesto al {percent}%'**
  String notifBudgetWarningTitle(String emoji, String percent);

  /// No description provided for @notifBudgetExceededBody.
  ///
  /// In es, this message translates to:
  /// **'Gastaste {spent} de {limit} en {category} este mes'**
  String notifBudgetExceededBody(String spent, String limit, String category);

  /// No description provided for @notifBudgetWarningBody.
  ///
  /// In es, this message translates to:
  /// **'Llevas {spent} de {limit} en {category}'**
  String notifBudgetWarningBody(String spent, String limit, String category);

  /// No description provided for @notifTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas de presupuesto'**
  String get notifTitle;

  /// No description provided for @notifActivatingBudget.
  ///
  /// In es, this message translates to:
  /// **'Activo · Alertas de presupuesto'**
  String get notifActivatingBudget;

  /// No description provided for @notifDeactivatingBudget.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get notifDeactivatingBudget;

  /// No description provided for @notifPermissionTitle.
  ///
  /// In es, this message translates to:
  /// **'Permiso de notificaciones'**
  String get notifPermissionTitle;

  /// No description provided for @notifPermissionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Kaku necesita permiso para enviarte alertas cuando te acercas al límite de un presupuesto.\n\nHabilítalo en los Ajustes del dispositivo.'**
  String get notifPermissionSubtitle;

  /// No description provided for @premiumBlockedBackupDrive.
  ///
  /// In es, this message translates to:
  /// **'El backup a Google Drive es una función premium.\nCon el plan free puedes hacer backup local.'**
  String get premiumBlockedBackupDrive;

  /// No description provided for @premiumBlockedExportPdfWithReceipts.
  ///
  /// In es, this message translates to:
  /// **'El PDF con imágenes de recibos es una función premium.\nCon el plan free puedes exportar CSV o PDF básico.'**
  String get premiumBlockedExportPdfWithReceipts;

  /// No description provided for @premiumBlockedExportCustomRange.
  ///
  /// In es, this message translates to:
  /// **'El rango personalizado de fechas es premium.\nCon el plan free puedes exportar el mes actual.'**
  String get premiumBlockedExportCustomRange;

  /// No description provided for @premiumBlockedViewHistory.
  ///
  /// In es, this message translates to:
  /// **'El historial de más de un mes es una función premium.'**
  String get premiumBlockedViewHistory;

  /// No description provided for @premiumBlockedPinLock.
  ///
  /// In es, this message translates to:
  /// **'El bloqueo por PIN o biometría es una función premium.'**
  String get premiumBlockedPinLock;

  /// No description provided for @premiumBlockedUnlimitedGoals.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado el límite de {max} metas del plan free.'**
  String premiumBlockedUnlimitedGoals(Object max);

  /// No description provided for @premiumBlockedUnlimitedBudgets.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado el límite de {max} presupuestos del plan free.'**
  String premiumBlockedUnlimitedBudgets(Object max);

  /// No description provided for @premiumBlockedUnlimitedCategories.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado el límite de {max} categorías personalizadas del plan free.'**
  String premiumBlockedUnlimitedCategories(Object max);

  /// No description provided for @permissionTitle.
  ///
  /// In es, this message translates to:
  /// **'Permiso de {source}'**
  String permissionTitle(String source);

  /// No description provided for @permissionDesc.
  ///
  /// In es, this message translates to:
  /// **'Kaku necesita acceso a tu {source} para adjuntar recibos. Habilítalo en los Ajustes del dispositivo.'**
  String permissionDesc(String source);

  /// No description provided for @messageNoReceipt.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la {source}'**
  String messageNoReceipt(String source);

  /// No description provided for @attachedReceipt.
  ///
  /// In es, this message translates to:
  /// **'Recibo adjunto'**
  String get attachedReceipt;

  /// No description provided for @receiptName.
  ///
  /// In es, this message translates to:
  /// **'Recibo · {name}'**
  String receiptName(String name);

  /// No description provided for @toPinchToZoom.
  ///
  /// In es, this message translates to:
  /// **'Pellizca para hacer zoom'**
  String get toPinchToZoom;

  /// No description provided for @receiptNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el recibo'**
  String get receiptNotFound;

  /// No description provided for @formRequired.
  ///
  /// In es, this message translates to:
  /// **'Campo requerido'**
  String get formRequired;

  /// No description provided for @formName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get formName;

  /// No description provided for @formBalanceInitial.
  ///
  /// In es, this message translates to:
  /// **'Saldo inicial'**
  String get formBalanceInitial;

  /// No description provided for @formColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get formColor;

  /// No description provided for @formIcon.
  ///
  /// In es, this message translates to:
  /// **'Ícono'**
  String get formIcon;

  /// No description provided for @formAmountMajor.
  ///
  /// In es, this message translates to:
  /// **'Debe ser mayor a 0'**
  String get formAmountMajor;

  /// No description provided for @formContributeMajorTotal.
  ///
  /// In es, this message translates to:
  /// **'No puedes aportar más que el total'**
  String get formContributeMajorTotal;

  /// No description provided for @formAccountNoBalance.
  ///
  /// In es, this message translates to:
  /// **'Cuenta sin saldo suficiente'**
  String get formAccountNoBalance;

  /// No description provided for @formLimitMajor.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un límite mayor a 0'**
  String get formLimitMajor;

  /// No description provided for @formMajorOrEqual.
  ///
  /// In es, this message translates to:
  /// **'Debe ser mayor o igual a {value}'**
  String formMajorOrEqual(int value);

  /// No description provided for @formPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get formPassword;

  /// No description provided for @accountsTitle.
  ///
  /// In es, this message translates to:
  /// **'{isPlural, plural, =1 {Cuentas} other {Cuenta}}'**
  String accountsTitle(int isPlural);

  /// No description provided for @accountTypeCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get accountTypeCash;

  /// No description provided for @accountTypeDebit.
  ///
  /// In es, this message translates to:
  /// **'Débito'**
  String get accountTypeDebit;

  /// No description provided for @accountTypeCredit.
  ///
  /// In es, this message translates to:
  /// **'Crédito'**
  String get accountTypeCredit;

  /// No description provided for @accountTypeSavings.
  ///
  /// In es, this message translates to:
  /// **'Ahorro'**
  String get accountTypeSavings;

  /// No description provided for @accountDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de la cuenta'**
  String get accountDetail;

  /// No description provided for @accountNotFound.
  ///
  /// In es, this message translates to:
  /// **'Cuenta no encontrada'**
  String get accountNotFound;

  /// No description provided for @myAccountName.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get myAccountName;

  /// No description provided for @accountType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de cuenta'**
  String get accountType;

  /// No description provided for @accountBalanceMessage.
  ///
  /// In es, this message translates to:
  /// **'Este es el saldo actual de tu cuenta. Las transacciones futuras ajustarán este valor'**
  String get accountBalanceMessage;

  /// No description provided for @accountUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cuenta actualizada'**
  String get accountUpdateSuccess;

  /// No description provided for @accountCreateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada'**
  String get accountCreateSuccess;

  /// No description provided for @accountArchiveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cuenta archivada'**
  String get accountArchiveSuccess;

  /// No description provided for @accountsErrorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar las cuentas'**
  String get accountsErrorLoading;

  /// No description provided for @accountsNotCreated.
  ///
  /// In es, this message translates to:
  /// **'No has creado ninguna cuenta'**
  String get accountsNotCreated;

  /// No description provided for @myAccounts.
  ///
  /// In es, this message translates to:
  /// **'Mis cuentas'**
  String get myAccounts;

  /// No description provided for @accountNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta'**
  String get accountNew;

  /// No description provided for @currentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual'**
  String get currentBalance;

  /// No description provided for @accountInflow.
  ///
  /// In es, this message translates to:
  /// **'Entrada'**
  String get accountInflow;

  /// No description provided for @accountOutflow.
  ///
  /// In es, this message translates to:
  /// **'Salida'**
  String get accountOutflow;

  /// No description provided for @balanceTotal.
  ///
  /// In es, this message translates to:
  /// **'Balance total'**
  String get balanceTotal;

  /// No description provided for @accountsActive.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1 {1 cuenta activa} other {{count} cuentas activas}}'**
  String accountsActive(int count);

  /// No description provided for @thisMonth.
  ///
  /// In es, this message translates to:
  /// **'este mes'**
  String get thisMonth;

  /// No description provided for @savings.
  ///
  /// In es, this message translates to:
  /// **'Ahorro'**
  String get savings;

  /// No description provided for @categoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'{isPlural, plural, =1 {Categorías} other {Categoría}}'**
  String categoriesTitle(int isPlural);

  /// No description provided for @categoryFood.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get categoryTransport;

  /// No description provided for @categoryHome.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get categoryHome;

  /// No description provided for @categoryHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get categoryHealth;

  /// No description provided for @categoryLeisure.
  ///
  /// In es, this message translates to:
  /// **'Ocio'**
  String get categoryLeisure;

  /// No description provided for @categoryEducation.
  ///
  /// In es, this message translates to:
  /// **'Educación'**
  String get categoryEducation;

  /// No description provided for @categoryShopping.
  ///
  /// In es, this message translates to:
  /// **'Compras'**
  String get categoryShopping;

  /// No description provided for @categoryUtilities.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get categoryUtilities;

  /// No description provided for @categorySavings.
  ///
  /// In es, this message translates to:
  /// **'Ahorro'**
  String get categorySavings;

  /// No description provided for @categorySalary.
  ///
  /// In es, this message translates to:
  /// **'Salario'**
  String get categorySalary;

  /// No description provided for @categoryFreelance.
  ///
  /// In es, this message translates to:
  /// **'Freelance'**
  String get categoryFreelance;

  /// No description provided for @categorySales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get categorySales;

  /// No description provided for @categoryGifts.
  ///
  /// In es, this message translates to:
  /// **'Regalos'**
  String get categoryGifts;

  /// No description provided for @categoryInvestments.
  ///
  /// In es, this message translates to:
  /// **'Inversiones'**
  String get categoryInvestments;

  /// No description provided for @categoryOtherIncome.
  ///
  /// In es, this message translates to:
  /// **'Otros ingresos'**
  String get categoryOtherIncome;

  /// No description provided for @notSetBudgetCategory.
  ///
  /// In es, this message translates to:
  /// **'Sin presupuesto definido para esta categoría'**
  String get notSetBudgetCategory;

  /// No description provided for @spentInMonth.
  ///
  /// In es, this message translates to:
  /// **'Gasto en {month}'**
  String spentInMonth(String month);

  /// No description provided for @categoryLimit.
  ///
  /// In es, this message translates to:
  /// **'Límite'**
  String get categoryLimit;

  /// No description provided for @categorySpentUsed.
  ///
  /// In es, this message translates to:
  /// **'{spent} usado'**
  String categorySpentUsed(String spent);

  /// No description provided for @categorySpentLeft.
  ///
  /// In es, this message translates to:
  /// **'Quedan {spent}'**
  String categorySpentLeft(String spent);

  /// No description provided for @categoryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin categorías'**
  String get categoryEmptyTitle;

  /// No description provided for @categoryEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca \'+ Nueva\' para crear tu primera categoría'**
  String get categoryEmptySubtitle;

  /// No description provided for @errorLoadCategories.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar las categorías'**
  String get errorLoadCategories;

  /// No description provided for @newCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get newCategoryTitle;

  /// No description provided for @editCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar categoría'**
  String get editCategoryTitle;

  /// No description provided for @categoryNotFound.
  ///
  /// In es, this message translates to:
  /// **'Categoría no encontrada'**
  String get categoryNotFound;

  /// No description provided for @categoryEditSuccess.
  ///
  /// In es, this message translates to:
  /// **'Categoría actualizada'**
  String get categoryEditSuccess;

  /// No description provided for @categoryCreateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Categoría creada'**
  String get categoryCreateSuccess;

  /// No description provided for @categoryDeactivateTitle.
  ///
  /// In es, this message translates to:
  /// **'Desactivar categoría'**
  String get categoryDeactivateTitle;

  /// No description provided for @categoryDeactivateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{emoji} {category} tiene {txCount, plural, =1{1 transacción asociada} other{{txCount} transacciones asociadas}}.\n\nAl desactivarla ya no aparecerá al agregar gastos, pero las transacciones existentes se conservan.'**
  String categoryDeactivateSubtitle(String emoji, String category, int txCount);

  /// No description provided for @categoryNotDeleted.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar'**
  String get categoryNotDeleted;

  /// No description provided for @categoryNotDeletedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{emoji} {category} tiene {txCount, plural, =1{1 transacción asociada} other{{txCount} transacciones asociadas}}.\n\nPara no perder el historial, solo puedes desactivarla. Seguirá visible en transacciones pasadas pero no aparecerá al agregar nuevos gastos.'**
  String categoryNotDeletedSubtitle(String emoji, String category, int txCount);

  /// No description provided for @categoryDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get categoryDeleteConfirm;

  /// No description provided for @categoryDeleteConfirmSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar {emoji} {category}?\n\nEsta categoría no tiene transacciones, por lo que se puede eliminar de forma permanente.'**
  String categoryDeleteConfirmSubtitle(String emoji, String category);

  /// No description provided for @countActiveCategories.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 categoría activa} other{{count} categorías activas}}'**
  String countActiveCategories(int count);

  /// No description provided for @categoryTitle.
  ///
  /// In es, this message translates to:
  /// **'{isPlural, plural, =1{Categorías} other {Categoría}}'**
  String categoryTitle(int isPlural);

  /// No description provided for @availableBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo disponible'**
  String get availableBalance;

  /// No description provided for @welcomeToKaku.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Kaku 👋'**
  String get welcomeToKaku;

  /// No description provided for @welcomeToKakuSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu bolsillo, bajo control'**
  String get welcomeToKakuSubtitle;

  /// No description provided for @welcomeToKakuName.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name} 👋'**
  String welcomeToKakuName(String name);

  /// No description provided for @errorLoadBudget.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar presupuestos'**
  String get errorLoadBudget;

  /// No description provided for @bannerStateExceeded.
  ///
  /// In es, this message translates to:
  /// **'Llevas {spent} gastados y tu límite era {budget}. Te pasaste por {over} este mes.'**
  String bannerStateExceeded(String spent, String budget, String over);

  /// No description provided for @bannerStateCritical.
  ///
  /// In es, this message translates to:
  /// **'A este ritmo ({avg}/día) gastarás {projection} este mes, {over} más de tu presupuesto.'**
  String bannerStateCritical(String avg, String projection, String over);

  /// No description provided for @bannerStateWarning.
  ///
  /// In es, this message translates to:
  /// **'Al ritmo actual podrías llegar a {projection} este mes vs tu presupuesto de {budget}.'**
  String bannerStateWarning(String projection, String budget);

  /// No description provided for @bannerStateNearEnd.
  ///
  /// In es, this message translates to:
  /// **'Quedan {daysLeft} días y ya usaste el {percentage} de tu presupuesto.'**
  String bannerStateNearEnd(int daysLeft, String percentage);

  /// No description provided for @bannerConfigExceeded.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto superado'**
  String get bannerConfigExceeded;

  /// No description provided for @bannerConfigCritical.
  ///
  /// In es, this message translates to:
  /// **'Vas a pasarte del presupuesto'**
  String get bannerConfigCritical;

  /// No description provided for @bannerConfigWarning.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu ritmo de gasto'**
  String get bannerConfigWarning;

  /// No description provided for @bannerConfigNearEnd.
  ///
  /// In es, this message translates to:
  /// **'Casi al límite del mes'**
  String get bannerConfigNearEnd;

  /// No description provided for @goalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get goalsTitle;

  /// No description provided for @contributeGoal.
  ///
  /// In es, this message translates to:
  /// **'Aportar meta'**
  String get contributeGoal;

  /// No description provided for @btnContribute.
  ///
  /// In es, this message translates to:
  /// **'Aportar'**
  String get btnContribute;

  /// No description provided for @contributeAll.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get contributeAll;

  /// No description provided for @leftToContribute.
  ///
  /// In es, this message translates to:
  /// **'Quedan {amount} para completar'**
  String leftToContribute(String amount);

  /// No description provided for @amountContributeToday.
  ///
  /// In es, this message translates to:
  /// **'Monto a aportar hoy'**
  String get amountContributeToday;

  /// No description provided for @newProgress.
  ///
  /// In es, this message translates to:
  /// **'Nuevo progreso'**
  String get newProgress;

  /// No description provided for @contributeSuccess.
  ///
  /// In es, this message translates to:
  /// **'Aporte realizado'**
  String get contributeSuccess;

  /// No description provided for @btnConfirmContribute.
  ///
  /// In es, this message translates to:
  /// **'Confirmar aporte'**
  String get btnConfirmContribute;

  /// No description provided for @newGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva meta'**
  String get newGoalTitle;

  /// No description provided for @nameGoal.
  ///
  /// In es, this message translates to:
  /// **'Meta: {name}'**
  String nameGoal(String name);

  /// No description provided for @amountGoal.
  ///
  /// In es, this message translates to:
  /// **'Monto objetivo'**
  String get amountGoal;

  /// No description provided for @dateGoal.
  ///
  /// In es, this message translates to:
  /// **'Fecha límite (opcional)'**
  String get dateGoal;

  /// No description provided for @dateGoalMessage.
  ///
  /// In es, this message translates to:
  /// **'Si no ingresa una fecha, el sistema utilizará su historial de ahorro para estimar cuándo podría cumplir su meta.'**
  String get dateGoalMessage;

  /// No description provided for @goalUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Meta actualizada'**
  String get goalUpdateSuccess;

  /// No description provided for @goalCreateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Meta creada'**
  String get goalCreateSuccess;

  /// No description provided for @btnUpdateGoal.
  ///
  /// In es, this message translates to:
  /// **'Actualizar Meta'**
  String get btnUpdateGoal;

  /// No description provided for @btnCreateGoal.
  ///
  /// In es, this message translates to:
  /// **'Crear Meta'**
  String get btnCreateGoal;

  /// No description provided for @goalEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar meta {name}'**
  String goalEditTitle(String name);

  /// No description provided for @goalCompleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Meta completada'**
  String get goalCompleteSuccess;

  /// No description provided for @goalDeleting.
  ///
  /// In es, this message translates to:
  /// **'Meta eliminandose'**
  String get goalDeleting;

  /// No description provided for @goalsActive.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 activa · } other{{count} activas · }}'**
  String goalsActive(int count);

  /// No description provided for @goalComplete.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 Completada} other{{count} completadas}}'**
  String goalComplete(int count);

  /// No description provided for @goalsNoActive.
  ///
  /// In es, this message translates to:
  /// **'Sin metas activas'**
  String get goalsNoActive;

  /// No description provided for @premiumSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lleva tus finanzas\nal siguiente nivel'**
  String get premiumSubtitle;

  /// No description provided for @premiumContent.
  ///
  /// In es, this message translates to:
  /// **'Todas las herramientas que necesitas para\ntener control total de tu dinero.'**
  String get premiumContent;

  /// No description provided for @premiumPaymentTitle.
  ///
  /// In es, this message translates to:
  /// **'✨ PAGO ÚNICO — SIN SUSCRIPCIÓN'**
  String get premiumPaymentTitle;

  /// No description provided for @premiumPaymentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'para siempre · un solo pago'**
  String get premiumPaymentSubtitle;

  /// No description provided for @premiumUnlockKaku.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear Kaku Premium'**
  String get premiumUnlockKaku;

  /// No description provided for @welcomeToPremium.
  ///
  /// In es, this message translates to:
  /// **'🎉 ¡Bienvenido a Kaku Premium!'**
  String get welcomeToPremium;

  /// No description provided for @billingPending.
  ///
  /// In es, this message translates to:
  /// **'Pago pendiente. Te notificaremos cuando se confirme.'**
  String get billingPending;

  /// No description provided for @billingProductNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el producto en la tienda. Verifica tu conexión e intenta de nuevo.'**
  String get billingProductNotFound;

  /// No description provided for @billingFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar el pago. Intenta de nuevo.'**
  String get billingFailed;

  /// No description provided for @labelUnlockTitle.
  ///
  /// In es, this message translates to:
  /// **'TODO LO QUE DESBLOQUEAS'**
  String get labelUnlockTitle;

  /// No description provided for @billingRestorePurchase.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compra'**
  String get billingRestorePurchase;

  /// No description provided for @billingCodePromo.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes un código de descuento?'**
  String get billingCodePromo;

  /// No description provided for @billingNoteLegal.
  ///
  /// In es, this message translates to:
  /// **'Pago único · Sin suscripción · Sin cobros recurrentes'**
  String get billingNoteLegal;

  /// No description provided for @verifyingPurchase.
  ///
  /// In es, this message translates to:
  /// **'Verificando compra...'**
  String get verifyingPurchase;

  /// No description provided for @verifyingPurchaseSuccess.
  ///
  /// In es, this message translates to:
  /// **'✅ Compra restaurada correctamente'**
  String get verifyingPurchaseSuccess;

  /// No description provided for @billingRestorePurchaseNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró ninguna compra previa asociada a tu cuenta de Google.'**
  String get billingRestorePurchaseNotFound;

  /// No description provided for @billingRestorePurchaseError.
  ///
  /// In es, this message translates to:
  /// **'Error al restaurar. Intenta de nuevo.'**
  String get billingRestorePurchaseError;

  /// No description provided for @premiumFeatureBackupDrive.
  ///
  /// In es, this message translates to:
  /// **'Backup automático a Google Drive'**
  String get premiumFeatureBackupDrive;

  /// No description provided for @premiumFeatureBackupDriveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sincroniza tu base de datos y recibos en la nube con un toque'**
  String get premiumFeatureBackupDriveSubtitle;

  /// No description provided for @premiumFeatureExportPdf.
  ///
  /// In es, this message translates to:
  /// **'PDF con fotos de recibos'**
  String get premiumFeatureExportPdf;

  /// No description provided for @premiumFeatureExportPdfSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Exporta reportes completos con las imágenes adjuntas de cada compra'**
  String get premiumFeatureExportPdfSubtitle;

  /// No description provided for @premiumFeatureExportCustomRange.
  ///
  /// In es, this message translates to:
  /// **'Rango de fechas personalizado'**
  String get premiumFeatureExportCustomRange;

  /// No description provided for @premiumFeatureExportCustomRangeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Exporta cualquier período de tiempo, no solo el mes actual'**
  String get premiumFeatureExportCustomRangeSubtitle;

  /// No description provided for @premiumFeatureUnlimitedGoals.
  ///
  /// In es, this message translates to:
  /// **'Metas ilimitadas'**
  String get premiumFeatureUnlimitedGoals;

  /// No description provided for @premiumFeatureUnlimitedGoalsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea todas las metas de ahorro que necesites sin restricciones'**
  String get premiumFeatureUnlimitedGoalsSubtitle;

  /// No description provided for @premiumFeatureUnlimitedBudgets.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos ilimitados'**
  String get premiumFeatureUnlimitedBudgets;

  /// No description provided for @premiumFeatureUnlimitedBudgetsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Asigna límites a todas tus categorías, no solo 3'**
  String get premiumFeatureUnlimitedBudgetsSubtitle;

  /// No description provided for @premiumFeatureUnlimitedCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías personalizadas ilimitadas'**
  String get premiumFeatureUnlimitedCategories;

  /// No description provided for @premiumFeatureUnlimitedCategoriesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza tus gastos con todas las categorías que quieras'**
  String get premiumFeatureUnlimitedCategoriesSubtitle;

  /// No description provided for @premiumFeaturePinLock.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo con PIN o biometría'**
  String get premiumFeaturePinLock;

  /// No description provided for @premiumFeaturePinLockSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Protege tu información financiera con huella, Face ID o PIN propio'**
  String get premiumFeaturePinLockSubtitle;

  /// No description provided for @premiumFeatureViewHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial completo de estadísticas'**
  String get premiumFeatureViewHistory;

  /// No description provided for @premiumFeatureViewHistorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Analiza tus patrones de gasto en cualquier período pasado'**
  String get premiumFeatureViewHistorySubtitle;

  /// No description provided for @redeemCodeErrorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Código no válido. Verifica e intenta de nuevo.'**
  String get redeemCodeErrorInvalid;

  /// No description provided for @redeemCodeErrorAlreadyUsed.
  ///
  /// In es, this message translates to:
  /// **'Este código ya fue canjeado en este dispositivo.'**
  String get redeemCodeErrorAlreadyUsed;

  /// No description provided for @redeemCode.
  ///
  /// In es, this message translates to:
  /// **'Canjear código'**
  String get redeemCode;

  /// No description provided for @redeemCodeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu código de descuento o acceso premium'**
  String get redeemCodeSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearanceTitle;

  /// No description provided for @themeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tema de color'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el color de acento de la app'**
  String get themeSubtitle;

  /// No description provided for @themeModeTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get themeModeTitle;

  /// No description provided for @themeModeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activa el modo oscuro o desactivalo para usar el tema claro'**
  String get themeModeSubtitle;

  /// No description provided for @regionalTitle.
  ///
  /// In es, this message translates to:
  /// **'Regional'**
  String get regionalTitle;

  /// No description provided for @currencyTitle.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currencyTitle;

  /// No description provided for @budgetsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos'**
  String get budgetsSectionTitle;

  /// No description provided for @budgetByCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos por categorías'**
  String get budgetByCategoryTitle;

  /// No description provided for @budgetByCategorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'{monthYear} - {count, plural, =1{1 configurado} other{{count} configurados}}'**
  String budgetByCategorySubtitle(num count, Object monthYear);

  /// No description provided for @dataTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos'**
  String get dataTitle;

  /// No description provided for @storageLocalTitle.
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento local'**
  String get storageLocalTitle;

  /// No description provided for @storageNoReceipts.
  ///
  /// In es, this message translates to:
  /// **'Sin recibos guardados'**
  String get storageNoReceipts;

  /// No description provided for @storageSummary.
  ///
  /// In es, this message translates to:
  /// **'{size} · {count, plural, =1{1 foto} other{{count} fotos}}'**
  String storageSummary(String size, int count);

  /// No description provided for @dangerZoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Zona peligrosa'**
  String get dangerZoneTitle;

  /// No description provided for @deleteDataAllTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar todos los datos'**
  String get deleteDataAllTitle;

  /// No description provided for @deleteDataAllSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elimina todos los datos de la app'**
  String get deleteDataAllSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get aboutTitle;

  /// No description provided for @versionTitle.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get versionTitle;

  /// No description provided for @deleteText.
  ///
  /// In es, this message translates to:
  /// **'BORRAR'**
  String get deleteText;

  /// No description provided for @errorDeletingData.
  ///
  /// In es, this message translates to:
  /// **'Error al borrar los datos'**
  String get errorDeletingData;

  /// No description provided for @messageDataAllDeleted.
  ///
  /// In es, this message translates to:
  /// **'Esta acción es permanente e irreversible. Se eliminarán todos los datos de Kaku de tu dispositivo.'**
  String get messageDataAllDeleted;

  /// No description provided for @titleDeleteList.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán permanentemente:'**
  String get titleDeleteList;

  /// No description provided for @deleteListTransactions.
  ///
  /// In es, this message translates to:
  /// **'Todas las transacciones'**
  String get deleteListTransactions;

  /// No description provided for @deleteListAccounts.
  ///
  /// In es, this message translates to:
  /// **'Todas las cuentas'**
  String get deleteListAccounts;

  /// No description provided for @deleteListGoals.
  ///
  /// In es, this message translates to:
  /// **'Todos los metas y aportes'**
  String get deleteListGoals;

  /// No description provided for @deleteListBudgets.
  ///
  /// In es, this message translates to:
  /// **'Todos los presupuestos'**
  String get deleteListBudgets;

  /// No description provided for @deleteListCategories.
  ///
  /// In es, this message translates to:
  /// **'Todas las categorías personalizadas'**
  String get deleteListCategories;

  /// No description provided for @deleteListReceipts.
  ///
  /// In es, this message translates to:
  /// **'Todos los fotos de recibos'**
  String get deleteListReceipts;

  /// No description provided for @deleteListSettings.
  ///
  /// In es, this message translates to:
  /// **'Toda la configuración de la app'**
  String get deleteListSettings;

  /// No description provided for @writeWordDeleted.
  ///
  /// In es, this message translates to:
  /// **'Escribe BORRAR para confirmar'**
  String get writeWordDeleted;

  /// No description provided for @selectedDatesRange.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un rango de fechas'**
  String get selectedDatesRange;

  /// No description provided for @last3Months.
  ///
  /// In es, this message translates to:
  /// **'Últimos 3 meses'**
  String get last3Months;

  /// No description provided for @thisYear.
  ///
  /// In es, this message translates to:
  /// **'Año {year}'**
  String thisYear(int year);

  /// No description provided for @rangeCustom.
  ///
  /// In es, this message translates to:
  /// **'Rango personalizado'**
  String get rangeCustom;

  /// No description provided for @formatTitle.
  ///
  /// In es, this message translates to:
  /// **'Formato'**
  String get formatTitle;

  /// No description provided for @csvDecription.
  ///
  /// In es, this message translates to:
  /// **'Para abrir en Excel o Google Sheets.'**
  String get csvDecription;

  /// No description provided for @pdfBasic.
  ///
  /// In es, this message translates to:
  /// **'PDF básico'**
  String get pdfBasic;

  /// No description provided for @pdfBasicDecription.
  ///
  /// In es, this message translates to:
  /// **'Tabla de transacciones sin fotos.'**
  String get pdfBasicDecription;

  /// No description provided for @pdfWithReceipts.
  ///
  /// In es, this message translates to:
  /// **'PDF con fotos de recibos'**
  String get pdfWithReceipts;

  /// No description provided for @pdfWithReceiptsDecription.
  ///
  /// In es, this message translates to:
  /// **'PDF completo con fotos adjuntas.'**
  String get pdfWithReceiptsDecription;

  /// No description provided for @periodTitle.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get periodTitle;

  /// No description provided for @rangeTitle.
  ///
  /// In es, this message translates to:
  /// **'Rango de fechas'**
  String get rangeTitle;

  /// No description provided for @languageTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el idioma de la app'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'Idioma del dispositivo'**
  String get languageSystem;

  /// No description provided for @budgetTitle.
  ///
  /// In es, this message translates to:
  /// **'{plural, plural, =1 {Presupuestos} other {Presupuesto}}'**
  String budgetTitle(int plural);

  /// No description provided for @deleteBudgetConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar presupuesto'**
  String get deleteBudgetConfirm;

  /// No description provided for @deleteBudgetConfirmSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar el presupuesto de {emoji} {category} para este mes?'**
  String deleteBudgetConfirmSubtitle(String emoji, String category);

  /// No description provided for @limitMonth.
  ///
  /// In es, this message translates to:
  /// **'Límite mensual'**
  String get limitMonth;

  /// No description provided for @acumulateSurplus.
  ///
  /// In es, this message translates to:
  /// **'Acumular sobrante'**
  String get acumulateSurplus;

  /// No description provided for @acumulateSurplusSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Si gastas menos de lo planeado, el sobrante se suma al próximo mes.'**
  String get acumulateSurplusSubtitle;

  /// No description provided for @acumulateBudget.
  ///
  /// In es, this message translates to:
  /// **'Acumular presupuesto'**
  String get acumulateBudget;

  /// No description provided for @btnCreateBudget.
  ///
  /// In es, this message translates to:
  /// **'Crear presupuesto'**
  String get btnCreateBudget;

  /// No description provided for @budgetTotal.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto total'**
  String get budgetTotal;

  /// No description provided for @budgetWornOut.
  ///
  /// In es, this message translates to:
  /// **'Gastado'**
  String get budgetWornOut;

  /// No description provided for @budgetAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get budgetAvailable;

  /// No description provided for @unlimited.
  ///
  /// In es, this message translates to:
  /// **'Sin límite'**
  String get unlimited;

  /// No description provided for @budgetWornOutDescription.
  ///
  /// In es, this message translates to:
  /// **'Gastado: {spent}'**
  String budgetWornOutDescription(String spent);

  /// No description provided for @budgetRemainingOrExceeded.
  ///
  /// In es, this message translates to:
  /// **'{remaining, plural, =1 {Quedan} other {Excedido}} {amount}'**
  String budgetRemainingOrExceeded(int remaining, String amount);

  /// No description provided for @editBudget.
  ///
  /// In es, this message translates to:
  /// **'Editar presupuesto'**
  String get editBudget;

  /// No description provided for @createBudget.
  ///
  /// In es, this message translates to:
  /// **'Nuevo presupuesto'**
  String get createBudget;

  /// No description provided for @budgetSaved.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto guardado'**
  String get budgetSaved;

  /// No description provided for @profileEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEdit;

  /// No description provided for @profileNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Email (Solo Lectura)'**
  String get profileEmailLabel;

  /// No description provided for @changesSaved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get changesSaved;

  /// No description provided for @storageClearReceipts.
  ///
  /// In es, this message translates to:
  /// **'Limpiar recibos'**
  String get storageClearReceipts;

  /// No description provided for @storageReceiptsCleared.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán {count} fotos de recibos ({size}) del dispositivo.\n\nLas transacciones se conservan pero ya no tendrán foto adjunta.'**
  String storageReceiptsCleared(int count, String size);

  /// No description provided for @storageReceiptsLabel.
  ///
  /// In es, this message translates to:
  /// **'Fotos de recibos'**
  String get storageReceiptsLabel;

  /// No description provided for @storageReceiptsSummary.
  ///
  /// In es, this message translates to:
  /// **'{count} fotos de recibos · {size}'**
  String storageReceiptsSummary(int count, String size);

  /// No description provided for @storageNoteInfo.
  ///
  /// In es, this message translates to:
  /// **'Las fotos se guardan en el almacenamiento privado de la app y nunca salen de tu dispositivo.'**
  String get storageNoteInfo;

  /// No description provided for @storageCleaning.
  ///
  /// In es, this message translates to:
  /// **'Limpiando...'**
  String get storageCleaning;

  /// No description provided for @storageClearedInfo.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin recibos que limpiar} one{Se eliminará un recibo} other{Se eliminarán {count} recibos ({size})}}'**
  String storageClearedInfo(int count, String size);

  /// No description provided for @statsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statsTitle;

  /// No description provided for @statsEmptyThisMonth.
  ///
  /// In es, this message translates to:
  /// **'No hay estadísticas para este mes o periodo'**
  String get statsEmptyThisMonth;

  /// No description provided for @statsTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get statsTotalLabel;

  /// No description provided for @statsMonthLabel.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get statsMonthLabel;

  /// No description provided for @statsQuarterLabel.
  ///
  /// In es, this message translates to:
  /// **'Trimestre'**
  String get statsQuarterLabel;

  /// No description provided for @statsYearLabel.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get statsYearLabel;

  /// No description provided for @statsDonutTitle.
  ///
  /// In es, this message translates to:
  /// **'Distribución'**
  String get statsDonutTitle;

  /// No description provided for @statsDonutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Por categoría · {monthName}'**
  String statsDonutSubtitle(String monthName);

  /// No description provided for @statsTrendTitle.
  ///
  /// In es, this message translates to:
  /// **'Tendencia'**
  String get statsTrendTitle;

  /// No description provided for @statsTrendSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Últimos 6 meses'**
  String get statsTrendSubtitle;

  /// No description provided for @statsTrendMonthVsPreviousTitle.
  ///
  /// In es, this message translates to:
  /// **'Mes vs anterior'**
  String get statsTrendMonthVsPreviousTitle;

  /// No description provided for @statsTrendMonthVsPreviousSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{previousLabel} vs {currentLabel}'**
  String statsTrendMonthVsPreviousSubtitle(
    String previousLabel,
    String currentLabel,
  );

  /// No description provided for @statsExpensesDiaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Gasto diario'**
  String get statsExpensesDiaryTitle;

  /// No description provided for @statsExpensesDiarySubtitle.
  ///
  /// In es, this message translates to:
  /// **'{daysInMonth, plural, =1{1 día} other{{daysInMonth} días}}'**
  String statsExpensesDiarySubtitle(int daysInMonth);

  /// No description provided for @statsLast3MonthsTitle.
  ///
  /// In es, this message translates to:
  /// **'Últimos 3 meses'**
  String get statsLast3MonthsTitle;

  /// No description provided for @statsLast3MonthsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gasto total por mes'**
  String get statsLast3MonthsSubtitle;

  /// No description provided for @statsLastYearTitle.
  ///
  /// In es, this message translates to:
  /// **'Últimos 12 meses'**
  String get statsLastYearTitle;

  /// No description provided for @statsTrend6MonthsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tendencia · Últimos 6 meses'**
  String get statsTrend6MonthsTitle;

  /// No description provided for @statsTrend6MonthsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea Premium para ver tu historial completo de gastos.'**
  String get statsTrend6MonthsSubtitle;

  /// No description provided for @statsDailyBarChartTitle.
  ///
  /// In es, this message translates to:
  /// **'Promedio: {avg}/día'**
  String statsDailyBarChartTitle(String avg);

  /// No description provided for @statsDailyBarChartTooltip.
  ///
  /// In es, this message translates to:
  /// **'Día {day}\n{money}'**
  String statsDailyBarChartTooltip(int day, String money);

  /// No description provided for @statsDailyBarChartAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get statsDailyBarChartAverage;

  /// No description provided for @statsMonthComparationExpense.
  ///
  /// In es, this message translates to:
  /// **'Gastaste'**
  String get statsMonthComparationExpense;

  /// No description provided for @statsMonthComparationLegend.
  ///
  /// In es, this message translates to:
  /// **'{percent}% {improved, plural, =1 {menos} other {más}}'**
  String statsMonthComparationLegend(String percent, int improved);

  /// No description provided for @statsIncomeExpenseTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresos vs gastos'**
  String get statsIncomeExpenseTitle;

  /// No description provided for @statsIncomeExpenseSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Últimos {months} meses'**
  String statsIncomeExpenseSubtitle(int months);

  /// No description provided for @statsIncomeExpenseNet.
  ///
  /// In es, this message translates to:
  /// **'Neto del periodo: {amount}'**
  String statsIncomeExpenseNet(String amount);

  /// No description provided for @statsIncomeExpenseLocked.
  ///
  /// In es, this message translates to:
  /// **'Disponible con Premium'**
  String get statsIncomeExpenseLocked;

  /// No description provided for @premiumFeatureIncomeExpense.
  ///
  /// In es, this message translates to:
  /// **'Gráfica de ingresos vs gastos'**
  String get premiumFeatureIncomeExpense;

  /// No description provided for @premiumFeatureIncomeExpenseSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Compara cuánto entra y cuánto sale cada mes'**
  String get premiumFeatureIncomeExpenseSubtitle;

  /// No description provided for @transactionTypeFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get transactionTypeFilterAll;

  /// No description provided for @transactionTypeFilterByCategory.
  ///
  /// In es, this message translates to:
  /// **'Por categoría'**
  String get transactionTypeFilterByCategory;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Gasto} other{Gastos}}'**
  String transactionTypeExpense(int count);

  /// No description provided for @transactionTypeIncome.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Ingreso} other{Ingresos}}'**
  String transactionTypeIncome(int count);

  /// No description provided for @transactionTypeTransfer.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Transferencia} other{Transferencias}}'**
  String transactionTypeTransfer(int count);

  /// No description provided for @transactionsHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Historial de transacciones vacío'**
  String get transactionsHistoryEmpty;

  /// No description provided for @transactionTitle.
  ///
  /// In es, this message translates to:
  /// **'{plural, plural, =1 {Transacciones} other {Transacción}}'**
  String transactionTitle(int plural);

  /// No description provided for @transactionCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 transacción} other{{count} transacciones}}'**
  String transactionCount(int count);

  /// No description provided for @transactionEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones'**
  String get transactionEmpty;

  /// No description provided for @transactionTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total · {currency}'**
  String transactionTotalLabel(String currency);

  /// No description provided for @transactionDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get transactionDescriptionLabel;

  /// No description provided for @transactionExpenseSaved.
  ///
  /// In es, this message translates to:
  /// **'Gasto guardado'**
  String get transactionExpenseSaved;

  /// No description provided for @transactionIncomeSaved.
  ///
  /// In es, this message translates to:
  /// **'Ingreso guardado'**
  String get transactionIncomeSaved;

  /// No description provided for @transactionTransferSaved.
  ///
  /// In es, this message translates to:
  /// **'Transferencia guardada'**
  String get transactionTransferSaved;

  /// No description provided for @transactionSavedGeneric.
  ///
  /// In es, this message translates to:
  /// **'Transacción guardada'**
  String get transactionSavedGeneric;

  /// No description provided for @transactionExpenseBtnSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardar gasto'**
  String get transactionExpenseBtnSaved;

  /// No description provided for @transactionIncomeBtnSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardar ingreso'**
  String get transactionIncomeBtnSaved;

  /// No description provided for @transactionTransferBtnSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardar transferencia'**
  String get transactionTransferBtnSaved;

  /// No description provided for @transactionBtnSavedGeneric.
  ///
  /// In es, this message translates to:
  /// **'Guardar transacción'**
  String get transactionBtnSavedGeneric;

  /// No description provided for @addTransactionTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva transacción'**
  String get addTransactionTitle;

  /// No description provided for @transferMessageEmpty.
  ///
  /// In es, this message translates to:
  /// **'Registra al menos dos cuentas para poder crear transferencias'**
  String get transferMessageEmpty;

  /// No description provided for @transferAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad o Monto · {currency}'**
  String transferAmountLabel(String currency);

  /// No description provided for @transferAccountDestinationLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuenta destino'**
  String get transferAccountDestinationLabel;

  /// No description provided for @transferAccountOriginLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuenta origen'**
  String get transferAccountOriginLabel;

  /// No description provided for @transferAccountDestEmpty.
  ///
  /// In es, this message translates to:
  /// **'Seleccione una cuenta de destino'**
  String get transferAccountDestEmpty;

  /// No description provided for @transferAccountOriginEmpty.
  ///
  /// In es, this message translates to:
  /// **'Seleccione una cuenta de origen'**
  String get transferAccountOriginEmpty;

  /// No description provided for @transferAccountDestEqualOrigin.
  ///
  /// In es, this message translates to:
  /// **'La cuenta destino no debe ser igual a la cuenta origen'**
  String get transferAccountDestEqualOrigin;

  /// No description provided for @transferAccountOriginEqualDest.
  ///
  /// In es, this message translates to:
  /// **'La cuenta origen no debe ser igual a la cuenta destino'**
  String get transferAccountOriginEqualDest;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar transacción'**
  String get deleteTransactionConfirm;

  /// No description provided for @deleteTransactionDesc.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer. ¿Eliminar?'**
  String get deleteTransactionDesc;

  /// No description provided for @deleteTransactionSuccess.
  ///
  /// In es, this message translates to:
  /// **'Transacción eliminada'**
  String get deleteTransactionSuccess;

  /// No description provided for @transactionNotFound.
  ///
  /// In es, this message translates to:
  /// **'Transacción no encontrada'**
  String get transactionNotFound;

  /// No description provided for @messageTransactionAccountEmpty.
  ///
  /// In es, this message translates to:
  /// **'Registra al menos una cuenta para poder crear transacciones'**
  String get messageTransactionAccountEmpty;

  /// No description provided for @amountOrValueUnit.
  ///
  /// In es, this message translates to:
  /// **'Monto o valor unitario · {currency}'**
  String amountOrValueUnit(String currency);

  /// No description provided for @amountLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get amountLabel;

  /// No description provided for @valueUnitLabel.
  ///
  /// In es, this message translates to:
  /// **'Valor Unitario'**
  String get valueUnitLabel;

  /// No description provided for @viewReceipt.
  ///
  /// In es, this message translates to:
  /// **'Ver recibo'**
  String get viewReceipt;

  /// No description provided for @receiptEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin recibo'**
  String get receiptEmpty;

  /// No description provided for @totalTransactionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get totalTransactionsLabel;

  /// No description provided for @transactionDateCompleteLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora'**
  String get transactionDateCompleteLabel;

  /// No description provided for @transactionRecurrentLabel.
  ///
  /// In es, this message translates to:
  /// **'Recurrente'**
  String get transactionRecurrentLabel;

  /// No description provided for @transactionIsRecurringLabel.
  ///
  /// In es, this message translates to:
  /// **'{recurring, plural, =1 {Sí} other {No}}'**
  String transactionIsRecurringLabel(int recurring);

  /// No description provided for @transactionReceiptLabel.
  ///
  /// In es, this message translates to:
  /// **'Foto de recibo'**
  String get transactionReceiptLabel;

  /// No description provided for @transactionEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar transacción #{id}'**
  String transactionEditTitle(int id);

  /// No description provided for @transactionDeletingLabel.
  ///
  /// In es, this message translates to:
  /// **'Transacción eliminandose'**
  String get transactionDeletingLabel;

  /// No description provided for @balance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @errorInsufficientFunds.
  ///
  /// In es, this message translates to:
  /// **'Fondos insuficientes para esta transacción'**
  String get errorInsufficientFunds;

  /// No description provided for @errorAccountNotFound.
  ///
  /// In es, this message translates to:
  /// **'Cuenta no encontrada'**
  String get errorAccountNotFound;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In es, this message translates to:
  /// **'Cantidad no válida'**
  String get errorInvalidAmount;

  /// No description provided for @errorNetworkError.
  ///
  /// In es, this message translates to:
  /// **'Error de red'**
  String get errorNetworkError;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @undo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// No description provided for @btnClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get btnClose;

  /// No description provided for @archived.
  ///
  /// In es, this message translates to:
  /// **'Archivada'**
  String get archived;

  /// No description provided for @btnConfiguration.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get btnConfiguration;

  /// No description provided for @btnCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get btnCancel;

  /// No description provided for @btnViewPremium.
  ///
  /// In es, this message translates to:
  /// **'Ver Premium'**
  String get btnViewPremium;

  /// No description provided for @btnOpenSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir Ajustes'**
  String get btnOpenSettings;

  /// No description provided for @btnResetZoom.
  ///
  /// In es, this message translates to:
  /// **'Restablecer zoom'**
  String get btnResetZoom;

  /// No description provided for @btnAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get btnAdd;

  /// No description provided for @btnEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get btnEdit;

  /// No description provided for @btnUpdate.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get btnUpdate;

  /// No description provided for @btnCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get btnCreate;

  /// No description provided for @btnArchive.
  ///
  /// In es, this message translates to:
  /// **'Archivar o Inactivar'**
  String get btnArchive;

  /// No description provided for @btnViewDetail.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get btnViewDetail;

  /// No description provided for @btnNew.
  ///
  /// In es, this message translates to:
  /// **'{femenine, plural, =1 {Nueva} other {Nuevo}}'**
  String btnNew(int femenine);

  /// No description provided for @btnDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get btnDeactivate;

  /// No description provided for @btnActivate.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get btnActivate;

  /// No description provided for @btnDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get btnDelete;

  /// No description provided for @btnUnderstood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get btnUnderstood;

  /// No description provided for @btnDisableInstead.
  ///
  /// In es, this message translates to:
  /// **'Desactivar en su lugar'**
  String get btnDisableInstead;

  /// No description provided for @btnRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get btnRetry;

  /// No description provided for @btnSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get btnSave;

  /// No description provided for @btnClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get btnClear;

  /// No description provided for @btnSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get btnSaveChanges;

  /// No description provided for @btnConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get btnConfirm;

  /// No description provided for @emojiLabel.
  ///
  /// In es, this message translates to:
  /// **'Emoji'**
  String get emojiLabel;

  /// No description provided for @emojiHint.
  ///
  /// In es, this message translates to:
  /// **'Elige un emoji'**
  String get emojiHint;

  /// No description provided for @emojiHintSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar emoji...'**
  String get emojiHintSearch;

  /// No description provided for @premiumLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Límite alcanzado'**
  String get premiumLimitReached;

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camera;

  /// No description provided for @galery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get galery;

  /// No description provided for @selectedColor.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un color'**
  String get selectedColor;

  /// No description provided for @noDescription.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción'**
  String get noDescription;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @preview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get preview;

  /// No description provided for @average.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get average;

  /// No description provided for @majorSpending.
  ///
  /// In es, this message translates to:
  /// **'Mayor gasto'**
  String get majorSpending;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get viewAll;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @notAvailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get notAvailable;

  /// No description provided for @generatingLabel.
  ///
  /// In es, this message translates to:
  /// **'Generando...'**
  String get generatingLabel;

  /// No description provided for @localeEn.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get localeEn;

  /// No description provided for @localeEs.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get localeEs;

  /// No description provided for @selectMonthYear.
  ///
  /// In es, this message translates to:
  /// **'Selecciona mes y año'**
  String get selectMonthYear;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
