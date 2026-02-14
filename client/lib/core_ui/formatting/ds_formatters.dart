import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class DSFormatters {
  const DSFormatters(this.locale);

  final Locale locale;

  String formatDecimal(
    num value, {
    int? minimumFractionDigits,
    int? maximumFractionDigits,
  }) {
    final formatter = NumberFormat.decimalPattern(locale.toLanguageTag());
    if (minimumFractionDigits != null) {
      formatter.minimumFractionDigits = minimumFractionDigits;
    }
    if (maximumFractionDigits != null) {
      formatter.maximumFractionDigits = maximumFractionDigits;
    }
    return formatter.format(value);
  }

  String formatDecimalFromDecimal(
    Decimal value, {
    int? minimumFractionDigits,
    int? maximumFractionDigits,
  }) {
    return formatDecimal(
      value.toDouble(),
      minimumFractionDigits: minimumFractionDigits,
      maximumFractionDigits: maximumFractionDigits,
    );
  }

  /// Returns "amount currency" (e.g. "1 234.56 USD").
  String formatMoney(
    Decimal amount,
    String currency, {
    int maximumFractionDigits = 2,
  }) {
    return '${formatDecimalFromDecimal(amount, maximumFractionDigits: maximumFractionDigits)} $currency';
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
