import 'package:asset_tuner/core_ui/components/ds_empty_card.dart';
import 'package:asset_tuner/core_ui/components/ds_history_entry_card.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: lightTheme,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('DSEmptyCard: a tap anywhere on the card runs the action (QA-033)', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      DSEmptyCard(
        title: 'No accounts',
        message: 'Add your first account',
        actionLabel: 'Add account',
        onAction: () => taps += 1,
      ),
    );

    await tester.tap(find.text('No accounts'));
    expect(taps, 1);
  });

  testWidgets('DSHistoryEntryCard: no change lines without a change (QA-033)', (tester) async {
    await _pump(
      tester,
      const DSHistoryEntryCard(
        dateText: 'Oct 24, 2026',
        deltaColor: Colors.grey,
        trailingPrimaryText: '100.00 USD',
      ),
    );

    expect(find.text('-'), findsNothing);
    expect(find.text('100.00 USD'), findsOneWidget);
  });

  testWidgets('DSHistoryEntryCard: a huge amount leaves room for the date', (tester) async {
    await _pump(
      tester,
      const SizedBox(
        width: 360,
        child: DSHistoryEntryCard(
          dateText: 'Oct 24, 2026',
          subtitleText: 'Implied change',
          deltaColor: Colors.grey,
          trailingPrimaryText: '123,456,789,012,345,678,901,234.12 USD',
        ),
      ),
    );

    // The label keeps a usable width instead of wrapping letter by letter (the test font is wide,
    // so two lines are fine).
    final lineHeight = tester.getSize(find.text('Oct 24, 2026')).height;
    expect(
      tester.getSize(find.text('Implied change')).height,
      lessThanOrEqualTo(2 * lineHeight),
    );
    expect(tester.takeException(), isNull);
  });
}
