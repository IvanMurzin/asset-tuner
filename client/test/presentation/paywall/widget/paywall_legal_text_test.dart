import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_legal_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaywallLegalText', () {
    testWidgets('renders legal links and triggers callbacks', (tester) async {
      var termsTapCount = 0;
      var privacyTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: PaywallLegalText(
              prefix: 'Cancel anytime.',
              termsLabel: 'Terms',
              privacyLabel: 'Privacy',
              onTermsTap: () => termsTapCount += 1,
              onPrivacyTap: () => privacyTapCount += 1,
            ),
          ),
        ),
      );

      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);

      await tester.tap(find.text('Terms'));
      await tester.tap(find.text('Privacy'));

      expect(termsTapCount, 1);
      expect(privacyTapCount, 1);
    });
  });
}
