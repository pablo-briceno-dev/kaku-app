// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get balance => 'Balance';

  @override
  String get errorInsufficientFunds =>
      'Insufficient funds for this transaction';

  @override
  String get errorAccountNotFound => 'Account not found';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryServices => 'Services';

  @override
  String get errorInvalidAmount => 'Invalid amount';

  @override
  String get errorNetworkError => 'Network error';
}
