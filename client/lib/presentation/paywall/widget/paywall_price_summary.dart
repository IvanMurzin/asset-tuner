import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';

class PaywallPriceSummary extends StatelessWidget {
  const PaywallPriceSummary({
    super.key,
    required this.monthlyLine,
    required this.yearlyLine,
    required this.selectedOption,
  });

  final String monthlyLine;
  final String yearlyLine;
  final PaywallPlanOption selectedOption;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    final entries = selectedOption == PaywallPlanOption.monthly
        ? [(monthlyLine, true), (yearlyLine, false)]
        : [(yearlyLine, true), (monthlyLine, false)];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Column(
        key: ValueKey(selectedOption),
        children: [
          _SummaryLine(text: entries[0].$1, emphasized: entries[0].$2),
          SizedBox(height: spacing.s4),
          _SummaryLine(text: entries[1].$1, emphasized: entries[1].$2),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.text, required this.emphasized});

  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      style: (emphasized ? typography.body : typography.caption).copyWith(
        color: emphasized ? colors.textPrimary : colors.textTertiary,
        fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
      ),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
