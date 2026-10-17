// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get currencyCopLabel => 'Peso colombiano';

  @override
  String get currencyUsdLabel => 'Dólar estadounidense';

  @override
  String get currencyEurLabel => 'Euro';

  @override
  String get currencyArsLabel => 'Peso argentino';

  @override
  String get currencyMxnLabel => 'Peso mexicano';

  @override
  String get currencySelect => 'Moneda';

  @override
  String get accentAurora => 'Aurora';

  @override
  String get accentDusk => 'Atardecer';

  @override
  String get accentViolet => 'Violeta';

  @override
  String get accentMono => 'Monocromático';

  @override
  String get accentOcean => 'Océano';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get userDisplayName => 'Usuario';

  @override
  String get appShellTabDashboard => 'Inicio';

  @override
  String get appShellTabStats => 'Estadísticas';

  @override
  String get appShellTabPersonal => 'Planificar';

  @override
  String get appShellTabAccounts => 'Cuentas';

  @override
  String get calendarTab => 'Calendario';

  @override
  String get calendarTabSubtitle => 'Programa tus gastos';

  @override
  String get calendarAddEntry => 'Agregar';

  @override
  String get calendarEntryTitleLabel => 'Título';

  @override
  String get calendarEntryAmountLabel => 'Monto estimado (vacío = nota)';

  @override
  String get calendarEmptyDay => 'Nada programado para este día';

  @override
  String get calendarPlannedExpense => 'Gasto programado';

  @override
  String get calendarNote => 'Nota';

  @override
  String get budgetCalculatorSavingsRateMenorCero =>
      'Gastaste más de lo que ganaste';

  @override
  String get budgetCalculatorSavingsRateMenor20 => 'Puedes mejorar';

  @override
  String get budgetCalculatorSavingsRateMenor50 => 'Vas bien 👍';

  @override
  String get budgetCalculatorSavingsRateMayor50 => 'Buen mes 🎉';

  @override
  String estimateTimeMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String estimateTimeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get noEstimate => 'Sin estimación';

  @override
  String get securityBiometrics => 'Bloqueo de pantalla';

  @override
  String get securityBiometricsSubtitle => 'Elige cómo quieres proteger tu app';

  @override
  String get securityPin => 'PIN';

  @override
  String get securityFingerprint => 'Huella digital';

  @override
  String get securityFaceId => 'Face ID';

  @override
  String get securityUnlockConfirm =>
      'Confirma tu identidad para desactivar el bloqueo';

  @override
  String get securityError => 'No se pudo verificar tu identidad.';

  @override
  String get biometricLockTitle => 'Kaku bloqueado';

  @override
  String get biometricLockSubtitle => 'Usa tu biometría para continuar';

  @override
  String get biometricLockUnlock => 'Desbloquear';

  @override
  String get biometricLockVerifying => 'Verificando...';

  @override
  String get biometricAuthReason => 'Confirma tu identidad para acceder a Kaku';

  @override
  String get biometricEnableSubtitle => 'Activo · Se pide al abrir la app';

  @override
  String get biometricDisableSubtitle =>
      'Inactivo · La app no pide confirmación';

  @override
  String get biometricNotConfigured => 'No se logró configurar';

  @override
  String get errorLoadLockMethods => 'Error al cargar métodos de bloqueo';

  @override
  String get enableBiometricLockReason => 'Activar bloqueo biométrico';

  @override
  String errorEnableBiometricLock(String name) {
    return 'No se logró activar: $name';
  }

  @override
  String get biometricAuthFailed => 'Autenticación fallida. Intenta de nuevo.';

  @override
  String get biometricAuthUnlocking => 'Desbloqueando...';

  @override
  String get createPin => 'Crear PIN';

  @override
  String get createPinSubtitle => 'Elige un PIN de 4 dígitos';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get confirmPinSubtitle => 'Ingresa el PIN nuevamente';

  @override
  String get pinMismatch => 'PIN no coincide';

  @override
  String get pinMismatchSubtitle => 'Los PIN no coinciden. Intenta de nuevo.';

  @override
  String get pinConfirmTitle => 'Ingresa tu PIN';

  @override
  String pinIncorrect(int attempts) {
    return 'PIN incorrecto ($attempts intentos fallidos)';
  }

  @override
  String get pinIncorrectSubtitle => 'PIN incorrecto. Intenta de nuevo.';

  @override
  String get securityTitle => 'Seguridad';

  @override
  String get notSynced => 'Sin sincronizar';

  @override
  String syncLastBackup(String relative) {
    return 'Última sincronización: $relative';
  }

  @override
  String get exportCsvHeader =>
      'Fecha,Descripción,Categoría,Tipo,Cantidad,M.Unitario,Total';

  @override
  String get exportPdfHeader =>
      'Fecha,Descripción,Categoría,Tipo,Cant.,M. Unit.,Total';

  @override
  String get exportUncategorized => 'Sin categoría';

  @override
  String get exportBalance => 'Balance';

  @override
  String get exportDate => 'Fecha';

  @override
  String get exportDescription => 'Descripción';

  @override
  String get exportCategory => 'Categoría';

  @override
  String get exportType => 'Tipo';

  @override
  String get exportAmount => 'Cant.';

  @override
  String get exportUnitPrice => 'M. Unit.';

  @override
  String get exportTotal => 'Total';

  @override
  String exportReportTitle(String period) {
    return 'Kaku - Reporte $period';
  }

  @override
  String get exportCsvShareText => 'Kaku - Exportación de transacciones';

  @override
  String exportReceiptTitle(String desc) {
    return 'Recibo - $desc';
  }

  @override
  String get exportTitle => 'Exportar datos';

  @override
  String get exportSubtitle => 'CSV · PDF';

  @override
  String get exportCsvLabel => 'CSV';

  @override
  String get exportCsvDecription =>
      'CSV: Abre en Excel o Google Sheets para análisis detallado.';

  @override
  String get exportPdfBasicLabel => 'PDF básico';

  @override
  String get exportPdfBasicDecription =>
      'PDF básico: Tabla de transacciones limpia, lista para imprimir.';

  @override
  String get exportPdfWithReceiptsLabel => 'PDF con recibos';

  @override
  String get exportPdfWithReceiptsDecription =>
      'PDF con recibos: PDF completo con fotos adjuntas. 👑 Premium';

  @override
  String get thisMonthLabel => 'Mes actual';

  @override
  String get last3MonthsLabel => 'Últimos 3 meses';

  @override
  String get thisYearLabel => 'Este año';

  @override
  String get customRangeLabel => 'Rango personalizado';

  @override
  String backupShareText(String date) {
    return 'Copia de Seguridad de Kaku — $date';
  }

  @override
  String get backupGoogleDriveTitle => 'Copia de seguridad Google Drive';

  @override
  String get backupTitle => 'Copia de seguridad';

  @override
  String get backupLocalTitle => 'Copia de seguridad local';

  @override
  String get backupSubtitle => 'Gratis · Comparte el archivo donde quieras';

  @override
  String backupConnectedAs(Object email) {
    return '✅ Conectado como $email';
  }

  @override
  String get backupConnectFailed => 'No se pudo conectar con Google';

  @override
  String get backupCompleted =>
      '✅ Copia de Seguridad completado — DB + recibos cifrados';

  @override
  String get backupSignInFirst => 'Inicia sesión con Google primero';

  @override
  String get backupDbNotFound => 'No se encontró la base de datos';

  @override
  String get backupErrorGeneric =>
      'Error al realizar la copia de seguridad. Intenta de nuevo.';

  @override
  String get restoreDialogTitle => 'Restaurar copia de seguridad';

  @override
  String get restoreDialogContent =>
      'Se reemplazarán todos los datos actuales con los de la copia de seguridad.\n\nEsta acción no se puede deshacer.';

  @override
  String get restoreDialogCancel => 'Cancelar';

  @override
  String get restoreDialogConfirm => 'Restaurar';

  @override
  String get restoreSuccess => '✅ Datos restaurados correctamente';

  @override
  String get restoreNoBackupFound =>
      'No se encontró ninguna copia de seguridad en Drive';

  @override
  String get restoreErrorGeneric => 'Error al restaurar. Intenta de nuevo.';

  @override
  String get backupIncludesTitle => 'La copia de seguridad incluye:';

  @override
  String get backupIncludesDatabase =>
      'Base de datos (transacciones, cuentas, metas)';

  @override
  String get backupIncludesReceipts => 'Fotos de recibos';

  @override
  String get backupIncludesEncryption =>
      'Cifrado AES-256 con tu cuenta de Google';

  @override
  String get backupIncludesEncryptionLocal =>
      'Cifrado AES-256 con la contraseña ingresada';

  @override
  String get backupSignOut => 'Salir';

  @override
  String get backupConnectGoogle => 'Conectar con Google';

  @override
  String get backupUploading => 'Subiendo...';

  @override
  String get backupDoNow => 'Realizar copia de seguridad ahora';

  @override
  String get backupRestoring => 'Restaurando...';

  @override
  String get backupRestoreFromDrive => 'Restaurar desde Drive';

  @override
  String get passwordNotEmpty => 'La contraseña no puede estar vacía';

  @override
  String get backupGenerateSuccess =>
      '✅ Copia de seguridad generada correctamente';

  @override
  String get backupPermissionDenied =>
      'Sin permiso para acceder al almacenamiento';

  @override
  String get selectedFileBackup =>
      'Selecciona el archivo de la copia de seguridad de Kaku';

  @override
  String get backupFileNotFound =>
      'No se encontró el archivo de copia de seguridad';

  @override
  String get backupFileNotValid =>
      'El archivo no es una copia de seguridad válida de Kaku o está dañado';

  @override
  String get backupMessageShare =>
      'El archivo se guarda en tu dispositivo. Puedes moverlo a Google Drive, WhatsApp o donde prefieras usando el botón Compartir. La contraseña es necesaria para descifrarlo (restaurar) y cifrar el archivo de copia de seguridad.';

  @override
  String get backupBtnCreating => 'Creando copia de seguridad...';

  @override
  String get backupBtnCreateShare => 'Crear y compartir copia de seguridad';

  @override
  String get backupBtnRestore => 'Restaurar desde archivo .zip';

  @override
  String get backupBtnRestoring => 'Restaurando...';

  @override
  String notifBudgetExceededTitle(String emoji) {
    return '$emoji Presupuesto excedido';
  }

  @override
  String notifBudgetWarningTitle(String emoji, String percent) {
    return '$emoji Presupuesto al $percent%';
  }

  @override
  String notifBudgetExceededBody(String spent, String limit, String category) {
    return 'Gastaste $spent de $limit en $category este mes';
  }

  @override
  String notifBudgetWarningBody(String spent, String limit, String category) {
    return 'Llevas $spent de $limit en $category';
  }

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String get notifActivatingBudget => 'Activo · Alertas de presupuesto';

  @override
  String get notifDeactivatingBudget => 'Inactivo';

  @override
  String get notifPermissionTitle => 'Permiso de notificaciones';

  @override
  String get notifPermissionSubtitle =>
      'Kaku necesita permiso para enviarte alertas cuando te acercas al límite de un presupuesto.\n\nHabilítalo en los Ajustes del dispositivo.';

  @override
  String get premiumBlockedBackupDrive =>
      'El backup a Google Drive es una función premium.\nCon el plan free puedes hacer backup local.';

  @override
  String get premiumBlockedExportPdfWithReceipts =>
      'El PDF con imágenes de recibos es una función premium.\nCon el plan free puedes exportar CSV o PDF básico.';

  @override
  String get premiumBlockedExportCustomRange =>
      'El rango personalizado de fechas es premium.\nCon el plan free puedes exportar el mes actual.';

  @override
  String get premiumBlockedViewHistory =>
      'El historial de más de un mes es una función premium.';

  @override
  String get premiumBlockedPinLock =>
      'El bloqueo por PIN o biometría es una función premium.';

  @override
  String premiumBlockedUnlimitedGoals(Object max) {
    return 'Has alcanzado el límite de $max metas del plan free.';
  }

  @override
  String premiumBlockedUnlimitedBudgets(Object max) {
    return 'Has alcanzado el límite de $max presupuestos del plan free.';
  }

  @override
  String premiumBlockedUnlimitedCategories(Object max) {
    return 'Has alcanzado el límite de $max categorías personalizadas del plan free.';
  }

  @override
  String permissionTitle(String source) {
    return 'Permiso de $source';
  }

  @override
  String permissionDesc(String source) {
    return 'Kaku necesita acceso a tu $source para adjuntar recibos. Habilítalo en los Ajustes del dispositivo.';
  }

  @override
  String messageNoReceipt(String source) {
    return 'No se pudo abrir la $source';
  }

  @override
  String get attachedReceipt => 'Recibo adjunto';

  @override
  String receiptName(String name) {
    return 'Recibo · $name';
  }

  @override
  String get toPinchToZoom => 'Pellizca para hacer zoom';

  @override
  String get receiptNotFound => 'No se pudo cargar el recibo';

  @override
  String get formRequired => 'Campo requerido';

  @override
  String get formName => 'Nombre';

  @override
  String get formBalanceInitial => 'Saldo inicial';

  @override
  String get formColor => 'Color';

  @override
  String get formIcon => 'Ícono';

  @override
  String get formAmountMajor => 'Debe ser mayor a 0';

  @override
  String get formContributeMajorTotal => 'No puedes aportar más que el total';

  @override
  String get formAccountNoBalance => 'Cuenta sin saldo suficiente';

  @override
  String get formLimitMajor => 'Ingresa un límite mayor a 0';

  @override
  String formMajorOrEqual(int value) {
    return 'Debe ser mayor o igual a $value';
  }

  @override
  String get formPassword => 'Contraseña';

  @override
  String accountsTitle(int isPlural) {
    String _temp0 = intl.Intl.pluralLogic(
      isPlural,
      locale: localeName,
      other: 'Cuenta',
      one: 'Cuentas',
    );
    return '$_temp0';
  }

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountTypeDebit => 'Débito';

  @override
  String get accountTypeCredit => 'Crédito';

  @override
  String get accountTypeSavings => 'Ahorro';

  @override
  String get accountDetail => 'Detalle de la cuenta';

  @override
  String get accountNotFound => 'Cuenta no encontrada';

  @override
  String get myAccountName => 'Mi cuenta';

  @override
  String get accountType => 'Tipo de cuenta';

  @override
  String get accountBalanceMessage =>
      'Este es el saldo actual de tu cuenta. Las transacciones futuras ajustarán este valor';

  @override
  String get accountUpdateSuccess => 'Cuenta actualizada';

  @override
  String get accountCreateSuccess => 'Cuenta creada';

  @override
  String get accountArchiveSuccess => 'Cuenta archivada';

  @override
  String get accountsErrorLoading => 'Error al cargar las cuentas';

  @override
  String get accountsNotCreated => 'No has creado ninguna cuenta';

  @override
  String get myAccounts => 'Mis cuentas';

  @override
  String get accountNew => 'Nueva cuenta';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String get accountInflow => 'Entrada';

  @override
  String get accountOutflow => 'Salida';

  @override
  String get balanceTotal => 'Balance total';

  @override
  String accountsActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas activas',
      one: '1 cuenta activa',
    );
    return '$_temp0';
  }

  @override
  String get thisMonth => 'este mes';

  @override
  String get savings => 'Ahorro';

  @override
  String categoriesTitle(int isPlural) {
    String _temp0 = intl.Intl.pluralLogic(
      isPlural,
      locale: localeName,
      other: 'Categoría',
      one: 'Categorías',
    );
    return '$_temp0';
  }

  @override
  String get categoryFood => 'Comida';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryHome => 'Casa';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryLeisure => 'Ocio';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryUtilities => 'Servicios';

  @override
  String get categorySavings => 'Ahorro';

  @override
  String get categorySalary => 'Salario';

  @override
  String get categoryFreelance => 'Freelance';

  @override
  String get categorySales => 'Ventas';

  @override
  String get categoryGifts => 'Regalos';

  @override
  String get categoryInvestments => 'Inversiones';

  @override
  String get categoryOtherIncome => 'Otros ingresos';

  @override
  String get notSetBudgetCategory =>
      'Sin presupuesto definido para esta categoría';

  @override
  String spentInMonth(String month) {
    return 'Gasto en $month';
  }

  @override
  String get categoryLimit => 'Límite';

  @override
  String categorySpentUsed(String spent) {
    return '$spent usado';
  }

  @override
  String categorySpentLeft(String spent) {
    return 'Quedan $spent';
  }

  @override
  String get categoryEmptyTitle => 'Sin categorías';

  @override
  String get categoryEmptySubtitle =>
      'Toca \'+ Nueva\' para crear tu primera categoría';

  @override
  String get errorLoadCategories => 'Error al cargar las categorías';

  @override
  String get newCategoryTitle => 'Nueva categoría';

  @override
  String get editCategoryTitle => 'Editar categoría';

  @override
  String get categoryNotFound => 'Categoría no encontrada';

  @override
  String get categoryEditSuccess => 'Categoría actualizada';

  @override
  String get categoryCreateSuccess => 'Categoría creada';

  @override
  String get categoryDeactivateTitle => 'Desactivar categoría';

  @override
  String categoryDeactivateSubtitle(
    String emoji,
    String category,
    int txCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      txCount,
      locale: localeName,
      other: '$txCount transacciones asociadas',
      one: '1 transacción asociada',
    );
    return '$emoji $category tiene $_temp0.\n\nAl desactivarla ya no aparecerá al agregar gastos, pero las transacciones existentes se conservan.';
  }

  @override
  String get categoryNotDeleted => 'No se puede eliminar';

  @override
  String categoryNotDeletedSubtitle(
    String emoji,
    String category,
    int txCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      txCount,
      locale: localeName,
      other: '$txCount transacciones asociadas',
      one: '1 transacción asociada',
    );
    return '$emoji $category tiene $_temp0.\n\nPara no perder el historial, solo puedes desactivarla. Seguirá visible en transacciones pasadas pero no aparecerá al agregar nuevos gastos.';
  }

  @override
  String get categoryDeleteConfirm => 'Eliminar categoría';

  @override
  String categoryDeleteConfirmSubtitle(String emoji, String category) {
    return '¿Eliminar $emoji $category?\n\nEsta categoría no tiene transacciones, por lo que se puede eliminar de forma permanente.';
  }

  @override
  String countActiveCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorías activas',
      one: '1 categoría activa',
    );
    return '$_temp0';
  }

  @override
  String categoryTitle(int isPlural) {
    String _temp0 = intl.Intl.pluralLogic(
      isPlural,
      locale: localeName,
      other: 'Categoría',
      one: 'Categorías',
    );
    return '$_temp0';
  }

  @override
  String get availableBalance => 'Saldo disponible';

  @override
  String get welcomeToKaku => 'Bienvenido a Kaku 👋';

  @override
  String get welcomeToKakuSubtitle => 'Tu bolsillo, bajo control';

  @override
  String welcomeToKakuName(String name) {
    return 'Hola, $name 👋';
  }

  @override
  String get errorLoadBudget => 'Error al cargar presupuestos';

  @override
  String bannerStateExceeded(String spent, String budget, String over) {
    return 'Llevas $spent gastados y tu límite era $budget. Te pasaste por $over este mes.';
  }

  @override
  String bannerStateCritical(String avg, String projection, String over) {
    return 'A este ritmo ($avg/día) gastarás $projection este mes, $over más de tu presupuesto.';
  }

  @override
  String bannerStateWarning(String projection, String budget) {
    return 'Al ritmo actual podrías llegar a $projection este mes vs tu presupuesto de $budget.';
  }

  @override
  String bannerStateNearEnd(int daysLeft, String percentage) {
    return 'Quedan $daysLeft días y ya usaste el $percentage de tu presupuesto.';
  }

  @override
  String get bannerConfigExceeded => 'Presupuesto superado';

  @override
  String get bannerConfigCritical => 'Vas a pasarte del presupuesto';

  @override
  String get bannerConfigWarning => 'Revisa tu ritmo de gasto';

  @override
  String get bannerConfigNearEnd => 'Casi al límite del mes';

  @override
  String get goalsTitle => 'Metas';

  @override
  String get contributeGoal => 'Aportar meta';

  @override
  String get btnContribute => 'Aportar';

  @override
  String get contributeAll => 'Todo';

  @override
  String leftToContribute(String amount) {
    return 'Quedan $amount para completar';
  }

  @override
  String get amountContributeToday => 'Monto a aportar hoy';

  @override
  String get newProgress => 'Nuevo progreso';

  @override
  String get contributeSuccess => 'Aporte realizado';

  @override
  String get btnConfirmContribute => 'Confirmar aporte';

  @override
  String get newGoalTitle => 'Nueva meta';

  @override
  String nameGoal(String name) {
    return 'Meta: $name';
  }

  @override
  String get amountGoal => 'Monto objetivo';

  @override
  String get dateGoal => 'Fecha límite (opcional)';

  @override
  String get dateGoalMessage =>
      'Si no ingresa una fecha, el sistema utilizará su historial de ahorro para estimar cuándo podría cumplir su meta.';

  @override
  String get goalUpdateSuccess => 'Meta actualizada';

  @override
  String get goalCreateSuccess => 'Meta creada';

  @override
  String get btnUpdateGoal => 'Actualizar Meta';

  @override
  String get btnCreateGoal => 'Crear Meta';

  @override
  String goalEditTitle(String name) {
    return 'Editar meta $name';
  }

  @override
  String get goalCompleteSuccess => 'Meta completada';

  @override
  String get goalDeleting => 'Meta eliminandose';

  @override
  String goalsActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activas · ',
      one: '1 activa · ',
    );
    return '$_temp0';
  }

  @override
  String goalComplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completadas',
      one: '1 Completada',
    );
    return '$_temp0';
  }

  @override
  String get goalsNoActive => 'Sin metas activas';

  @override
  String get premiumSubtitle => 'Lleva tus finanzas\nal siguiente nivel';

  @override
  String get premiumContent =>
      'Todas las herramientas que necesitas para\ntener control total de tu dinero.';

  @override
  String get premiumPaymentTitle => '✨ PAGO ÚNICO — SIN SUSCRIPCIÓN';

  @override
  String get premiumPaymentSubtitle => 'para siempre · un solo pago';

  @override
  String get premiumUnlockKaku => 'Desbloquear Kaku Premium';

  @override
  String get welcomeToPremium => '🎉 ¡Bienvenido a Kaku Premium!';

  @override
  String get billingPending =>
      'Pago pendiente. Te notificaremos cuando se confirme.';

  @override
  String get billingProductNotFound =>
      'No se encontró el producto en la tienda. Verifica tu conexión e intenta de nuevo.';

  @override
  String get billingFailed => 'Error al procesar el pago. Intenta de nuevo.';

  @override
  String get labelUnlockTitle => 'TODO LO QUE DESBLOQUEAS';

  @override
  String get billingRestorePurchase => 'Restaurar compra';

  @override
  String get billingCodePromo => '¿Tienes un código de descuento?';

  @override
  String get billingNoteLegal =>
      'Pago único · Sin suscripción · Sin cobros recurrentes';

  @override
  String get verifyingPurchase => 'Verificando compra...';

  @override
  String get verifyingPurchaseSuccess => '✅ Compra restaurada correctamente';

  @override
  String get billingRestorePurchaseNotFound =>
      'No se encontró ninguna compra previa asociada a tu cuenta de Google.';

  @override
  String get billingRestorePurchaseError =>
      'Error al restaurar. Intenta de nuevo.';

  @override
  String get premiumFeatureBackupDrive => 'Backup automático a Google Drive';

  @override
  String get premiumFeatureBackupDriveSubtitle =>
      'Sincroniza tu base de datos y recibos en la nube con un toque';

  @override
  String get premiumFeatureExportPdf => 'PDF con fotos de recibos';

  @override
  String get premiumFeatureExportPdfSubtitle =>
      'Exporta reportes completos con las imágenes adjuntas de cada compra';

  @override
  String get premiumFeatureExportCustomRange => 'Rango de fechas personalizado';

  @override
  String get premiumFeatureExportCustomRangeSubtitle =>
      'Exporta cualquier período de tiempo, no solo el mes actual';

  @override
  String get premiumFeatureUnlimitedGoals => 'Metas ilimitadas';

  @override
  String get premiumFeatureUnlimitedGoalsSubtitle =>
      'Crea todas las metas de ahorro que necesites sin restricciones';

  @override
  String get premiumFeatureUnlimitedBudgets => 'Presupuestos ilimitados';

  @override
  String get premiumFeatureUnlimitedBudgetsSubtitle =>
      'Asigna límites a todas tus categorías, no solo 3';

  @override
  String get premiumFeatureUnlimitedCategories =>
      'Categorías personalizadas ilimitadas';

  @override
  String get premiumFeatureUnlimitedCategoriesSubtitle =>
      'Organiza tus gastos con todas las categorías que quieras';

  @override
  String get premiumFeaturePinLock => 'Bloqueo con PIN o biometría';

  @override
  String get premiumFeaturePinLockSubtitle =>
      'Protege tu información financiera con huella, Face ID o PIN propio';

  @override
  String get premiumFeatureViewHistory => 'Historial completo de estadísticas';

  @override
  String get premiumFeatureViewHistorySubtitle =>
      'Analiza tus patrones de gasto en cualquier período pasado';

  @override
  String get redeemCodeErrorInvalid =>
      'Código no válido. Verifica e intenta de nuevo.';

  @override
  String get redeemCodeErrorAlreadyUsed =>
      'Este código ya fue canjeado en este dispositivo.';

  @override
  String get redeemCode => 'Canjear código';

  @override
  String get redeemCodeSubtitle =>
      'Ingresa tu código de descuento o acceso premium';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get themeTitle => 'Tema de color';

  @override
  String get themeSubtitle => 'Elige el color de acento de la app';

  @override
  String get themeModeTitle => 'Modo oscuro';

  @override
  String get themeModeSubtitle =>
      'Activa el modo oscuro o desactivalo para usar el tema claro';

  @override
  String get regionalTitle => 'Regional';

  @override
  String get currencyTitle => 'Moneda';

  @override
  String get budgetsSectionTitle => 'Presupuestos';

  @override
  String get budgetByCategoryTitle => 'Presupuestos por categorías';

  @override
  String budgetByCategorySubtitle(num count, Object monthYear) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count configurados',
      one: '1 configurado',
    );
    return '$monthYear - $_temp0';
  }

  @override
  String get dataTitle => 'Datos';

  @override
  String get storageLocalTitle => 'Almacenamiento local';

  @override
  String get storageNoReceipts => 'Sin recibos guardados';

  @override
  String storageSummary(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$size · $_temp0';
  }

  @override
  String get dangerZoneTitle => 'Zona peligrosa';

  @override
  String get deleteDataAllTitle => 'Borrar todos los datos';

  @override
  String get deleteDataAllSubtitle => 'Elimina todos los datos de la app';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get versionTitle => 'Versión';

  @override
  String get deleteText => 'BORRAR';

  @override
  String get errorDeletingData => 'Error al borrar los datos';

  @override
  String get messageDataAllDeleted =>
      'Esta acción es permanente e irreversible. Se eliminarán todos los datos de Kaku de tu dispositivo.';

  @override
  String get titleDeleteList => 'Se eliminarán permanentemente:';

  @override
  String get deleteListTransactions => 'Todas las transacciones';

  @override
  String get deleteListAccounts => 'Todas las cuentas';

  @override
  String get deleteListGoals => 'Todos los metas y aportes';

  @override
  String get deleteListBudgets => 'Todos los presupuestos';

  @override
  String get deleteListCategories => 'Todas las categorías personalizadas';

  @override
  String get deleteListReceipts => 'Todos los fotos de recibos';

  @override
  String get deleteListSettings => 'Toda la configuración de la app';

  @override
  String get writeWordDeleted => 'Escribe BORRAR para confirmar';

  @override
  String get selectedDatesRange => 'Selecciona un rango de fechas';

  @override
  String get last3Months => 'Últimos 3 meses';

  @override
  String thisYear(int year) {
    return 'Año $year';
  }

  @override
  String get rangeCustom => 'Rango personalizado';

  @override
  String get formatTitle => 'Formato';

  @override
  String get csvDecription => 'Para abrir en Excel o Google Sheets.';

  @override
  String get pdfBasic => 'PDF básico';

  @override
  String get pdfBasicDecription => 'Tabla de transacciones sin fotos.';

  @override
  String get pdfWithReceipts => 'PDF con fotos de recibos';

  @override
  String get pdfWithReceiptsDecription => 'PDF completo con fotos adjuntas.';

  @override
  String get periodTitle => 'Periodo';

  @override
  String get rangeTitle => 'Rango de fechas';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Elige el idioma de la app';

  @override
  String get languageSystem => 'Idioma del dispositivo';

  @override
  String budgetTitle(int plural) {
    String _temp0 = intl.Intl.pluralLogic(
      plural,
      locale: localeName,
      other: 'Presupuesto',
      one: 'Presupuestos',
    );
    return '$_temp0';
  }

  @override
  String get deleteBudgetConfirm => 'Eliminar presupuesto';

  @override
  String deleteBudgetConfirmSubtitle(String emoji, String category) {
    return '¿Eliminar el presupuesto de $emoji $category para este mes?';
  }

  @override
  String get limitMonth => 'Límite mensual';

  @override
  String get acumulateSurplus => 'Acumular sobrante';

  @override
  String get acumulateSurplusSubtitle =>
      'Si gastas menos de lo planeado, el sobrante se suma al próximo mes.';

  @override
  String get acumulateBudget => 'Acumular presupuesto';

  @override
  String get btnCreateBudget => 'Crear presupuesto';

  @override
  String get budgetTotal => 'Presupuesto total';

  @override
  String get budgetWornOut => 'Gastado';

  @override
  String get budgetAvailable => 'Disponible';

  @override
  String get unlimited => 'Sin límite';

  @override
  String budgetWornOutDescription(String spent) {
    return 'Gastado: $spent';
  }

  @override
  String budgetRemainingOrExceeded(int remaining, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Excedido',
      one: 'Quedan',
    );
    return '$_temp0 $amount';
  }

  @override
  String get editBudget => 'Editar presupuesto';

  @override
  String get createBudget => 'Nuevo presupuesto';

  @override
  String get budgetSaved => 'Presupuesto guardado';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileNameLabel => 'Nombre';

  @override
  String get profileEmailLabel => 'Email (Solo Lectura)';

  @override
  String get changesSaved => 'Cambios guardados';

  @override
  String get storageClearReceipts => 'Limpiar recibos';

  @override
  String storageReceiptsCleared(int count, String size) {
    return 'Se eliminarán $count fotos de recibos ($size) del dispositivo.\n\nLas transacciones se conservan pero ya no tendrán foto adjunta.';
  }

  @override
  String get storageReceiptsLabel => 'Fotos de recibos';

  @override
  String storageReceiptsSummary(int count, String size) {
    return '$count fotos de recibos · $size';
  }

  @override
  String get storageNoteInfo =>
      'Las fotos se guardan en el almacenamiento privado de la app y nunca salen de tu dispositivo.';

  @override
  String get storageCleaning => 'Limpiando...';

  @override
  String storageClearedInfo(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminarán $count recibos ($size)',
      one: 'Se eliminará un recibo',
      zero: 'Sin recibos que limpiar',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsEmptyThisMonth =>
      'No hay estadísticas para este mes o periodo';

  @override
  String get statsTotalLabel => 'Total';

  @override
  String get statsMonthLabel => 'Mes';

  @override
  String get statsQuarterLabel => 'Trimestre';

  @override
  String get statsYearLabel => 'Año';

  @override
  String get statsDonutTitle => 'Distribución';

  @override
  String statsDonutSubtitle(String monthName) {
    return 'Por categoría · $monthName';
  }

  @override
  String get statsTrendTitle => 'Tendencia';

  @override
  String get statsTrendSubtitle => 'Últimos 6 meses';

  @override
  String get statsTrendMonthVsPreviousTitle => 'Mes vs anterior';

  @override
  String statsTrendMonthVsPreviousSubtitle(
    String previousLabel,
    String currentLabel,
  ) {
    return '$previousLabel vs $currentLabel';
  }

  @override
  String get statsExpensesDiaryTitle => 'Gasto diario';

  @override
  String statsExpensesDiarySubtitle(int daysInMonth) {
    String _temp0 = intl.Intl.pluralLogic(
      daysInMonth,
      locale: localeName,
      other: '$daysInMonth días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get statsLast3MonthsTitle => 'Últimos 3 meses';

  @override
  String get statsLast3MonthsSubtitle => 'Gasto total por mes';

  @override
  String get statsLastYearTitle => 'Últimos 12 meses';

  @override
  String get statsTrend6MonthsTitle => 'Tendencia · Últimos 6 meses';

  @override
  String get statsTrend6MonthsSubtitle =>
      'Desbloquea Premium para ver tu historial completo de gastos.';

  @override
  String statsDailyBarChartTitle(String avg) {
    return 'Promedio: $avg/día';
  }

  @override
  String statsDailyBarChartTooltip(int day, String money) {
    return 'Día $day\n$money';
  }

  @override
  String get statsDailyBarChartAverage => 'Promedio';

  @override
  String get statsMonthComparationExpense => 'Gastaste';

  @override
  String statsMonthComparationLegend(String percent, int improved) {
    String _temp0 = intl.Intl.pluralLogic(
      improved,
      locale: localeName,
      other: 'más',
      one: 'menos',
    );
    return '$percent% $_temp0';
  }

  @override
  String get statsIncomeExpenseTitle => 'Ingresos vs gastos';

  @override
  String statsIncomeExpenseSubtitle(int months) {
    return 'Últimos $months meses';
  }

  @override
  String statsIncomeExpenseNet(String amount) {
    return 'Neto del periodo: $amount';
  }

  @override
  String get statsIncomeExpenseLocked => 'Disponible con Premium';

  @override
  String get premiumFeatureIncomeExpense => 'Gráfica de ingresos vs gastos';

  @override
  String get premiumFeatureIncomeExpenseSubtitle =>
      'Compara cuánto entra y cuánto sale cada mes';

  @override
  String get transactionTypeFilterAll => 'Todos';

  @override
  String get transactionTypeFilterByCategory => 'Por categoría';

  @override
  String transactionTypeExpense(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gastos',
      one: 'Gasto',
    );
    return '$_temp0';
  }

  @override
  String transactionTypeIncome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ingresos',
      one: 'Ingreso',
    );
    return '$_temp0';
  }

  @override
  String transactionTypeTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Transferencias',
      one: 'Transferencia',
    );
    return '$_temp0';
  }

  @override
  String get transactionsHistoryEmpty => 'Historial de transacciones vacío';

  @override
  String transactionTitle(int plural) {
    String _temp0 = intl.Intl.pluralLogic(
      plural,
      locale: localeName,
      other: 'Transacción',
      one: 'Transacciones',
    );
    return '$_temp0';
  }

  @override
  String transactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacciones',
      one: '1 transacción',
    );
    return '$_temp0';
  }

  @override
  String get transactionEmpty => 'Sin transacciones';

  @override
  String transactionTotalLabel(String currency) {
    return 'Total · $currency';
  }

  @override
  String get transactionDescriptionLabel => 'Descripción';

  @override
  String get transactionExpenseSaved => 'Gasto guardado';

  @override
  String get transactionIncomeSaved => 'Ingreso guardado';

  @override
  String get transactionTransferSaved => 'Transferencia guardada';

  @override
  String get transactionSavedGeneric => 'Transacción guardada';

  @override
  String get transactionExpenseBtnSaved => 'Guardar gasto';

  @override
  String get transactionIncomeBtnSaved => 'Guardar ingreso';

  @override
  String get transactionTransferBtnSaved => 'Guardar transferencia';

  @override
  String get transactionBtnSavedGeneric => 'Guardar transacción';

  @override
  String get addTransactionTitle => 'Nueva transacción';

  @override
  String get transferMessageEmpty =>
      'Registra al menos dos cuentas para poder crear transferencias';

  @override
  String transferAmountLabel(String currency) {
    return 'Cantidad o Monto · $currency';
  }

  @override
  String get transferAccountDestinationLabel => 'Cuenta destino';

  @override
  String get transferAccountOriginLabel => 'Cuenta origen';

  @override
  String get transferAccountDestEmpty => 'Seleccione una cuenta de destino';

  @override
  String get transferAccountOriginEmpty => 'Seleccione una cuenta de origen';

  @override
  String get transferAccountDestEqualOrigin =>
      'La cuenta destino no debe ser igual a la cuenta origen';

  @override
  String get transferAccountOriginEqualDest =>
      'La cuenta origen no debe ser igual a la cuenta destino';

  @override
  String get deleteTransactionConfirm => 'Eliminar transacción';

  @override
  String get deleteTransactionDesc =>
      'Esta acción no se puede deshacer. ¿Eliminar?';

  @override
  String get deleteTransactionSuccess => 'Transacción eliminada';

  @override
  String get transactionNotFound => 'Transacción no encontrada';

  @override
  String get messageTransactionAccountEmpty =>
      'Registra al menos una cuenta para poder crear transacciones';

  @override
  String amountOrValueUnit(String currency) {
    return 'Monto o valor unitario · $currency';
  }

  @override
  String get amountLabel => 'Cantidad';

  @override
  String get valueUnitLabel => 'Valor Unitario';

  @override
  String get viewReceipt => 'Ver recibo';

  @override
  String get receiptEmpty => 'Sin recibo';

  @override
  String get totalTransactionsLabel => 'Total';

  @override
  String get transactionDateCompleteLabel => 'Fecha y hora';

  @override
  String get transactionRecurrentLabel => 'Recurrente';

  @override
  String transactionIsRecurringLabel(int recurring) {
    String _temp0 = intl.Intl.pluralLogic(
      recurring,
      locale: localeName,
      other: 'No',
      one: 'Sí',
    );
    return '$_temp0';
  }

  @override
  String get transactionReceiptLabel => 'Foto de recibo';

  @override
  String transactionEditTitle(int id) {
    return 'Editar transacción #$id';
  }

  @override
  String get transactionDeletingLabel => 'Transacción eliminandose';

  @override
  String get balance => 'Balance';

  @override
  String get errorInsufficientFunds =>
      'Fondos insuficientes para esta transacción';

  @override
  String get errorAccountNotFound => 'Cuenta no encontrada';

  @override
  String get errorInvalidAmount => 'Cantidad no válida';

  @override
  String get errorNetworkError => 'Error de red';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get undo => 'Deshacer';

  @override
  String get btnClose => 'Cerrar';

  @override
  String get archived => 'Archivada';

  @override
  String get btnConfiguration => 'Configuración';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnViewPremium => 'Ver Premium';

  @override
  String get btnOpenSettings => 'Abrir Ajustes';

  @override
  String get btnResetZoom => 'Restablecer zoom';

  @override
  String get btnAdd => 'Añadir';

  @override
  String get btnEdit => 'Editar';

  @override
  String get btnUpdate => 'Actualizar';

  @override
  String get btnCreate => 'Crear';

  @override
  String get btnArchive => 'Archivar o Inactivar';

  @override
  String get btnViewDetail => 'Ver detalle';

  @override
  String btnNew(int femenine) {
    String _temp0 = intl.Intl.pluralLogic(
      femenine,
      locale: localeName,
      other: 'Nuevo',
      one: 'Nueva',
    );
    return '$_temp0';
  }

  @override
  String get btnDeactivate => 'Desactivar';

  @override
  String get btnActivate => 'Activar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnUnderstood => 'Entendido';

  @override
  String get btnDisableInstead => 'Desactivar en su lugar';

  @override
  String get btnRetry => 'Reintentar';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnClear => 'Limpiar';

  @override
  String get btnSaveChanges => 'Guardar cambios';

  @override
  String get btnConfirm => 'Confirmar';

  @override
  String get emojiLabel => 'Emoji';

  @override
  String get emojiHint => 'Elige un emoji';

  @override
  String get emojiHintSearch => 'Buscar emoji...';

  @override
  String get premiumLimitReached => 'Límite alcanzado';

  @override
  String get camera => 'Cámara';

  @override
  String get galery => 'Galería';

  @override
  String get selectedColor => 'Selecciona un color';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get history => 'Historial';

  @override
  String get preview => 'Vista previa';

  @override
  String get average => 'Promedio';

  @override
  String get majorSpending => 'Mayor gasto';

  @override
  String get viewAll => 'Ver todas';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get generatingLabel => 'Generando...';

  @override
  String get localeEn => 'Inglés';

  @override
  String get localeEs => 'Español';

  @override
  String get selectMonthYear => 'Selecciona mes y año';
}
