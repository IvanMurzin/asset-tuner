import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatters = DSFormatters(Locale('en'));

  test('money keeps two fraction digits (QA-033)', () {
    expect(formatters.formatMoney(Decimal.parse('250.5'), 'USD'), '250.50 USD');
    expect(formatters.formatMoney(Decimal.parse('3'), 'EUR'), '3.00 EUR');
  });

  test('asset quantities keep their precision without padding beyond two digits', () {
    expect(
      formatters.formatMoney(Decimal.parse('0.0125'), 'BTC', maximumFractionDigits: 8),
      '0.0125 BTC',
    );
    expect(
      formatters.formatMoney(Decimal.parse('1.5'), 'BTC', maximumFractionDigits: 8),
      '1.50 BTC',
    );
  });

  test('large amounts keep every digit (R-08)', () {
    expect(
      formatters.formatMoney(Decimal.parse('123456789012345678901234.12'), 'USD'),
      '123,456,789,012,345,678,901,234.12 USD',
    );
  });

  test('negative amounts, rounding and grouping', () {
    expect(formatters.formatMoney(Decimal.parse('-1234.565'), 'USD'), '-1,234.57 USD');
    expect(formatters.formatDecimalFromDecimal(Decimal.parse('0.0004')), '0');
    expect(formatters.formatDecimalFromDecimal(Decimal.parse('-0.0004')), '0');
  });

  test('uses locale separators', () {
    const ru = DSFormatters(Locale('ru'));
    expect(ru.formatMoney(Decimal.parse('1234567.5'), 'RUB'), '1\u00a0234\u00a0567,50 RUB');
  });
}
