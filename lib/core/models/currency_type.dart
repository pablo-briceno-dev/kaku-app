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
}