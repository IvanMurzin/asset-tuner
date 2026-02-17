import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('en/ru ARB files have the same message keys', () {
    final en = _readArb('lib/l10n/app_en.arb');
    final ru = _readArb('lib/l10n/app_ru.arb');

    final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
    final ruKeys = ru.keys.where((k) => !k.startsWith('@')).toSet();

    expect(ruKeys, equals(enKeys));
  });

  test('ARB values are non-empty strings', () {
    final en = _readArb('lib/l10n/app_en.arb');
    final ru = _readArb('lib/l10n/app_ru.arb');

    final keys = en.keys.where((k) => !k.startsWith('@')).toList()..sort();

    for (final key in keys) {
      final enValue = en[key];
      final ruValue = ru[key];

      expect(enValue, isA<String>(), reason: 'en:$key is not a String');
      expect(ruValue, isA<String>(), reason: 'ru:$key is not a String');

      expect((enValue as String).trim(), isNotEmpty, reason: 'en:$key is empty');
      expect((ruValue as String).trim(), isNotEmpty, reason: 'ru:$key is empty');
    }
  });
}

Map<String, dynamic> _readArb(String path) {
  final raw = File(path).readAsStringSync();
  final decoded = jsonDecode(raw);
  return (decoded as Map).cast<String, dynamic>();
}
