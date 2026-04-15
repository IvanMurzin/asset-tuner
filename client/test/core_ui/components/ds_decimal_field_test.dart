import 'package:asset_tuner/core_ui/components/ds_decimal_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses left alignment by default', (tester) async {
    await tester.pumpWidget(_TestApp(child: const DSDecimalField()));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.textAlign, TextAlign.start);
  });

  testWidgets('respects explicit text alignment override', (tester) async {
    await tester.pumpWidget(_TestApp(child: const DSDecimalField(textAlign: TextAlign.end)));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.textAlign, TextAlign.end);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dsColors = DSColors(
      primary: Colors.blue,
      primaryHover: Colors.blueAccent,
      onPrimary: Colors.white,
      background: Colors.white,
      surface: Colors.white,
      surfaceAlt: Colors.grey.shade200,
      textPrimary: Colors.black,
      textSecondary: Colors.black54,
      textTertiary: Colors.black45,
      textOnPrimary: Colors.white,
      border: Colors.black26,
      success: Colors.green,
      warning: Colors.orange,
      danger: Colors.red,
      info: Colors.lightBlue,
      neutral0: Colors.white,
      neutral50: Colors.grey.shade50,
      neutral100: Colors.grey.shade100,
      neutral200: Colors.grey.shade200,
      neutral300: Colors.grey.shade300,
      neutral400: Colors.grey.shade400,
      neutral500: Colors.grey.shade500,
      neutral600: Colors.grey.shade600,
      neutral700: Colors.grey.shade700,
      neutral900: Colors.grey.shade900,
      neutral950: Colors.black,
    );
    final theme = ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        dsColors,
        const DSSpacing(s4: 4, s8: 8, s12: 12, s16: 16, s24: 24, s32: 32),
        const DSRadius(r8: 8, r12: 12, r16: 16),
        const DSElevation(e0: <BoxShadow>[], e1: <BoxShadow>[], e2: <BoxShadow>[]),
        DSTypography.fromColors(dsColors),
      ],
    );

    return MaterialApp(
      theme: theme,
      home: Scaffold(body: child),
    );
  }
}
