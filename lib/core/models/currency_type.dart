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

  String get labelComplete {
    switch (this) {
      case CurrencyType.cop:
        return 'Peso colombiano';
      case CurrencyType.usd:
        return 'Dólar estadounidense';
      case CurrencyType.eur:
        return 'Euro';
      case CurrencyType.mxn:
        return 'Peso mexicano';
      case CurrencyType.ars:
        return 'Peso argentino';
    }
  }
}
