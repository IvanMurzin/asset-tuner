import 'package:asset_tuner/l10n/app_localizations_en.dart';
import 'package:asset_tuner/l10n/app_localizations_ru.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('subaccount counts use plural forms', () {
    final en = AppLocalizationsEn();
    expect(en.subaccountsCount(1), '1 subaccount');
    expect(en.subaccountsCount(3), '3 subaccounts');

    final ru = AppLocalizationsRu();
    expect(ru.subaccountsCount(1), '1 позиция');
    expect(ru.subaccountsCount(3), '3 позиции');
    expect(ru.subaccountsCount(5), '5 позиций');
    expect(ru.subaccountsCount(21), '21 позиция');
  });
}
