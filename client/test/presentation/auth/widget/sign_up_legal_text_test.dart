import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/presentation/auth/widget/sign_up_legal_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignUpLegalText', () {
    testWidgets('renders terms and privacy labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: SignUpLegalText(
              prefix: 'By creating an account, you agree to our',
              termsLabel: 'Terms',
              privacyLabel: 'Privacy',
            ),
          ),
        ),
      );

      expect(find.text('By creating an account, you agree to our'), findsOneWidget);
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });
  });
}
