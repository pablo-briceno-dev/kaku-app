import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kaku/core/models/currency_type.dart';

class CurrencyFormatter {
  // Formateadores base por moneda
  // Se crean una sola vez (son caros de instanciar) y se reutilizan
  static final Map<String, NumberFormat> _formatters = {};

  static NumberFormat _fmt(CurrencyType currency) => _formatters.putIfAbsent(
    currency.label,
    () =>
        NumberFormat.decimalPattern(_localeFor(currency))
          ..maximumFractionDigits = 0,
  );

  // Formato completo con separadores de miles
  static String format(
    double amount, [
    CurrencyType currency = CurrencyType.cop,
  ]) {
    final symbol = _symbolFor(currency);
    final sign = amount < 0 ? '-' : '';
    // Formateamos el valor absoluto y pegamos el símbolo al frente
    final number = _fmt(currency).format(amount.abs());
    return '$sign$symbol$number';
  }

  // Formato corto para listas y chips
  static String compact(
    double amount, [
    CurrencyType currency = CurrencyType.cop,
  ]) {
    final symbol = _symbolFor(currency);
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();

    if (abs >= 1_000_000_000) {
      return '$sign$symbol${_trimZero(abs / 1_000_000_000)}B'; // $2.4B (billones)
    }
    if (abs >= 1_000_000) {
      return '$sign$symbol${_trimZero(abs / 1_000_000)}M'; // $1.7M
    }
    if (abs >= 1_000) {
      return '$sign$symbol${_trimZero(abs / 1_000)}k'; // $32K
    }
    return '$sign$symbol${abs.toStringAsFixed(0)}'; // $850
  }

  // Formato completo con signo explícito + / -
  static String withSign(
    double amount, {
    CurrencyType currency = CurrencyType.cop,
    String? type, // 'income' | 'expense'
    bool isPercentage = false,
    bool compact = false,
  }) {
    final isNegative = type == 'expense' || amount < 0;
    final sign = isNegative ? '-' : '+';
    final abs = amount.abs();

    if (isPercentage) return '$sign${abs.toStringAsFixed(1)}%';

    final formatted = compact
        ? CurrencyFormatter.compact(abs, currency)
        : CurrencyFormatter.format(abs, currency);
    return '$sign$formatted';
  }

  // Convierte un String formateado de vuelta a double
  static double parse(String text) {
    if (text.trim().isEmpty) return 0.0;
    final clean = text
        .replaceAll(RegExp(r'[^\d,\.]'), '') // quita $, letras, espacios
        .replaceAll('.', '') // quita separador de miles COP
        .replaceAll(',', ''); // coma decimal -> punto
    return double.tryParse(clean) ?? 0.0;
  }

  // TextInputFormatter para el campo de monto
  static TextInputFormatter inputFormatter([
    CurrencyType currency = CurrencyType.cop,
  ]) => _CurrencyInputFormatter(currency);

  // Formatea un porcentaje con decimales opcionales
  static String percentage(double value, {int decimals = 0}) =>
      '${value.toStringAsFixed(decimals)}%';

  // Helpers
  static String _symbolFor(CurrencyType currency) =>
      const {
        CurrencyType.cop: r'$',
        CurrencyType.usd: r'US$',
        CurrencyType.eur: '€',
        CurrencyType.mxn: r'MX$',
        CurrencyType.ars: r'AR$',
      }[currency] ??
      r'$';

  static String _localeFor(CurrencyType currency) =>
      const {
        CurrencyType.cop: 'es_CO', // punto como sep de miles: $2.480.500
        CurrencyType.usd: 'en_US', // coma: $2,480,500
        CurrencyType.eur: 'de_DE', // punto como sep, coma decimal: €2.480.500
        CurrencyType.mxn: 'es_MX',
        CurrencyType.ars: 'es_AR',
      }[currency] ??
      'es_CO';

  // Elimina el ".0" cuando el valor compacto es entero.
  // _trimZero(1.0) → "1"   _trimZero(1.7) → "1.7"
  static String _trimZero(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.replaceAll('.0', '') : s;
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final CurrencyType currency;

  const _CurrencyInputFormatter(this.currency);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final amount = double.parse(digits);
    final formatted = CurrencyFormatter.format(amount, currency);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
