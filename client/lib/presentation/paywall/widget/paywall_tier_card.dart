import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class PaywallTierCard extends StatelessWidget {
  const PaywallTierCard({
    super.key,
    required this.title,
    required this.features,
    this.highlighted = false,
    this.badgeText,
    this.dense = false,
  });

  final String title;
  final List<String> features;
  final bool highlighted;
  final String? badgeText;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final radius = context.dsRadius;
    final typography = context.dsTypography;

    final verticalPadding = dense ? spacing.s12 : spacing.s16;
    final iconSize = dense ? spacing.s16 : spacing.s24;
    final featureStyle = dense ? typography.caption : typography.body;
    final cardRadius = dense ? radius.r12 : radius.r16;
    final badgeHorizontal = dense ? spacing.s12 : spacing.s16;
    final badgeVertical = dense ? spacing.s4 : spacing.s8;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: highlighted ? colors.primary : colors.border,
              width: highlighted ? 2 : 1,
            ),
          ),
          child: DSCard(
            bordered: false,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (dense ? typography.h3 : typography.h2).copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: dense ? spacing.s8 : spacing.s16),
                for (var i = 0; i < features.length; i++) ...[
                  _PaywallFeatureRow(
                    text: features[i],
                    highlighted: highlighted,
                    iconSize: iconSize,
                    textStyle: featureStyle,
                    dense: dense,
                  ),
                  if (i != features.length - 1)
                    SizedBox(height: dense ? spacing.s8 : spacing.s12),
                ],
              ],
            ),
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: dense ? -12 : -14,
            left: dense ? spacing.s16 : spacing.s24,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: badgeHorizontal,
                vertical: badgeVertical,
              ),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeText!,
                style: typography.body.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PaywallFeatureRow extends StatelessWidget {
  const _PaywallFeatureRow({
    required this.text,
    required this.highlighted,
    required this.iconSize,
    required this.textStyle,
    required this.dense,
  });

  final String text;
  final bool highlighted;
  final double iconSize;
  final TextStyle textStyle;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: dense ? 1 : spacing.s4),
          child: Icon(
            Icons.check,
            size: iconSize,
            color: highlighted ? colors.primary : colors.textTertiary,
          ),
        ),
        SizedBox(width: dense ? spacing.s8 : spacing.s12),
        Expanded(
          child: Text(
            text,
            style: textStyle.copyWith(
              color: highlighted ? colors.textPrimary : colors.textSecondary,
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
