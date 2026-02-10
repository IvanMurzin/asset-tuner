import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ru');
  });

  test('DSFormatters formats decimals by locale', () {
    final en = DSFormatters(const Locale('en'));
    final ru = DSFormatters(const Locale('ru'));

    final enText = en.formatDecimal(
      123456.78,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    );
    final ruText = ru.formatDecimal(
      123456.78,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    );

    expect(enText, contains(','));
    expect(enText, contains('.'));
    expect(ruText, contains(','));
    expect(ruText, isNot(contains('.')));
    expect(ruText, anyOf(contains(' '), contains('\u00A0')));
  });

  test('DSFormatters formats dates by locale', () {
    final en = DSFormatters(const Locale('en'));
    final ru = DSFormatters(const Locale('ru'));
    final dateTime = DateTime(2026, 2, 10, 9, 30);

    final enText = en.formatDateTime(dateTime);
    final ruText = ru.formatDateTime(dateTime);

    expect(enText, contains('2026'));
    expect(ruText, contains('2026'));
    expect(enText, contains('09:30'));
    expect(ruText, contains('09:30'));
    expect(ruText, contains(RegExp(r'[А-Яа-я]')));
  });
}
