import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_positions_section.dart';
import 'package:asset_tuner/presentation/account/widget/subaccount_view_item.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountDetailPositionsSection', () {
    testWidgets('shows caption when subaccounts list has items', (tester) async {
      await _pumpSection(tester, items: [_item()]);

      expect(
        find.text('Use separate subaccounts for each currency or token inside this account.'),
        findsOneWidget,
      );
      expect(find.text('Main wallet'), findsOneWidget);
    });

    testWidgets('shows caption when subaccounts list is empty', (tester) async {
      await _pumpSection(tester, items: const []);

      expect(
        find.text('Use separate subaccounts for each currency or token inside this account.'),
        findsOneWidget,
      );
      expect(find.text('No subaccounts yet'), findsOneWidget);
    });

    testWidgets('localizes caption in russian locale', (tester) async {
      await _pumpSection(tester, items: const [], locale: const Locale('ru'));

      expect(
        find.text(
          'Используйте отдельные счёта для каждой валюты или токена внутри этого аккаунта.',
        ),
        findsOneWidget,
      );
    });
  });
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required List<SubaccountViewItem> items,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: AccountDetailPositionsSection(
            items: items,
            baseCurrency: 'USD',
            onAddSubaccount: () {},
            onOpenSubaccount: (_) async {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SubaccountViewItem _item() {
  return SubaccountViewItem(
    subaccountId: 'subaccount-1',
    assetId: 'asset-1',
    name: 'Main wallet',
    assetCode: 'USD',
    assetName: 'US Dollar',
    assetKind: AssetKind.fiat,
    originalAmount: Decimal.parse('123.45'),
    convertedAmount: Decimal.parse('123.45'),
  );
}
