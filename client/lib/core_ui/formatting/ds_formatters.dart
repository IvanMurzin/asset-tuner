import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class DSFormatters {
  const DSFormatters(this.locale);

  final Locale locale;

  String formatDecimal(num value, {int? minimumFractionDigits, int? maximumFractionDigits}) {
    final formatter = NumberFormat.decimalPattern(locale.toLanguageTag());
    if (minimumFractionDigits != null) {
      formatter.minimumFractionDigits = minimumFractionDigits;
    }
    if (maximumFractionDigits != null) {
      formatter.maximumFractionDigits = maximumFractionDigits;
    }
    return formatter.format(value);
  }

  /// Formats [value] exactly: a double would lose digits past ~15 significant ones (R-08).
  String formatDecimalFromDecimal(
    Decimal value, {
    int? minimumFractionDigits,
    int? maximumFractionDigits,
  }) {
    final symbols = NumberFormat.decimalPattern(locale.toLanguageTag()).symbols;
    final minDigits = minimumFractionDigits ?? 0;
    final maxDigits = maximumFractionDigits ?? 3;
    final rounded = value.round(scale: maxDigits);
    final digits = rounded.abs().toStringAsFixed(maxDigits);
    final dot = digits.indexOf('.');
    final integer = dot == -1 ? digits : digits.substring(0, dot);
    var fraction = dot == -1 ? '' : digits.substring(dot + 1);
    while (fraction.length > minDigits && fraction.endsWith('0')) {
      fraction = fraction.substring(0, fraction.length - 1);
    }

    final grouped = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) {
        grouped.write(symbols.GROUP_SEP);
      }
      grouped.write(integer[i]);
    }
    final sign = rounded < Decimal.zero ? symbols.MINUS_SIGN : '';
    final tail = fraction.isEmpty ? '' : '${symbols.DECIMAL_SEP}$fraction';
    return '$sign$grouped$tail';
  }

  /// Returns "amount currency" with at least two fraction digits (e.g. "1 234.50 USD"; an asset
  /// quantity with a larger [maximumFractionDigits] keeps its precision: "0.0125 BTC").
  String formatMoney(Decimal amount, String currency, {int maximumFractionDigits = 2}) {
    final formatted = formatDecimalFromDecimal(
      amount,
      minimumFractionDigits: maximumFractionDigits < 2 ? maximumFractionDigits : 2,
      maximumFractionDigits: maximumFractionDigits,
    );
    return '$formatted $currency';
  }

  String formatDate(DateTime value) {
    final local = value.isUtc ? value.toLocal() : value;
    return DateFormat.yMMMd(locale.toLanguageTag()).format(local);
  }

  String formatDateTime(DateTime value) {
    final local = value.isUtc ? value.toLocal() : value;
    return DateFormat.yMMMd(locale.toLanguageTag()).add_Hm().format(local);
  }
}

extension DSFormattersX on BuildContext {
  DSFormatters get dsFormatters => DSFormatters(Localizations.localeOf(this));
}
