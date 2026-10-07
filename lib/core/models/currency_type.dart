import 'package:flutter/material.dart';
import 'package:kaku/l10n/app_localizations.dart';

enum CurrencyType {
  cop,
  usd,
  eur,
  mxn,
  ars;

  String get label {
    switch (this) {
      case CurrencyType.cop:
        return 'COP';
      case CurrencyType.usd:
        return 'USD';
      case CurrencyType.eur:
        return 'EUR';
      case CurrencyType.mxn:
        return 'MXN';
      case CurrencyType.ars:
        return 'ARS';
    }
  }

  String get labelCompact {
    switch (this) {
      case CurrencyType.cop:
        return 'CO';
      case CurrencyType.usd:
        return 'US';
      case CurrencyType.eur:
        return 'EU';
      case CurrencyType.mxn:
        return 'MX';
      case CurrencyType.ars:
        return 'AR';
    }
  }
}

extension CurrencyTypeL10n on CurrencyType {
  String labelComplete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      CurrencyType.cop => l10n.currencyCopLabel,
      CurrencyType.usd => l10n.currencyUsdLabel,
      CurrencyType.eur => l10n.currencyEurLabel,
      CurrencyType.mxn => l10n.currencyMxnLabel,
      CurrencyType.ars => l10n.currencyArsLabel,
    };
  }
}
