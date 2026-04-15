import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSBaseCurrencyValueCard extends StatelessWidget {
  const DSBaseCurrencyValueCard({
    super.key,
    required this.title,
    required this.caption,
    this.trailing,
  });

  final String title;
  final String caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DSCard(
          padding: EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(radius.r12),
                ),
                child: Icon(Icons.currency_exchange_rounded, color: colors.primary, size: 20),
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Text(
                  title,
                  style: typography.h3.copyWith(color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[SizedBox(width: spacing.s8), trailing!],
            ],
          ),
        ),
        SizedBox(height: spacing.s8),
        Text(caption, style: typography.caption.copyWith(color: colors.textSecondary)),
      ],
    );
  }
}
