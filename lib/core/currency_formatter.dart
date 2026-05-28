import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/transaction_type.dart';

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
    TransactionType? type, // 'income' | 'expense'
    bool isPercentage = false,
    bool compact = false,
  }) {
    final isNegative = type == TransactionType.expense || amount < 0;
    final sign = isNegative ? '-' : '+';
    final abs = amount.abs();

    if (isPercentage) return '$sign${abs.toStringAsFixed(1)}%';

    final formatted = compact
        ? CurrencyFormatter.compact(abs, currency)
        : CurrencyFormatter.format(abs, currency);
    return '$sign$formatted';
  }

  // ════════════════════════════════════════════════════════
  //  parse() actualizado — lee decimales correctamente
  //
  //  Reemplaza el parse() actual en CurrencyFormatter.
  //  El anterior hacía replaceAll('.', '') que eliminaba
  //  el separador decimal de USD rompiendo el valor.
  // ════════════════════════════════════════════════════════
  static double parse(String text, [CurrencyType currency = CurrencyType.cop]) {
    if (text.trim().isEmpty) return 0.0;

    // Quita el símbolo de moneda
    var clean = text.replaceAll(_symbolFor(currency), '').trim();

    if (currency == CurrencyType.usd || currency == CurrencyType.mxn) {
      // USD/MXN: miles con coma, decimal con punto
      // "1,200.50" → quita comas de miles → "1200.50"
      clean = clean.replaceAll(',', '');
      // El punto ya es el decimal correcto
    } else {
      // COP/EUR/ARS: miles con punto, decimal con coma
      // "1.200,50" → quita puntos de miles → "1200,50"
      //            → convierte coma decimal a punto → "1200.50"
      //
      // Pero "1.200" sin coma → es entero con punto de miles
      final hasComma = clean.contains(',');
      if (hasComma) {
        // Tiene coma → es separador decimal
        clean = clean.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Sin coma → los puntos son solo separadores de miles
        clean = clean.replaceAll('.', '');
      }
    }

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

  String get _thousandsSep => switch (currency) {
    CurrencyType.usd || CurrencyType.mxn => ',',
    _ => '.',
  };

  String get _decimalSep => switch (currency) {
    CurrencyType.usd || CurrencyType.mxn => '.',
    _ => ',',
  };

  bool get _hasDecimals => switch (currency) {
    CurrencyType.cop || CurrencyType.ars => false,
    _ => true,
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;

    // ── 1. Campo vacío ────────────────────────────────
    if (raw.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // ── 2. Quitar el símbolo de moneda para trabajar
    //       solo con el número que escribió el usuario
    final symbol = CurrencyFormatter._symbolFor(currency);
    final withoutSym = raw.replaceAll(symbol, '').trim();

    // ── 3. Detectar si el usuario escribió un separador decimal.
    //       Aceptamos AMBOS ("." y ",") sin importar la moneda —
    //       luego normalizamos al correcto.
    final hasDot = withoutSym.contains('.');
    final hasComma = withoutSym.contains(',');
    final hasDecimalInput = _hasDecimals && (hasDot || hasComma);

    // ── 4. Separar parte entera y decimal ─────────────
    // Primero normalizamos al separador decimal de la moneda
    // para poder hacer el split correctamente.
    final normalized = _normalize(withoutSym);
    final parts = normalized.split(_decimalSep);

    // Parte entera: solo dígitos
    final intPart = parts[0].replaceAll(RegExp(r'[^\d]'), '');

    // Parte decimal: solo dígitos, máximo 2
    final decPart = hasDecimalInput && parts.length > 1
        ? parts[1]
              .replaceAll(RegExp(r'[^\d]'), '')
              .substring(
                0,
                parts[1].replaceAll(RegExp(r'[^\d]'), '').length.clamp(0, 2),
              )
        : '';

    // ── 5. Si no hay nada útil, limpiar ───────────────
    if (intPart.isEmpty && !hasDecimalInput) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // ── 6. Formatear parte entera con separadores de miles
    final formattedInt = intPart.isEmpty ? '0' : _addThousands(intPart);

    // ── 7. Construir el string final ──────────────────
    final String formatted;
    if (hasDecimalInput) {
      // Muestra el separador aunque el usuario no haya
      // escrito dígitos decimales aún: "US$1,200."
      formatted = '$symbol$formattedInt$_decimalSep$decPart';
    } else {
      formatted = '$symbol$formattedInt';
    }

    // ── 8. Recalcular posición del cursor ─────────────
    final cursorPos = newValue.selection.end.clamp(0, raw.length);
    final digitsBeforeCursor = raw
        .substring(0, cursorPos)
        .replaceAll(RegExp(r'[^\d]'), '')
        .length;

    var newCursorPos = 0;
    var digitCount = 0;

    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
        if (digitCount == digitsBeforeCursor) {
          newCursorPos = i + 1;
          break;
        }
      }
      newCursorPos = i + 1;
    }

    // Cursor justo después del separador decimal
    if (hasDecimalInput && decPart.isEmpty) {
      newCursorPos = formatted.length;
    }

    if (digitsBeforeCursor == 0) {
      final firstDigit = formatted.indexOf(RegExp(r'\d'));
      newCursorPos = firstDigit >= 0 ? firstDigit : formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorPos.clamp(0, formatted.length),
      ),
    );
  }

  // ── Normaliza "." y "," al separador decimal correcto ──
  // El usuario puede escribir cualquiera de los dos.
  // Esta función convierte al separador de la moneda activa.
  String _normalize(String raw) {
    final hasDot = raw.contains('.');
    final hasComma = raw.contains(',');

    if (!hasDot && !hasComma) return raw;

    if (_decimalSep == '.') {
      // USD/MXN: decimal es "."
      // Si el usuario escribió "," con <= 2 dígitos después → era decimal
      if (hasComma && !hasDot) {
        final afterComma = raw
            .substring(raw.lastIndexOf(',') + 1)
            .replaceAll(RegExp(r'[^\d]'), '');
        return afterComma.length <= 2
            ? raw.replaceAll(',', '.') // coma → punto decimal
            : raw.replaceAll(',', ''); // coma de miles → quitar
      }
      // Ya tiene punto → correcto, pero quitamos posibles comas de miles
      return raw.replaceAll(',', '');
    } else {
      // COP/EUR/ARS: decimal es ","
      // Si el usuario escribió "." con <= 2 dígitos después → era decimal
      if (hasDot && !hasComma) {
        final afterDot = raw
            .substring(raw.lastIndexOf('.') + 1)
            .replaceAll(RegExp(r'[^\d]'), '');
        return afterDot.length <= 2
            ? raw.replaceAll('.', ',') // punto → coma decimal
            : raw.replaceAll('.', ''); // punto de miles → quitar
      }
      // Ya tiene coma → correcto, pero quitamos posibles puntos de miles
      return raw.replaceAll('.', '');
    }
  }

  // ── Agrega separadores de miles a la parte entera ────
  String _addThousands(String digits) {
    final result = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write(_thousandsSep);
      }
      result.write(digits[i]);
    }
    return result.toString();
  }
}
