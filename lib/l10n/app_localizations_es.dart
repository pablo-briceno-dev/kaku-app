// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get balance => 'Balance';

  @override
  String get errorInsufficientFunds =>
      'Fondos insuficientes para esta transacción';

  @override
  String get errorAccountNotFound => 'Cuenta no encontrada';

  @override
  String get categoryFood => 'Comida';

  @override
  String get categoryServices => 'Servicios';

  @override
  String get errorInvalidAmount => 'Cantidad no válida';

  @override
  String get errorNetworkError => 'Error de red';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';
}
