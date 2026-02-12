import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class OverviewSummaryCard extends StatelessWidget {
  const OverviewSummaryCard({
    super.key,
    required this.totalLabel,
    required this.totalValue,
    required this.pricedTotalLabel,
    required this.pricedTotalValue,
    required this.ratesText,
  });

  final String totalLabel;
  final String totalValue;
  final String? pricedTotalLabel;
  final String? pricedTotalValue;
  final String ratesText;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.22),
            colors.info.withValues(alpha: 0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(context.dsRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalLabel,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s8),
          Text(totalValue, style: typography.h1),
          if (pricedTotalLabel != null && pricedTotalValue != null) ...[
            SizedBox(height: spacing.s12),
            Text(
              '$pricedTotalLabel: $pricedTotalValue',
              style: typography.body.copyWith(color: colors.textSecondary),
            ),
          ],
          SizedBox(height: spacing.s12),
          Text(
            ratesText,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
