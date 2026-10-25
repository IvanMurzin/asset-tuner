import 'package:asset_tuner/presentation/balance/widget/subaccount_history_section.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history conversion matches the header for long amounts', () {
    final current = Decimal.parse('123456789012345678901234.12');
    final converted = Decimal.parse('175614195950337407424885.23');

    expect(convertAtCurrentRate(current, current, converted), converted);
    expect(
      convertAtCurrentRate(Decimal.parse('10'), Decimal.parse('4'), Decimal.parse('6')),
      Decimal.parse('15'),
    );
  });

  test('no conversion without a rate or a balance', () {
    expect(convertAtCurrentRate(Decimal.one, Decimal.zero, Decimal.one), isNull);
    expect(convertAtCurrentRate(Decimal.one, Decimal.one, null), isNull);
  });
}
