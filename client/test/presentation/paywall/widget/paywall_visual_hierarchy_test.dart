import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_plan_toggle.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_tier_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Paywall visual hierarchy', () {
    testWidgets('shows most popular badge on annual plan option with bottom-right overlap', (
      tester,
    ) async {
      await _pumpWidget(
        tester,
        PaywallPlanToggle(
          monthlyLabel: 'Monthly',
          yearlyLabel: 'Annual',
          annualBadgeText: 'Most Popular',
          selectedOption: PaywallPlanOption.annual,
          monthlyEnabled: true,
          yearlyEnabled: true,
          monthlyPrice: '\$4.99',
          yearlyPrice: '\$29.99',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Most Popular'), findsOneWidget);
      final annualRect = tester.getRect(find.byKey(const Key('paywall_plan_item_annual')));
      final badgeRect = tester.getRect(find.byKey(const Key('paywall_plan_badge')));

      expect(badgeRect.center.dx, greaterThan(annualRect.center.dx));
      expect((annualRect.right - badgeRect.right).abs(), lessThanOrEqualTo(20));
      expect(badgeRect.top, lessThan(annualRect.bottom));
      expect(badgeRect.bottom, greaterThan(annualRect.bottom));
    });

    testWidgets('does not render annual badge when badge text is not provided', (tester) async {
      await _pumpWidget(
        tester,
        PaywallPlanToggle(
          monthlyLabel: 'Monthly',
          yearlyLabel: 'Annual',
          selectedOption: PaywallPlanOption.annual,
          monthlyEnabled: true,
          yearlyEnabled: true,
          monthlyPrice: '\$4.99',
          yearlyPrice: '\$29.99',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Most Popular'), findsNothing);
    });

    testWidgets('does not show global badge on pro tier card', (tester) async {
      await _pumpWidget(
        tester,
        const PaywallTierCard(
          title: 'Pro',
          features: ['Unlimited accounts'],
          highlighted: true,
          dense: true,
        ),
      );

      expect(find.text('Most Popular'), findsNothing);
    });

    testWidgets('renders neutral free tier with muted check color', (tester) async {
      await _pumpWidget(
        tester,
        const PaywallTierCard(
          title: 'Free',
          features: ['Up to 5 accounts'],
          neutral: true,
          dense: true,
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      final colors = lightTheme.extension<DSColors>()!;
      expect(icon.color, colors.neutral500);
    });
  });
}

Future<void> _pumpWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
