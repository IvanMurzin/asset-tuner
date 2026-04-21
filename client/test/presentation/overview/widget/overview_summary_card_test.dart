import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders contextual summary caption', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: OverviewSummaryCard(
            totalLabel: 'Total',
            totalValue: '\$1,240',
            pricedTotalLabel: null,
            pricedTotalValue: null,
            ratesText: 'Rates updated at 12:10',
          ),
        ),
      ),
    );

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('\$1,240'), findsOneWidget);
    expect(find.text('Rates updated at 12:10'), findsOneWidget);
  });
}
