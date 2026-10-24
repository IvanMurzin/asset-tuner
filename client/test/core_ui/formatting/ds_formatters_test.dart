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
}
