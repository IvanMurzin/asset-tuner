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

    return DSCard(
      padding: EdgeInsets.all(spacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.h3.copyWith(color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.s4),
                Text(caption, style: typography.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: spacing.s12),
            Padding(
              padding: EdgeInsets.only(top: spacing.s4),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
  }
}
